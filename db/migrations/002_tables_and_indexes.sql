-- Migration 002: Geo-search tables and required indexes
-- Scope: ONLY geo-search tables (D-01). No users/inquiries/reviews/favorites/user_cars (D-02).
-- Coordinate convention: geography stored via ST_SetSRID(ST_MakePoint(lng, lat), 4326) — longitude first.

-- ---------------------------------------------------------------------------
-- Vendor (parts shops and repair shops)
-- ---------------------------------------------------------------------------
CREATE TABLE vendors (
    id            bigserial PRIMARY KEY,
    name          text        NOT NULL,
    type          text        NOT NULL CHECK (type IN ('parts_shop', 'repair_shop')),
    phone         text,
    address       text,
    location      geography(Point, 4326) NOT NULL,
    rating        numeric(3, 2) DEFAULT 0,
    is_verified   boolean     NOT NULL DEFAULT false,
    hours         jsonb,
    created_at    timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- Car catalogue: makes → models → generations
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
-- Part categories (self-referential tree)
-- ---------------------------------------------------------------------------
CREATE TABLE part_categories (
    id        bigserial PRIMARY KEY,
    parent_id bigint REFERENCES part_categories (id),
    name      text NOT NULL
);

-- ---------------------------------------------------------------------------
-- Parts (products listed by a vendor)
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
-- Part fitments — compatibility declared by the vendor
-- NULL model_id  = applies to all models of the make
-- NULL generation_id = applies to all generations of the model (or make)
-- ---------------------------------------------------------------------------
CREATE TABLE part_fitments (
    id             bigserial PRIMARY KEY,
    part_id        bigint NOT NULL REFERENCES parts (id),
    make_id        bigint NOT NULL REFERENCES car_makes (id),  -- CHECK: make_id IS NOT NULL (enforced by NOT NULL constraint)
    model_id       bigint REFERENCES car_models (id),           -- NULL = applies to all models of the make
    generation_id  bigint REFERENCES car_generations (id),      -- NULL = applies to all generations
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
-- Vendor services (which services a repair shop offers)
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

-- Spatial index on vendors.location — MUST use USING GIST for geography type
CREATE INDEX vendors_location_gist ON vendors USING GIST (location);

-- Full-text trigram search on parts.title
CREATE INDEX parts_title_gin ON parts USING GIN (title gin_trgm_ops);

-- Lookup by OEM/article number
CREATE INDEX parts_oem_number_btree ON parts (oem_number);

-- FK and filter indexes on parts
CREATE INDEX parts_vendor_id_btree    ON parts (vendor_id);
CREATE INDEX parts_category_id_btree  ON parts (category_id);

-- FK indexes on part_fitments
CREATE INDEX part_fitments_part_id_btree       ON part_fitments (part_id);
CREATE INDEX part_fitments_make_id_btree       ON part_fitments (make_id);
CREATE INDEX part_fitments_model_id_btree      ON part_fitments (model_id);
CREATE INDEX part_fitments_generation_id_btree ON part_fitments (generation_id);

-- FK indexes on car catalogue
CREATE INDEX car_models_make_id_btree       ON car_models (make_id);
CREATE INDEX car_generations_model_id_btree ON car_generations (model_id);

-- FK index on part_categories tree
CREATE INDEX part_categories_parent_id_btree ON part_categories (parent_id);

-- FK indexes on vendor_services
CREATE INDEX vendor_services_vendor_id_btree           ON vendor_services (vendor_id);
CREATE INDEX vendor_services_service_category_id_btree ON vendor_services (service_category_id);
