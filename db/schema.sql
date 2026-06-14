-- =============================================================================
-- db/schema.sql — Consolidated schema snapshot (source-of-truth documentation)
-- Generated from migrations 001 + 002.
-- This file is NOT run by node-pg-migrate. It is a human-readable reference.
-- Run `npm run migrate:up` (from backend/) to apply migrations to the DB.
-- =============================================================================

-- Extensions (001_extensions.sql)
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ---------------------------------------------------------------------------
-- Vendors (parts shops and repair shops)
-- ---------------------------------------------------------------------------
CREATE TABLE vendors (
    id          bigserial PRIMARY KEY,
    name        text        NOT NULL,
    type        text        NOT NULL CHECK (type IN ('parts_shop', 'repair_shop')),
    phone       text,
    address     text,
    location    geography(Point, 4326) NOT NULL,
    rating      numeric(3, 2) DEFAULT 0,
    is_verified boolean     NOT NULL DEFAULT false,
    hours       jsonb,
    created_at  timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- Car catalogue
-- ---------------------------------------------------------------------------
CREATE TABLE car_makes (
    id   bigserial PRIMARY KEY,
    name text NOT NULL
);

CREATE TABLE car_models (
    id      bigserial PRIMARY KEY,
    make_id bigint NOT NULL REFERENCES car_makes (id),
    name    text   NOT NULL
);

CREATE TABLE car_generations (
    id        bigserial PRIMARY KEY,
    model_id  bigint  NOT NULL REFERENCES car_models (id),
    name      text    NOT NULL,
    year_from integer,
    year_to   integer
);

-- ---------------------------------------------------------------------------
-- Part categories (tree)
-- ---------------------------------------------------------------------------
CREATE TABLE part_categories (
    id        bigserial PRIMARY KEY,
    parent_id bigint REFERENCES part_categories (id),
    name      text NOT NULL
);

-- ---------------------------------------------------------------------------
-- Parts
-- ---------------------------------------------------------------------------
CREATE TABLE parts (
    id          bigserial PRIMARY KEY,
    vendor_id   bigint  NOT NULL REFERENCES vendors (id),
    category_id bigint  REFERENCES part_categories (id),
    title       text    NOT NULL,
    brand       text,
    oem_number  text,
    price       numeric(12, 2),
    currency    text    NOT NULL DEFAULT 'AMD',
    in_stock    boolean NOT NULL DEFAULT true,
    photos      text[]  NOT NULL DEFAULT '{}'
);

-- ---------------------------------------------------------------------------
-- Part fitments (vendor-declared compatibility)
-- model_id IS NULL      → applies to all models of the make
-- generation_id IS NULL → applies to all generations
-- make_id IS NOT NULL enforced by both column constraint and explicit CHECK
-- ---------------------------------------------------------------------------
CREATE TABLE part_fitments (
    id            bigserial PRIMARY KEY,
    part_id       bigint NOT NULL REFERENCES parts (id),
    make_id       bigint NOT NULL REFERENCES car_makes (id),
    model_id      bigint REFERENCES car_models (id),      -- NULL = all models
    generation_id bigint REFERENCES car_generations (id), -- NULL = all generations
    CONSTRAINT part_fitments_make_required CHECK (make_id IS NOT NULL)
);

-- ---------------------------------------------------------------------------
-- Service categories
-- ---------------------------------------------------------------------------
CREATE TABLE service_categories (
    id   bigserial PRIMARY KEY,
    name text NOT NULL
);

-- ---------------------------------------------------------------------------
-- Vendor services
-- ---------------------------------------------------------------------------
CREATE TABLE vendor_services (
    id                  bigserial PRIMARY KEY,
    vendor_id           bigint NOT NULL REFERENCES vendors (id),
    service_category_id bigint NOT NULL REFERENCES service_categories (id),
    price_from          numeric(12, 2),
    price_to            numeric(12, 2)
);

-- ---------------------------------------------------------------------------
-- Indexes (FND-03)
-- ---------------------------------------------------------------------------
CREATE INDEX vendors_location_gist              ON vendors        USING GIST (location);
CREATE INDEX parts_title_gin                    ON parts          USING GIN  (title gin_trgm_ops);
CREATE INDEX parts_oem_number_btree             ON parts          (oem_number);
CREATE INDEX parts_vendor_id_btree              ON parts          (vendor_id);
CREATE INDEX parts_category_id_btree            ON parts          (category_id);
CREATE INDEX part_fitments_part_id_btree        ON part_fitments  (part_id);
CREATE INDEX part_fitments_make_id_btree        ON part_fitments  (make_id);
CREATE INDEX part_fitments_model_id_btree       ON part_fitments  (model_id);
CREATE INDEX part_fitments_generation_id_btree  ON part_fitments  (generation_id);
CREATE INDEX car_models_make_id_btree           ON car_models     (make_id);
CREATE INDEX car_generations_model_id_btree     ON car_generations (model_id);
CREATE INDEX part_categories_parent_id_btree    ON part_categories (parent_id);
CREATE INDEX vendor_services_vendor_id_btree           ON vendor_services (vendor_id);
CREATE INDEX vendor_services_service_category_id_btree ON vendor_services (service_category_id);
