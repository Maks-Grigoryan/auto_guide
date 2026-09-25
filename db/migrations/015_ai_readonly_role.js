/**
 * Migration 015: a read-only database role for the AI assistant.
 *
 * JavaScript rather than .sql, and so are 016 and 017, for two reasons. This
 * one needs a password, and a password must not sit in a committed file — it is
 * read from AI_DB_PASSWORD at migration time. When that variable is unset or
 * empty (local dev without the assistant, CI without secrets) the migration
 * succeeds as a no-op with a NOTICE instead of failing: nothing else in the
 * chain depends on the role, and the assistant module only mounts when
 * LLM_API_KEY is set. The other two are .js to keep the
 * assistant's migrations a single group with working `down` sections: the .sql
 * migrations in this project have none, so `npm run migrate:down` refuses them
 * and a rollback has to be done by hand.
 *
 * This role is the second of three locks between the assistant and the data:
 *   1. the model never writes SQL — it picks from a fixed set of tools
 *   2. this role — SELECT on the catalogue, nothing else
 *   3. the pool that connects with default_transaction_read_only=on
 *
 * WHAT IS DELIBERATELY NOT GRANTED: users, pending_registrations, and the chat
 * tables from 017. Not "denied" — never granted, so for this role they may as
 * well not exist. A prompt that talks the model into asking for accounts gets a
 * permission error from PostgreSQL, not a list of phone numbers.
 *
 * There is no ALTER DEFAULT PRIVILEGES here on purpose. New tables grant
 * nothing to anyone but their owner, so a table added a year from now is
 * already invisible to this role; a REVOKE would only look like protection
 * while doing nothing. What keeps it true is the rule below: grants are written
 * out table by table, never as ON ALL TABLES.
 */

const CATALOGUE_TABLES = [
  'vendors',
  'parts',
  'part_fitments',
  'part_categories',
  'car_makes',
  'car_models',
  'car_generations',
  'service_categories',
  'vendor_services',
];

/** Escapes a value for a PostgreSQL string literal. */
function quoteLiteral(value) {
  return `'${value.replace(/'/g, "''")}'`;
}

function readPassword() {
  const password = process.env.AI_DB_PASSWORD;
  // No password means no assistant in this environment (local dev, CI without
  // secrets): skip with a NOTICE rather than failing the whole migrate:up.
  // The role is only needed when the assistant actually connects.
  if (!password) return null;
  if (password.length < 16) {
    throw new Error('AI_DB_PASSWORD must be at least 16 characters.');
  }
  // A backslash only matters when standard_conforming_strings is off, which it
  // is not by default — but a password containing one would be a silent
  // difference between environments, so refuse it rather than guess.
  if (/[\\\r\n\0]/.test(password)) {
    throw new Error(
      'AI_DB_PASSWORD must not contain backslashes, newlines or null bytes.',
    );
  }
  return password;
}

exports.up = (pgm) => {
  const password = readPassword();

  // No-op path: leave a NOTICE in the migration log so a missing password is
  // visible rather than silent, then succeed without creating anything.
  if (!password) {
    pgm.sql(`DO $$
      BEGIN
        RAISE NOTICE '015 skipped: AI_DB_PASSWORD not set — ai_readonly role not created.';
      END $$;`);
    return;
  }

  // A role is a cluster-level object, so it can already exist even on a fresh
  // database — created by an earlier run against the same PostgreSQL instance.
  pgm.sql(`
    DO $$
    BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'ai_readonly') THEN
        CREATE ROLE ai_readonly LOGIN;
      END IF;
    END $$;
  `);

  pgm.sql(`ALTER ROLE ai_readonly LOGIN PASSWORD ${quoteLiteral(password)};`);

  pgm.sql(`
    DO $$
    BEGIN
      EXECUTE format('GRANT CONNECT ON DATABASE %I TO ai_readonly', current_database());
    END $$;
  `);

  pgm.sql('GRANT USAGE ON SCHEMA public TO ai_readonly;');

  // Table by table. Never ON ALL TABLES — see the header.
  for (const table of CATALOGUE_TABLES) {
    pgm.sql(`GRANT SELECT ON ${table} TO ai_readonly;`);
  }
};

exports.down = (pgm) => {
  // DROP OWNED clears every privilege this role holds in the current database
  // in one statement; without it DROP ROLE fails on the dependent grants.
  pgm.sql(`
    DO $$
    BEGIN
      IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'ai_readonly') THEN
        EXECUTE 'DROP OWNED BY ai_readonly';
        EXECUTE format('REVOKE CONNECT ON DATABASE %I FROM ai_readonly', current_database());
        EXECUTE 'DROP ROLE ai_readonly';
      END IF;
    END $$;
  `);
};
