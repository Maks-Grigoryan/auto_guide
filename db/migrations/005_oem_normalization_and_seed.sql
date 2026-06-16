-- Migration 005: OEM normalization in search_parts + seed known-OEM part
-- Replaces 003's search_parts with an updated version that strips spaces/dashes
-- from both stored oem_number and the incoming p_query before comparison.
-- Does NOT edit 003 (node-pg-migrate will not re-run applied migrations).

-- ---------------------------------------------------------------------------
-- search_parts (updated: OEM branch normalized)
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
        v.id, v.name, v.type, v.phone, v.address, v.location
    ORDER BY
        distance_m
$$;

-- ---------------------------------------------------------------------------
-- Seed: one part with oem_number '19216' at vendor 'АвтоДетали Центр'
-- Idempotent: ON CONFLICT DO NOTHING (unique on vendor+oem+category not enforced,
-- so we guard by only inserting when that exact title does not yet exist).
-- ---------------------------------------------------------------------------
INSERT INTO parts (vendor_id, category_id, title, brand, oem_number, price, currency, in_stock)
SELECT v.id, pc.id, 'Тормозной цилиндр главный 19216', 'FENOX', '19216', 7200, 'AMD', true
FROM vendors v, part_categories pc
WHERE v.name = 'АвтоДетали Центр'
  AND pc.name = 'Тормоза'
  AND NOT EXISTS (
      SELECT 1 FROM parts p2
      WHERE p2.vendor_id = v.id
        AND p2.oem_number = '19216'
  );
