-- Migration 012: rename users.email to users.login
--
-- Why: the column has never held only email addresses. Administrators sign in
-- as «admin», which the create-admin script writes straight into it, so a
-- column named `email` contains something that is not one — misleading to
-- anyone reading the schema, and a trap for whoever later wires up
-- password-reset mail and assumes every value there can be posted to.
--
-- Nothing is added: this is the same single identifier column under a name that
-- describes it. Registration still accepts only a real address here, so short
-- names like «admin» stay unclaimable by whoever signs up first.
--
-- Data is preserved — a rename does not rewrite rows.

ALTER TABLE users RENAME COLUMN email TO login;

-- The index survives a column rename but keeps its old name, which would be
-- the next misleading thing to read.
ALTER INDEX users_email_lower_unique RENAME TO users_login_lower_unique;

-- CHECK constraints store the column name inside their expression, so this one
-- has to be rebuilt rather than renamed.
ALTER TABLE users DROP CONSTRAINT users_identifier_present;

ALTER TABLE users ADD CONSTRAINT users_identifier_present
    CHECK (login IS NOT NULL OR phone IS NOT NULL);
