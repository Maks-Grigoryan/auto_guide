import {
  BadRequestException,
  ConflictException,
  Inject,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { randomInt } from 'node:crypto';
import { Pool } from 'pg';
import { PG_POOL } from '../database/database.module';
import { hashPassword, verifyPassword } from './password';
import {
  VERIFICATION_SENDER,
  VerificationSender,
  VerificationTarget,
} from './verification-sender';

/**
 * How long a confirmation code stays usable. Long enough for a message to
 * arrive and be typed without hurrying anyone, short enough that a code read
 * off a borrowed phone an hour later is worthless.
 */
const CODE_TTL_MINUTES = 10;

/**
 * Wrong guesses before the attempt is discarded and a new code must be asked
 * for. Six digits is a million combinations, so this is not really about
 * exhausting them — it is about not leaving one code standing while somebody
 * grinds away at it.
 */
const MAX_CODE_ATTEMPTS = 5;

export type UserRole = 'user' | 'admin';

/** An account as the rest of the app sees it — never carries the hash. */
export interface AuthUser {
  id: string;
  login: string | null;
  phone: string | null;
  role: UserRole;
}

interface UserRow extends AuthUser {
  password_hash: string;
}

/**
 * Lower-cases and trims a login so `Ivan@Example.com` and `ivan@example.com`
 * are one account — matching the `lower(login)` unique index in migration 012.
 */
export function normalizeLogin(login: string): string {
  return login.trim().toLowerCase();
}

/**
 * Reduces a phone number to `+` followed by digits.
 *
 * People type `+374 11 000000`, `(011) 00-00-00` and `+374-11-000000` for the
 * same line. Without this each spelling becomes a separate account, and the
 * unique index never sees that they collide.
 */
export function normalizePhone(phone: string): string {
  const cleaned = phone.replace(/[^\d+]/g, '');
  return cleaned.startsWith('+')
    ? '+' + cleaned.slice(1).replace(/\+/g, '')
    : cleaned.replace(/\+/g, '');
}

// Deliberately loose — enough to tell an address from a phone number and to
// catch an obvious typo, without inventing a stricter rule than real mail
// servers apply.
const EMAIL_SHAPE = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;
const PHONE_SHAPE = /^\+?[\d\s()-]+$/;

/** Which column a registration identifier belongs in, once recognised. */
export type ClassifiedIdentifier =
  | { column: 'login'; value: string }
  | { column: 'phone'; value: string };

/**
 * Decides whether a registration identifier is an email address or a phone
 * number, and normalises it. Returns null when it is neither.
 *
 * Registration takes ONE identifier, so this is where the choice is made.
 * Asking someone to fill in an email box and a phone box and then accepting
 * either made the form look like both were wanted.
 *
 * A bare word such as «admin» is rejected: it has no `@`, and as a phone
 * number it normalises to an empty string. That is deliberate — it keeps short
 * names unclaimable through sign-up, so an administrator's login cannot be
 * taken by whoever registers first. Admins are created by `admin:create`,
 * which does not come through here.
 */
export function classifyIdentifier(raw: string): ClassifiedIdentifier | null {
  const trimmed = raw.trim();
  if (!trimmed) return null;

  if (trimmed.includes('@')) {
    return EMAIL_SHAPE.test(trimmed)
      ? { column: 'login', value: normalizeLogin(trimmed) }
      : null;
  }

  if (!PHONE_SHAPE.test(trimmed)) return null;
  const phone = normalizePhone(trimmed);
  const digits = phone.replace(/\D/g, '');
  // Six is the shortest real subscriber number; fifteen is the E.164 maximum.
  if (digits.length < 6 || digits.length > 15) return null;
  return { column: 'phone', value: phone };
}

@Injectable()
export class AuthService {
  constructor(
    @Inject(PG_POOL) private readonly pool: Pool,
    @Inject(VERIFICATION_SENDER)
    private readonly sender: VerificationSender,
  ) {}

  /**
   * Step one of registration: remembers the details, sends a confirmation code,
   * and creates NO account.
   *
   * Nothing lands in `users` until the code comes back, so an address or number
   * typed by someone who does not own it expires quietly instead of becoming an
   * account — and instead of blocking the real owner, which is what an
   * unverified row in `users` would do.
   *
   * Returns where the code went so the app can tell the person what to check.
   */
  async startRegistration(
    identifier: string,
    password: string,
  ): Promise<VerificationTarget> {
    const classified = classifyIdentifier(identifier);
    if (!classified) {
      throw new BadRequestException('Enter a phone number or an email address');
    }

    const login = classified.column === 'login' ? classified.value : null;
    const phone = classified.column === 'phone' ? classified.value : null;

    // Refuse early if the account exists, rather than sending a code that could
    // never complete. This does tell the caller that the identifier is taken —
    // the same thing registration has always admitted by returning 409 — and
    // the alternative, staying silent and never sending a code, strands people
    // who simply forgot they had signed up.
    const existing = await this.findByIdentifier(login ?? phone ?? '');
    if (existing) {
      throw new ConflictException('Account already exists');
    }

    const code = generateCode();
    const [passwordHash, codeHash] = await Promise.all([
      hashPassword(password),
      hashPassword(code),
    ]);

    await this.pool.query('DELETE FROM pending_registrations WHERE expires_at < now()');
    await this.pool.query(
      `DELETE FROM pending_registrations
        WHERE ($1::text IS NOT NULL AND lower(login) = lower($1))
           OR ($2::text IS NOT NULL AND phone = $2)`,
      [login, phone],
    );
    await this.pool.query(
      `INSERT INTO pending_registrations
         (login, phone, password_hash, code_hash, expires_at)
       VALUES ($1, $2, $3, $4, now() + ($5 || ' minutes')::interval)`,
      [login, phone, passwordHash, codeHash, String(CODE_TTL_MINUTES)],
    );

    const target: VerificationTarget = { login, phone };
    await this.sender.send(target, code);
    return target;
  }

  /**
   * Step two: checks the code and, only then, creates the account.
   *
   * There is intentionally no role parameter anywhere on this path. It is the
   * only account route exposed over HTTP and can produce nothing but
   * `role = 'user'` — the column default from migration 011 does the work.
   * Admins come from [createAdmin], reachable only from `admin:create`.
   */
  async verifyRegistration(
    identifier: string,
    code: string,
  ): Promise<AuthUser> {
    const classified = classifyIdentifier(identifier);
    if (!classified) {
      throw new BadRequestException('Enter a phone number or an email address');
    }

    const login = classified.column === 'login' ? classified.value : null;
    const phone = classified.column === 'phone' ? classified.value : null;

    const pending = await this.pool.query<{
      id: string;
      password_hash: string;
      code_hash: string;
      attempts: number;
      expired: boolean;
    }>(
      `SELECT id::text, password_hash, code_hash, attempts,
              (expires_at < now()) AS expired
         FROM pending_registrations
        WHERE ($1::text IS NOT NULL AND lower(login) = lower($1))
           OR ($2::text IS NOT NULL AND phone = $2)
        LIMIT 1`,
      [login, phone],
    );

    const row = pending.rows[0];
    // No attempt, an expired one, or one already argued with too many times —
    // all answered the same way, because they all mean "ask for a new code".
    if (!row || row.expired || row.attempts >= MAX_CODE_ATTEMPTS) {
      if (row) await this.discardPending(row.id);
      throw new BadRequestException('Code expired — request a new one');
    }

    if (!(await verifyPassword(code, row.code_hash))) {
      await this.pool.query(
        'UPDATE pending_registrations SET attempts = attempts + 1 WHERE id = $1',
        [row.id],
      );
      throw new UnauthorizedException('Invalid code');
    }

    try {
      const result = await this.pool.query<AuthUser>(
        `INSERT INTO users (login, phone, password_hash)
         VALUES ($1, $2, $3)
         RETURNING id::text, login, phone, role`,
        [login, phone, row.password_hash],
      );
      await this.discardPending(row.id);
      return result.rows[0];
    } catch (error) {
      // Someone else confirmed the same identifier between step one and step
      // two. Rare, but the unique index is what decides, not the pending row.
      if (isUniqueViolation(error)) {
        await this.discardPending(row.id);
        throw new ConflictException('Account already exists');
      }
      throw error;
    }
  }

  private async discardPending(id: string): Promise<void> {
    await this.pool.query('DELETE FROM pending_registrations WHERE id = $1', [
      id,
    ]);
  }

  /**
   * Verifies credentials and returns the account, including its role.
   *
   * A missing account and a wrong password produce the identical error on
   * purpose: told apart, they let anyone enumerate which phone numbers and
   * addresses are registered.
   */
  async login(identifier: string, password: string): Promise<AuthUser> {
    const row = await this.findByIdentifier(identifier);

    // Hash even when there is no account. Returning early here would make
    // "unknown account" measurably faster than "wrong password", revealing
    // exactly what the shared error message exists to hide.
    const hash = row?.password_hash ?? DUMMY_HASH;
    const passwordMatches = await verifyPassword(password, hash);

    if (!row || !passwordMatches) {
      throw new UnauthorizedException('Invalid credentials');
    }
    return { id: row.id, login: row.login, phone: row.phone, role: row.role };
  }

  async findById(id: string): Promise<AuthUser | null> {
    const result = await this.pool.query<AuthUser>(
      `SELECT id::text, login, phone, role FROM users WHERE id = $1`,
      [id],
    );
    return result.rows[0] ?? null;
  }

  /**
   * Creates or promotes an administrator. Called only by `admin:create`; it is
   * wired to no controller, which is what makes "admin by code only" true
   * rather than merely intended.
   *
   * Unlike [register] this does not go through [classifyIdentifier] — which is
   * what lets an admin sign in as a short name like «admin» that sign-up
   * refuses.
   */
  async createAdmin(params: {
    login?: string;
    phone?: string;
    password: string;
  }): Promise<AuthUser> {
    const login = params.login ? normalizeLogin(params.login) : null;
    const phone = params.phone ? normalizePhone(params.phone) : null;
    const passwordHash = await hashPassword(params.password);

    const existing = await this.findByIdentifier(login ?? phone ?? '');
    if (existing) {
      const result = await this.pool.query<AuthUser>(
        `UPDATE users SET role = 'admin', password_hash = $2
          WHERE id = $1
      RETURNING id::text, login, phone, role`,
        [existing.id, passwordHash],
      );
      return result.rows[0];
    }

    const result = await this.pool.query<AuthUser>(
      `INSERT INTO users (login, phone, password_hash, role)
       VALUES ($1, $2, $3, 'admin')
       RETURNING id::text, login, phone, role`,
      [login, phone, passwordHash],
    );
    return result.rows[0];
  }

  /**
   * Finds an account by whichever identifier was typed.
   *
   * Both columns are searched rather than picking one from the shape of the
   * string. Guessing — «contains @, so it is an email, otherwise a phone» —
   * silently loses any identifier that is neither: run through the phone
   * normaliser, `admin` has every non-digit stripped and becomes an empty
   * string, so the lookup could never match it.
   *
   * The phone parameter is normalised because stored numbers are; the login one
   * is compared lower-case against the `lower(login)` unique index.
   */
  private async findByIdentifier(identifier: string): Promise<UserRow | null> {
    const trimmed = identifier.trim();
    if (!trimmed) return null;

    const asPhone = normalizePhone(trimmed);
    const result = await this.pool.query<UserRow>(
      `SELECT id::text, login, phone, role, password_hash
         FROM users
        WHERE lower(login) = $1
           OR (phone IS NOT NULL AND $2 <> '' AND phone = $2)
        LIMIT 1`,
      [normalizeLogin(trimmed), asPhone],
    );

    return result.rows[0] ?? null;
  }
}

/**
 * A six-digit confirmation code.
 *
 * randomInt, not Math.random: this is a credential, and Math.random is
 * predictable from previous outputs. Padded rather than ranged from 100000 so
 * codes beginning with a zero are possible — excluding them would quietly throw
 * away a tenth of the space.
 */
function generateCode(): string {
  return randomInt(0, 1_000_000).toString().padStart(6, '0');
}

function isUniqueViolation(error: unknown): boolean {
  return (
    typeof error === 'object' &&
    error !== null &&
    (error as { code?: string }).code === '23505'
  );
}

/**
 * A syntactically valid scrypt hash used to spend the same time on a login for
 * an account that does not exist. Its plaintext is irrelevant and unknown —
 * only the cost of verifying against it matters.
 */
const DUMMY_HASH =
  'scrypt$16384$8$1$AAAAAAAAAAAAAAAAAAAAAA==$' +
  'ZOb0aVnLZmPBTBmYvNnjNkVDR3dS0nJj0kQrJ0z0EYh7' +
  'cW4E1oXwJ0lMSJ0K0d0P0aVnLZmPBTBmYvNnjNg==';
