-- Migration 011: user accounts with roles
--
-- Sign-in accepts either a phone number or an email address, so both columns
-- are nullable and a CHECK requires at least one. Uniqueness is enforced with
-- partial indexes rather than column constraints, because a plain UNIQUE would
-- let unlimited rows share NULL in the column an account does not use — that is
-- how NULL behaves in SQL, and exactly the case here.
--
-- Email uniqueness is case-insensitive (`lower(email)`): someone who signed up
-- as Ivan@example.com must not be able to register again as ivan@example.com
-- and end up with two accounts that look identical wherever they are printed.
--
-- ROLE IS DELIBERATELY NOT SETTABLE FROM THE APP. The column defaults to
-- 'user' and the registration endpoint never reads a role from the request
-- body, so an admin can only be created by `npm run admin:create`, which talks
-- to the database directly. Everything reachable over HTTP makes a plain user.
-- The CHECK is the last line of that defence: a bug that passed arbitrary text
-- through would fail on write rather than mint a role nobody audits.

CREATE TABLE users (
    id            bigserial PRIMARY KEY,
    email         text,
    phone         text,
    password_hash text        NOT NULL,
    role          text        NOT NULL DEFAULT 'user',
    created_at    timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT users_role_valid
        CHECK (role IN ('user', 'admin')),

    -- An account with neither identifier could never sign in again.
    CONSTRAINT users_identifier_present
        CHECK (email IS NOT NULL OR phone IS NOT NULL)
);

CREATE UNIQUE INDEX users_email_lower_unique
    ON users (lower(email))
    WHERE email IS NOT NULL;

CREATE UNIQUE INDEX users_phone_unique
    ON users (phone)
    WHERE phone IS NOT NULL;

-- Login looks an account up by one identifier or the other; both lookups are
-- served by the unique indexes above, so no extra index is needed.
