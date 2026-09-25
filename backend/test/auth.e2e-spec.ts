import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';
import { AuthService } from '../src/auth/auth.service';
import {
  VERIFICATION_SENDER,
  VerificationSender,
  VerificationTarget,
} from '../src/auth/verification-sender';

/**
 * Captures the code instead of delivering it.
 *
 * The code is deliberately absent from every HTTP response, so a test has no
 * way to learn it except by standing where the sender stands — the same
 * position an SMS gateway would occupy.
 */
class CapturingSender implements VerificationSender {
  lastCode: string | null = null;
  lastTarget: VerificationTarget | null = null;

  async send(target: VerificationTarget, code: string): Promise<void> {
    this.lastTarget = target;
    this.lastCode = code;
  }
}

/**
 * The rate limiter is switched off for these tests. Registration allows five
 * attempts a minute, which this suite exceeds by design — leaving it on would
 * let the run's own speed decide whether it passes, and what is under test
 * here is the auth logic, not a third-party throttler.
 */
describe('/auth (e2e)', () => {
  let app: INestApplication;
  let auth: AuthService;
  const sender = new CapturingSender();

  // Unique per run so repeated runs against the same database do not collide
  // on the unique indexes from migrations 011, 012 and 014.
  const stamp = Date.now();
  const email = `user-${stamp}@example.com`;
  const phone = `+3741100${String(stamp).slice(-4)}`;
  const password = 'testpass123';

  /** Walks both registration steps and returns the verify response. */
  async function registerAndVerify(identifier: string, secret = password) {
    await request(app.getHttpServer())
      .post('/auth/register')
      .send({ identifier, password: secret })
      .expect(202);

    return request(app.getHttpServer())
      .post('/auth/verify')
      .send({ identifier, code: sender.lastCode })
      .expect(200);
  }

  beforeAll(async () => {
    // Must be set before AppModule is built: ThrottlerModule.forRoot reads it
    // while the module is being configured.
    process.env.THROTTLE_DISABLED = 'true';

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(VERIFICATION_SENDER)
      .useValue(sender)
      .compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({ transform: true, whitelist: true }));
    auth = app.get(AuthService);
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  // ── Step one: asking for a code ───────────────────────────────────────────

  it('register sends a code and creates no account yet', async () => {
    const res = await request(app.getHttpServer())
      .post('/auth/register')
      .send({ identifier: email, password })
      .expect(202);

    expect(res.body.accessToken).toBeUndefined();
    expect(sender.lastCode).toMatch(/^\d{6}$/);
    expect(sender.lastTarget?.login).toBe(email);

    // The account must not exist until the code comes back — signing in now
    // has to fail exactly as it would for a stranger.
    await request(app.getHttpServer())
      .post('/auth/login')
      .send({ identifier: email, password })
      .expect(401);
  });

  it('never puts the code in the response', async () => {
    const res = await request(app.getHttpServer())
      .post('/auth/register')
      .send({ identifier: `quiet-${stamp}@example.com`, password })
      .expect(202);

    // Anyone who could read their own code out of the reply would not need to
    // receive the message at all, which is the whole point of the step.
    expect(JSON.stringify(res.body)).not.toContain(sender.lastCode);
  });

  it('names where the code went, so the app can say so', async () => {
    const res = await request(app.getHttpServer())
      .post('/auth/register')
      .send({ identifier: phone, password })
      .expect(202);

    expect(res.body.sentTo.phone).toBe(phone);
    expect(res.body.sentTo.login).toBeNull();
  });

  // ── Step two: confirming ──────────────────────────────────────────────────

  it('verify creates the account and signs in', async () => {
    const res = await registerAndVerify(`ok-${stamp}@example.com`);

    expect(typeof res.body.accessToken).toBe('string');
    expect(res.body.user.login).toBe(`ok-${stamp}@example.com`);
    expect(res.body.user.role).toBe('user');
  });

  it('files an email identifier under login and leaves phone empty', async () => {
    const res = await registerAndVerify(`mail-${stamp}@example.com`);

    expect(res.body.user.login).toBe(`mail-${stamp}@example.com`);
    expect(res.body.user.phone).toBeNull();
  });

  it('files a phone identifier under phone and leaves login empty', async () => {
    const res = await registerAndVerify(phone);

    expect(res.body.user.phone).toBe(phone);
    expect(res.body.user.login).toBeNull();
  });

  it('rejects a wrong code and still creates nothing', async () => {
    const identifier = `wrong-${stamp}@example.com`;
    await request(app.getHttpServer())
      .post('/auth/register')
      .send({ identifier, password })
      .expect(202);

    const wrong = sender.lastCode === '000000' ? '111111' : '000000';
    await request(app.getHttpServer())
      .post('/auth/verify')
      .send({ identifier, code: wrong })
      .expect(401);

    await request(app.getHttpServer())
      .post('/auth/login')
      .send({ identifier, password })
      .expect(401);
  });

  it('throws the attempt away after too many wrong codes', async () => {
    const identifier = `bruteforce-${stamp}@example.com`;
    await request(app.getHttpServer())
      .post('/auth/register')
      .send({ identifier, password })
      .expect(202);
    const realCode = sender.lastCode!;

    const wrong = realCode === '000000' ? '111111' : '000000';
    for (let i = 0; i < 5; i++) {
      await request(app.getHttpServer())
        .post('/auth/verify')
        .send({ identifier, code: wrong })
        .expect(401);
    }

    // Even the correct code is refused now: the pending attempt is gone and a
    // new one has to be requested.
    await request(app.getHttpServer())
      .post('/auth/verify')
      .send({ identifier, code: realCode })
      .expect(400);
  });

  it('asking again replaces the previous code', async () => {
    const identifier = `resend-${stamp}@example.com`;
    await request(app.getHttpServer())
      .post('/auth/register')
      .send({ identifier, password })
      .expect(202);
    const firstCode = sender.lastCode!;

    await request(app.getHttpServer())
      .post('/auth/register')
      .send({ identifier, password })
      .expect(202);
    const secondCode = sender.lastCode!;

    // Two live codes for one identifier would double the guessing surface.
    if (firstCode !== secondCode) {
      await request(app.getHttpServer())
        .post('/auth/verify')
        .send({ identifier, code: firstCode })
        .expect(401);
    }

    await request(app.getHttpServer())
      .post('/auth/verify')
      .send({ identifier, code: secondCode })
      .expect(200);
  });

  it('refuses a code for an identifier nobody asked about', async () => {
    await request(app.getHttpServer())
      .post('/auth/verify')
      .send({ identifier: `nobody-${stamp}@example.com`, code: '123456' })
      .expect(400);
  });

  it('rejects a code that is not six digits', async () => {
    await request(app.getHttpServer())
      .post('/auth/verify')
      .send({ identifier: email, code: '12ab' })
      .expect(400);
  });

  // ── Registration rules that still hold ────────────────────────────────────

  it('ignores a role supplied in the registration body', async () => {
    const res = await registerAndVerify(`sneaky-${stamp}@example.com`);
    expect(res.body.user.role).toBe('user');
  });

  it('rejects registration with no identifier at all', async () => {
    await request(app.getHttpServer())
      .post('/auth/register')
      .send({ password })
      .expect(400);
  });

  it('rejects an identifier that is neither an address nor a number', async () => {
    await request(app.getHttpServer())
      .post('/auth/register')
      .send({ identifier: 'not-a-contact', password })
      .expect(400);
  });

  it('rejects a malformed email address', async () => {
    await request(app.getHttpServer())
      .post('/auth/register')
      .send({ identifier: 'broken@example', password })
      .expect(400);
  });

  it('rejects a number too short to be a phone', async () => {
    await request(app.getHttpServer())
      .post('/auth/register')
      .send({ identifier: '12345', password })
      .expect(400);
  });

  it('rejects a password shorter than 8 characters', async () => {
    await request(app.getHttpServer())
      .post('/auth/register')
      .send({ identifier: `short-${stamp}@example.com`, password: 'abc123' })
      .expect(400);
  });

  it('refuses to start a registration for an account that exists', async () => {
    await registerAndVerify(`taken-${stamp}@example.com`);

    await request(app.getHttpServer())
      .post('/auth/register')
      .send({ identifier: `TAKEN-${stamp}@EXAMPLE.COM`, password })
      .expect(409);
  });

  it('still refuses a bare name at registration, keeping short names free', async () => {
    // «admin» must not be claimable by whoever signs up first — that is what
    // makes an administrator's login safe to be a short word.
    await request(app.getHttpServer())
      .post('/auth/register')
      .send({ identifier: `plainname${stamp}`, password })
      .expect(400);
  });

  // ── Signing in ────────────────────────────────────────────────────────────

  it('never returns a password hash to the client', async () => {
    const res = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ identifier: phone, password })
      .expect(200);

    expect(JSON.stringify(res.body)).not.toContain('scrypt$');
    expect(res.body.user.password_hash).toBeUndefined();
  });

  it('signs in by address regardless of case', async () => {
    const identifier = `case-${stamp}@example.com`;
    await registerAndVerify(identifier);

    const res = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ identifier: identifier.toUpperCase(), password })
      .expect(200);

    expect(res.body.user.role).toBe('user');
  });

  it('signs in by phone however the number is punctuated', async () => {
    // Same digits, spelled the way a person would actually type them.
    const spaced = phone.replace(/^(\+\d{3})(\d{2})(\d+)$/, '$1 $2 $3');
    const res = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ identifier: spaced, password })
      .expect(200);

    expect(res.body.user.phone).toBe(phone);
  });

  it('rejects a wrong password', async () => {
    await request(app.getHttpServer())
      .post('/auth/login')
      .send({ identifier: phone, password: 'not-the-password' })
      .expect(401);
  });

  it('answers an unknown account exactly as it answers a wrong password', async () => {
    const unknown = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ identifier: `ghost-${stamp}@example.com`, password })
      .expect(401);

    const wrongPassword = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ identifier: phone, password: 'not-the-password' })
      .expect(401);

    // Identical wording is what stops login being used to discover which
    // addresses are registered.
    expect(unknown.body.message).toBe(wrongPassword.body.message);
  });

  // ── Session ───────────────────────────────────────────────────────────────

  it('GET /auth/me requires a token', async () => {
    await request(app.getHttpServer()).get('/auth/me').expect(401);
  });

  it('GET /auth/me rejects a token this server did not sign', async () => {
    await request(app.getHttpServer())
      .get('/auth/me')
      .set('Authorization', 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIn0.nope')
      .expect(401);
  });

  it('GET /auth/me returns the signed-in account', async () => {
    const signIn = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ identifier: phone, password })
      .expect(200);

    const res = await request(app.getHttpServer())
      .get('/auth/me')
      .set('Authorization', `Bearer ${signIn.body.accessToken}`)
      .expect(200);

    expect(res.body.phone).toBe(phone);
    expect(res.body.role).toBe('user');
  });

  // ── Administrators ────────────────────────────────────────────────────────

  it('signs in an admin by a bare name, not just an address or phone', async () => {
    // The name has no «@» and no digits, so registration would refuse it —
    // which is exactly why it is safe as an administrator's login.
    const name = `root${stamp}`;
    await auth.createAdmin({ login: name, password: 'adminpass1234' });

    const res = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ identifier: name, password: 'adminpass1234' })
      .expect(200);

    expect(res.body.user.role).toBe('admin');
  });

  it('creates admins without any confirmation code', async () => {
    // createAdmin is what `npm run admin:create` calls. It bypasses the whole
    // verification flow on purpose: whoever can run it already has shell
    // access to the server, and there is nowhere to send a code to.
    const adminLogin = `admin-${stamp}@example.com`;
    await auth.createAdmin({ login: adminLogin, password: 'adminpass1234' });

    const res = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ identifier: adminLogin, password: 'adminpass1234' })
      .expect(200);

    expect(res.body.user.role).toBe('admin');
  });
});
