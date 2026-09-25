/**
 * Migration 018: filter parts by year of manufacture.
 *
 * The selector now lets someone give a year instead of a generation, which is
 * the only thing they can give for the many makes in this catalogue that have
 * no generation rows at all. Until now that year went no further than the chip
 * on the home screen.
 *
 * HOW THE YEAR FILTERS: a fitment row points at a generation, and a generation
 * carries year_from/year_to. A part is offered for a given year when
 *
 *   - the fitment names no generation (it fits the whole model), or
 *   - the named generation's range covers that year.
 *
 * Open-ended ranges count: year_to IS NULL means "still in production", and a
 * generation with no year_from at all is not evidence against a match — it is
 * missing data, and excluding on missing data would quietly hide real parts.
 *
 * The year only ever narrows: passing NULL leaves every query behaving exactly
 * as before, which is what makes this safe to apply ahead of the clients that
 * will start sending it.
 *
 * A generation and a year can both arrive. They are ANDed rather than ranked —
 * a generation that does not cover the stated year is a contradiction, and
 * returning nothing is the honest answer to it.
 *
 * .js rather than .sql so `down` works — see the header of 015.
 */

const PARTS_SIGNATURE_OLD =
  'double precision, double precision, integer, bigint, bigint, bigint, bigint, text';
const PARTS_SIGNATURE_NEW = `${PARTS_SIGNATURE_OLD}, integer`;

const ITEMS_SIGNATURE_OLD =
  'double precision, double precision, integer, bigint, bigint, bigint, bigint, text, integer';
const ITEMS_SIGNATURE_NEW = `${ITEMS_SIGNATURE_OLD}, integer`;

/**
 * Shared year predicate. `pf` is the part_fitments alias.
 *
 * EXISTS rather than a join to car_generations: a join would multiply rows and
 * quietly change the COUNT that search_parts reports as item_count.
 */
const YEAR_PREDICATE = `
            AND (
                p_year IS NULL
                OR pf.generation_id IS NULL
                OR EXISTS (
                    SELECT 1
                      FROM car_generations g
                     WHERE g.id = pf.generation_id
                       AND (g.year_from IS NULL OR g.year_from <= p_year)
                       AND (g.year_to   IS NULL OR g.year_to   >= p_year)
                )
            )`;

exports.up = (pgm) => {
  // PostgreSQL will not add a parameter to an existing function through
  // CREATE OR REPLACE — it would create an overload, and a call with the old
  // eight arguments would then be ambiguous. Drop, then recreate.
  pgm.sql(`DROP FUNCTION IF EXISTS search_parts(${PARTS_SIGNATURE_OLD});`);

  pgm.sql(`
    CREATE FUNCTION search_parts(
        p_lat              double precision,
        p_lng              double precision,
        p_radius_m         integer,
        p_make_id          bigint   DEFAULT NULL,
        p_model_id         bigint   DEFAULT NULL,
        p_generation_id    bigint   DEFAULT NULL,
        p_category_id      bigint   DEFAULT NULL,
        p_query            text     DEFAULT NULL,
        p_year             integer  DEFAULT NULL
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
    AS $fn$
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
            )${YEAR_PREDICATE}
            AND (p_category_id IS NULL OR p.category_id = p_category_id)
            AND (
                p_query IS NULL
                OR regexp_replace(p.oem_number, '[\\s-]', '', 'g')
                   ILIKE regexp_replace(p_query, '[\\s-]', '', 'g')
                OR p.title % p_query
            )
            AND p.in_stock = true
        GROUP BY
            v.id, v.name, v.type, v.phone, v.address, v.location, v.rating
        ORDER BY
            distance_m
    $fn$;
  `);

  // The assistant's part-level search gets the same treatment: it reads the
  // same catalogue and would otherwise recommend parts for the wrong year.
  pgm.sql(`DROP FUNCTION IF EXISTS search_parts_items(${ITEMS_SIGNATURE_OLD});`);

  pgm.sql(`
    CREATE FUNCTION search_parts_items(
        p_lat              double precision,
        p_lng              double precision,
        p_radius_m         integer,
        p_make_id          bigint   DEFAULT NULL,
        p_model_id         bigint   DEFAULT NULL,
        p_generation_id    bigint   DEFAULT NULL,
        p_category_id      bigint   DEFAULT NULL,
        p_query            text     DEFAULT NULL,
        p_limit            integer  DEFAULT 20,
        p_year             integer  DEFAULT NULL
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
            )${YEAR_PREDICATE}
            AND (p_category_id IS NULL OR p.category_id = p_category_id)
            AND (
                p_query IS NULL
                OR p.oem_number ILIKE p_query
                OR p.title % p_query
            )
        ORDER BY p.id, distance_m
        LIMIT LEAST(GREATEST(p_limit, 1), 20)
    $fn$;
  `);
};

exports.down = (pgm) => {
  // Restore both functions exactly as 006 and 016 left them.
  pgm.sql(`DROP FUNCTION IF EXISTS search_parts(${PARTS_SIGNATURE_NEW});`);
  pgm.sql(`DROP FUNCTION IF EXISTS search_parts_items(${ITEMS_SIGNATURE_NEW});`);

  pgm.sql(`
    CREATE FUNCTION search_parts(
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
    AS $fn$
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
                OR regexp_replace(p.oem_number, '[\\s-]', '', 'g')
                   ILIKE regexp_replace(p_query, '[\\s-]', '', 'g')
                OR p.title % p_query
            )
            AND p.in_stock = true
        GROUP BY
            v.id, v.name, v.type, v.phone, v.address, v.location, v.rating
        ORDER BY
            distance_m
    $fn$;
  `);

  pgm.sql(`
    CREATE FUNCTION search_parts_items(
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
        ORDER BY p.id, distance_m
        LIMIT LEAST(GREATEST(p_limit, 1), 20)
    $fn$;
  `);
};
