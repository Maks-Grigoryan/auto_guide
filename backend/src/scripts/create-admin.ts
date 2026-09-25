import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { AuthService } from '../auth/auth.service';

/**
 * Creates or promotes an administrator.
 *
 *   npm run admin:create -- --login=admin --password='…'
 *   npm run admin:create -- --phone='+37411000000' --password='…'
 *
 * In Docker:
 *   docker compose exec api node dist/scripts/create-admin --login=… --password=…
 *
 * This script is the ONLY way an admin comes into existence. Nothing served
 * over HTTP can produce one: registration has no role parameter and the column
 * defaults to 'user'. Running an admin account therefore requires shell access
 * to the deployment, which is exactly the intent.
 *
 * The password is read from an argument rather than prompted for, so remember
 * it lands in shell history — prefix the command with a space, or pass it
 * through the ADMIN_PASSWORD environment variable instead.
 */
async function main(): Promise<void> {
  const args = parseArgs(process.argv.slice(2));

  // --email is kept as an alias for --login: the column was renamed in
  // migration 012, and the old flag is in shell history and in earlier docs.
  const login =
    args.login ??
    args.email ??
    process.env.ADMIN_LOGIN ??
    process.env.ADMIN_EMAIL;
  const phone = args.phone ?? process.env.ADMIN_PHONE;
  const password = args.password ?? process.env.ADMIN_PASSWORD;

  if (!login && !phone) {
    fail('Provide --login or --phone (or ADMIN_LOGIN / ADMIN_PHONE).');
  }
  if (!password) {
    fail('Provide --password (or ADMIN_PASSWORD).');
  }
  if (password.length < 8) {
    fail('Admin password must be at least 8 characters.');
  }
  if (password.length < 12 || /^(admin|password|qwerty|12345)/i.test(password)) {
    // Not refused — whoever has shell access on the server gets to decide. But
    // this is the account worth attacking, so a weak choice is said out loud
    // rather than accepted in silence.
    process.stderr.write(
      'WARNING: this admin password is short or predictable. ' +
        'Change it before the deployment is reachable from the internet.\n',
    );
  }

  const app = await NestFactory.createApplicationContext(AppModule, {
    logger: ['error', 'warn'],
  });

  try {
    const auth = app.get(AuthService);
    const user = await auth.createAdmin({ login, phone, password });
    process.stdout.write(
      `Admin ready: id=${user.id} login=${user.login ?? '-'} ` +
        `phone=${user.phone ?? '-'} role=${user.role}\n`,
    );
  } finally {
    await app.close();
  }
}

function parseArgs(argv: string[]): Record<string, string> {
  const parsed: Record<string, string> = {};
  for (const arg of argv) {
    const match = /^--([\w-]+)=(.*)$/.exec(arg);
    if (match) parsed[match[1]] = match[2];
  }
  return parsed;
}

function fail(message: string): never {
  process.stderr.write(`${message}\n`);
  process.exit(1);
}

void main().catch((error: unknown) => {
  process.stderr.write(
    `Failed to create admin: ${
      error instanceof Error ? error.message : String(error)
    }\n`,
  );
  process.exit(1);
});
