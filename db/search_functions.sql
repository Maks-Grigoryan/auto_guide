-- =============================================================================
-- db/search_functions.sql — Source-of-truth snapshot of geo-search functions
-- Generated from migration 003_search_functions.sql.
-- This file is NOT run by node-pg-migrate. It is a human-readable reference.
-- Run `npm run migrate:up` (from backend/) to apply to the DB.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- search_parts
-- Returns one row per vendor (parts_shop) within radius_m metres of (lat, lng).
-- Optional car filters applied via part_fitments with NULL-aware predicates.
-- Optional text query searches oem_number (ILIKE) and title (pg_trgm).
-- ---------------------------------------------------------------------------
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
    min_price    numeric
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
        MIN(p.price)                                                AS min_price
    FROM vendors v
    JOIN parts p ON p.vendor_id = v.id
    JOIN part_fitments pf ON pf.part_id = p.id
    WHERE
        v.type = 'parts_shop'
        AND ST_DWithin(
            v.location,
            ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography,
            p_radius_m
        )
        AND (
            p_make_id IS NULL
            OR (
                pf.make_id = p_make_id
                AND (p_model_id      IS NULL OR pf.model_id      IS NULL OR pf.model_id      = p_model_id)
                AND (p_generation_id IS NULL OR pf.generation_id IS NULL OR pf.generation_id = p_generation_id)
            )
        )
        AND (p_category_id IS NULL OR p.category_id = p_category_id)
        AND (
            p_query IS NULL
            OR p.oem_number ILIKE p_query
            OR p.title % p_query
        )
        AND p.in_stock = true
    GROUP BY
        v.id, v.name, v.type, v.phone, v.address, v.location
    ORDER BY
        distance_m
$$;

-- ---------------------------------------------------------------------------
-- search_repair
-- Returns one row per vendor (repair_shop) within radius_m metres of (lat, lng).
-- Optional service_category_id filter narrows to shops offering that service.
-- ---------------------------------------------------------------------------
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
    min_price      numeric
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
        MIN(vs.price_from)                                          AS min_price
    FROM vendors v
    JOIN vendor_services vs ON vs.vendor_id = v.id
    WHERE
        v.type = 'repair_shop'
        AND ST_DWithin(
            v.location,
            ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography,
            p_radius_m
        )
        AND (p_service_category_id IS NULL OR vs.service_category_id = p_service_category_id)
    GROUP BY
        v.id, v.name, v.phone, v.address, v.location
    ORDER BY
        distance_m
$$;
