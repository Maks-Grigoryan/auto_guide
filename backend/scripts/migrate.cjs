const path = require('node:path');
const { spawnSync } = require('node:child_process');
const dotenv = require('dotenv');

dotenv.config({
  path: path.resolve(__dirname, '../../.env'),
  quiet: true,
});

if (!process.env.DATABASE_URL) {
  console.error('DATABASE_URL is not set. Create the root .env from .env.example.');
  process.exit(1);
}

const cli = path.resolve(
  __dirname,
  '../node_modules/node-pg-migrate/bin/node-pg-migrate.js',
);
const migrationDir = path.resolve(__dirname, '../../db/migrations');
const result = spawnSync(
  process.execPath,
  [cli, ...process.argv.slice(2), '-m', migrationDir, '--no-check-order'],
  { stdio: 'inherit', env: process.env },
);

if (result.error) {
  console.error(result.error.message);
  process.exit(1);
}
process.exit(result.status ?? 1);
