-- Migration 014: registrations awaiting a confirmation code
--
-- Why a separate table rather than an `is_verified` flag on users: an
-- unverified row in `users` would occupy the unique index for that phone or
-- address, so anyone could claim an identifier they do not own and keep the
-- real owner from ever registering. Here an unclaimed attempt simply expires,
-- and `users` only ever holds accounts somebody proved they can receive mail
-- or messages at.
--
-- The code is stored hashed, with the same scrypt helper as passwords. For the
-- few minutes it lives it is a credential: anyone who read this table with the
-- codes in clear could finish someone else's registration.

CREATE TABLE pending_registrations (
    id            bigserial   PRIMARY KEY,
    login         text,
    phone         text,
    password_hash text        NOT NULL,
    code_hash     text        NOT NULL,

    -- Guards against sitting on one pending row and trying all million codes.
    attempts      integer     NOT NULL DEFAULT 0,

    expires_at    timestamptz NOT NULL,
    created_at    timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT pending_registrations_identifier_present
        CHECK (login IS NOT NULL OR phone IS NOT NULL)
);

-- One pending attempt per identifier: asking for a code again replaces the
-- previous attempt rather than leaving several valid codes alive at once.
CREATE UNIQUE INDEX pending_registrations_login_unique
    ON pending_registrations (lower(login))
    WHERE login IS NOT NULL;

CREATE UNIQUE INDEX pending_registrations_phone_unique
    ON pending_registrations (phone)
    WHERE phone IS NOT NULL;

-- Expired rows are swept opportunistically on each new attempt; the index
-- keeps that from turning into a full scan as the table grows.
CREATE INDEX pending_registrations_expires_at_btree
    ON pending_registrations (expires_at);
