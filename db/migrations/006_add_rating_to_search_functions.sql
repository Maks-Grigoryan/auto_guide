-- Migration 006: Add rating column to search_parts and search_repair return types
-- Replaces 003's search_repair and 005's search_parts with updated versions that
-- expose vendors.rating in the result set, enabling client-side sort-by-rating (RES-04).
-- Does NOT edit 003 or 005 (node-pg-migrate will not re-run applied migrations).
--
-- Critical rules preserved (PITFALLS #1, #2):
--   #1  Coordinate order: ST_MakePoint(p_lng, p_lat) — longitude first
--   #2  Use ST_DWithin in WHERE (index-accelerated); ST_Distance ONLY in SELECT

-- ---------------------------------------------------------------------------
-- search_parts (updated: rating column added)
-- Copy of migration 005 definition with two edits:
--   1. RETURNS TABLE: added `rating numeric` after `min_price`
--   2. SELECT list: added `v.rating AS rating` after `MIN(p.price) AS min_price`
--   3. GROUP BY: added `v.rating`
-- ---------------------------------------------------------------------------
-- PostgreSQL cannot change a function's OUT row type with CREATE OR REPLACE.
-- This migration has not shipped before the rating column is introduced, so
-- dropping and recreating the exact signature is the safe, atomic operation.
DROP FUNCTION IF EXISTS search_parts(
    double precision, double precision, integer,
    bigint, bigint, bigint, bigint, text
);

CREATE OR REPLACE FUNCTION search_parts(
    p_lat              double precision,
    p_lng              double precision,
    p_radius_m         integer,
    p_make_id          bigint   DEFAULT NULL,
    p_model_id         bigint   DEFAULT NULL,
    p_generation_id    bigint   DEFAULT NULL,
    p_category_id      bigint   DEFAULT NULL,
    p_query            text     DEFAULT NULL
)
RETURNS TABLE (
    vendor_id    bigint,
    name         text,
    type         text,
    phone        text,
    address      text,
    lat          double precision,
    lng          double precision,
    distance_m   double precision,
    item_count   bigint,
    min_price    numeric,
    rating       numeric
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        v.id                                                        AS vendor_id,
        v.name,
        v.type,
        v.phone,
        v.address,
        ST_Y(v.location::geometry)                                  AS lat,
        ST_X(v.location::geometry)                                  AS lng,
        ST_Distance(
            v.location,
            ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography
        )                                                           AS distance_m,
        COUNT(p.id)                                                 AS item_count,
        MIN(p.price)                                                AS min_price,
        v.rating                                                    AS rating
    FROM vendors v
    JOIN parts p ON p.vendor_id = v.id
    -- Fitment join: only applied when a make filter is requested
    JOIN part_fitments pf ON pf.part_id = p.id
    WHERE
        v.type = 'parts_shop'
        -- Spatial radius filter via GiST index (PITFALLS #2 — never ST_Distance here)
        AND ST_DWithin(
            v.location,
            ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography,
            p_radius_m
        )
        -- Car filter (only when make_id provided) — NULL-aware (PITFALLS #5)
        AND (
            p_make_id IS NULL
            OR (
                pf.make_id = p_make_id
                AND (p_model_id      IS NULL OR pf.model_id      IS NULL OR pf.model_id      = p_model_id)
                AND (p_generation_id IS NULL OR pf.generation_id IS NULL OR pf.generation_id = p_generation_id)
            )
        )
        -- Category filter
        AND (p_category_id IS NULL OR p.category_id = p_category_id)
        -- Text search: OEM normalized (strip spaces/dashes); title trigram
        AND (
            p_query IS NULL
            OR regexp_replace(p.oem_number, '[\s-]', '', 'g')
               ILIKE regexp_replace(p_query, '[\s-]', '', 'g')
            OR p.title % p_query
        )
        AND p.in_stock = true
    GROUP BY
        v.id, v.name, v.type, v.phone, v.address, v.location, v.rating
    ORDER BY
        distance_m
$$;

-- ---------------------------------------------------------------------------
-- search_repair (updated: rating column added)
-- Copy of migration 003 definition with two edits:
--   1. RETURNS TABLE: added `rating numeric` after `min_price`
--   2. SELECT list: added `v.rating AS rating` after `MIN(vs.price_from) AS min_price`
--   3. GROUP BY: added `v.rating`
-- ---------------------------------------------------------------------------
DROP FUNCTION IF EXISTS search_repair(
    double precision, double precision, integer, bigint
);

CREATE OR REPLACE FUNCTION search_repair(
    p_lat                  double precision,
    p_lng                  double precision,
    p_radius_m             integer,
    p_service_category_id  bigint DEFAULT NULL
)
RETURNS TABLE (
    vendor_id      bigint,
    name           text,
    phone          text,
    address        text,
    lat            double precision,
    lng            double precision,
    distance_m     double precision,
    service_count  bigint,
    min_price      numeric,
    rating         numeric
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        v.id                                                        AS vendor_id,
        v.name,
        v.phone,
        v.address,
        ST_Y(v.location::geometry)                                  AS lat,
        ST_X(v.location::geometry)                                  AS lng,
        ST_Distance(
            v.location,
            ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography
        )                                                           AS distance_m,
        COUNT(vs.id)                                                AS service_count,
        MIN(vs.price_from)                                          AS min_price,
        v.rating                                                    AS rating
    FROM vendors v
    JOIN vendor_services vs ON vs.vendor_id = v.id
    WHERE
        v.type = 'repair_shop'
        -- Spatial radius filter via GiST index (PITFALLS #2)
        AND ST_DWithin(
            v.location,
            ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography,
            p_radius_m
        )
        -- Optional service category filter
        AND (p_service_category_id IS NULL OR vs.service_category_id = p_service_category_id)
    GROUP BY
        v.id, v.name, v.phone, v.address, v.location, v.rating
    ORDER BY
        distance_m
$$;
