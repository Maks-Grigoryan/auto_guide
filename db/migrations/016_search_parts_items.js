/**
 * Migration 016: part-level geo search for the AI assistant.
 *
 * search_parts (003, redefined in 006) answers the screen's question — "which
 * shops near me have something for my car" — and groups by vendor to do it. The
 * assistant asks a different one: "which part do I recommend, and is it in
 * stock". Same geo and fitment logic, no GROUP BY, one row per part.
 *
 * Critical rules carried over verbatim from 003:
 *   #1  Coordinate order: ST_MakePoint(lng, lat) — longitude first
 *   #2  ST_DWithin in WHERE (index-accelerated); ST_Distance ONLY in SELECT
 *   #5  Fitment NULL semantics: (p_x IS NULL OR pf.x IS NULL OR pf.x = p_x)
 *   #9  OEM via ILIKE on the btree column; title via pg_trgm similarity
 *
 * p_limit and p_radius_m are clamped inside the function, not only in the DTO.
 * The caller here is a language model choosing its own arguments: the ceiling
 * has to live where it cannot be argued with.
 *
 * .js rather than .sql so that `down` works — see the header of 015.
 */

const SIGNATURE =
  'double precision, double precision, integer, bigint, bigint, bigint, bigint, text, integer';

exports.up = (pgm) => {
  pgm.sql(`
    CREATE OR REPLACE FUNCTION search_parts_items(
        p_lat              double precision,
        p_lng              double precision,
        p_radius_m         integer,
        p_make_id          bigint   DEFAULT NULL,
        p_model_id         bigint   DEFAULT NULL,
        p_generation_id    bigint   DEFAULT NULL,
        p_category_id      bigint   DEFAULT NULL,
        p_query            text     DEFAULT NULL,
        p_limit            integer  DEFAULT 20
    )
    RETURNS TABLE (
        part_id      bigint,
        title        text,
        brand        text,
        oem_number   text,
        price        numeric,
        in_stock     boolean,
        vendor_id    bigint,
        vendor_name  text,
        distance_m   double precision
    )
    LANGUAGE sql
    STABLE
    AS $fn$
        SELECT DISTINCT ON (p.id)
            p.id                                                    AS part_id,
            p.title,
            p.brand,
            p.oem_number,
            p.price,
            p.in_stock,
            v.id                                                    AS vendor_id,
            v.name                                                  AS vendor_name,
            ST_Distance(
                v.location,
                ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography
            )                                                       AS distance_m
        FROM parts p
        JOIN vendors v ON v.id = p.vendor_id
        -- LEFT JOIN, unlike search_parts: a part with no fitment rows is still
        -- a real part on a shelf. An inner join would hide the whole catalogue
        -- from the assistant whenever a vendor had not filled compatibility in.
        LEFT JOIN part_fitments pf ON pf.part_id = p.id
        WHERE
            v.type = 'parts_shop'
            AND ST_DWithin(
                v.location,
                ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography,
                LEAST(GREATEST(p_radius_m, 100), 50000)
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
        -- DISTINCT ON needs the deduplicated column first; distance decides
        -- which of several fitment rows for one part survives, and it is the
        -- same for all of them, so any is correct.
        ORDER BY p.id, distance_m
        LIMIT LEAST(GREATEST(p_limit, 1), 20)
    $fn$;
  `);

  pgm.sql(`
    COMMENT ON FUNCTION search_parts_items(${SIGNATURE}) IS
      'Part-level geo search for the AI assistant. Unlike search_parts it '
      'returns individual parts with price and stock instead of vendors with '
      'counts. p_limit is clamped to 20 and p_radius_m to 50 km inside the '
      'function.';
  `);
};

exports.down = (pgm) => {
  pgm.sql(`DROP FUNCTION IF EXISTS search_parts_items(${SIGNATURE});`);
};
