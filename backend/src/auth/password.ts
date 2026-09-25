import {
  randomBytes,
  scrypt,
  timingSafeEqual,
  type ScryptOptions,
} from 'node:crypto';

// Hand-wrapped rather than promisify(scrypt): promisify's typings resolve to
// the three-argument overload, so passing the cost parameters is a type error.
function scryptAsync(
  password: string,
  salt: Buffer,
  keyLength: number,
  options: ScryptOptions,
): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    scrypt(password, salt, keyLength, options, (error, derivedKey) => {
      if (error) reject(error);
      else resolve(derivedKey);
    });
  });
}

// scrypt rather than bcrypt or argon2: both of those are native modules, and
// the runtime image is node:20-alpine installed with `npm ci --omit=dev` and no
// build toolchain, so they would have to be compiled into the image or swapped
// for a slower pure-JS port. scrypt ships with Node, is memory-hard, and is on
// OWASP's list of acceptable password KDFs — no dependency, nothing to compile.
//
// N=16384, r=8, p=1 is the OWASP baseline (~16 MB and ~50-100 ms per hash).
// The parameters are stored in every hash, so raising them later leaves old
// hashes verifiable instead of locking everyone out.
const N = 16384;
const R = 8;
const P = 1;
const KEY_LENGTH = 64;
const SALT_LENGTH = 16;

/**
 * Guards against a caller posting a megabyte "password" and making the server
 * spend real memory hashing it. Past this length a password adds no strength.
 */
export const MAX_PASSWORD_LENGTH = 200;

/** Hashes [password] into a self-describing `scrypt$N$r$p$salt$hash` string. */
export async function hashPassword(password: string): Promise<string> {
  const salt = randomBytes(SALT_LENGTH);
  const derived = await scryptAsync(password, salt, KEY_LENGTH, {
    N,
    r: R,
    p: P,
    // Node refuses scrypt calls whose memory need exceeds maxmem (32 MB by
    // default). N=16384 with r=8 sits just under it, so ask for headroom
    // explicitly rather than depending on that default staying where it is.
    maxmem: 64 * 1024 * 1024,
  });

  return [
    'scrypt',
    N,
    R,
    P,
    salt.toString('base64'),
    derived.toString('base64'),
  ].join('$');
}

/**
 * Verifies [password] against a stored hash.
 *
 * Returns false for malformed or unknown-algorithm hashes rather than throwing,
 * so one corrupt row cannot turn a failed login into a 500 — which would tell
 * an attacker that the account exists.
 */
export async function verifyPassword(
  password: string,
  stored: string,
): Promise<boolean> {
  const parts = stored.split('$');
  if (parts.length !== 6 || parts[0] !== 'scrypt') return false;

  const n = Number(parts[1]);
  const r = Number(parts[2]);
  const p = Number(parts[3]);
  if (!Number.isInteger(n) || !Number.isInteger(r) || !Number.isInteger(p)) {
    return false;
  }

  const salt = Buffer.from(parts[4], 'base64');
  const expected = Buffer.from(parts[5], 'base64');
  if (salt.length === 0 || expected.length === 0) return false;

  const derived = await scryptAsync(password, salt, expected.length, {
    N: n,
    r,
    p,
    maxmem: 64 * 1024 * 1024,
  });

  // Constant-time: a plain === leaks how many leading bytes matched, which is
  // enough to reconstruct a hash byte by byte given enough attempts.
  return timingSafeEqual(derived, expected);
}
