-- fitment_null.sql
-- Success criterion: a whole-make fitment (model_id IS NULL) appears in a
-- model-specific search_parts call (PITFALLS #5).
-- Run via: psql -v ON_ERROR_STOP=1 -f fitment_null.sql
-- Exits non-zero on failure (RAISE EXCEPTION propagates to psql exit code).

DO $$
DECLARE
    v_make_id     bigint;
    v_model_id    bigint;
    v_vendor_id   bigint;
    v_part_id     bigint;
    v_row_count   integer;
BEGIN
    -- Seed: car make + model
    INSERT INTO car_makes (name) VALUES ('_smoke_make') RETURNING id INTO v_make_id;
    INSERT INTO car_models (make_id, name) VALUES (v_make_id, '_smoke_model') RETURNING id INTO v_model_id;

    -- Seed: parts_shop vendor near Yerevan
    INSERT INTO vendors (name, type, phone, address, location)
    VALUES (
        '_smoke_fitment_vendor',
        'parts_shop',
        NULL,
        'Yerevan test',
        ST_SetSRID(ST_MakePoint(44.5152, 40.1872), 4326)
    )
    RETURNING id INTO v_vendor_id;

    -- Seed: a part listed by that vendor
    INSERT INTO parts (vendor_id, title, price, in_stock)
    VALUES (v_vendor_id, '_smoke_part', 5000, true)
    RETURNING id INTO v_part_id;

    -- Seed: fitment with make_id set but model_id IS NULL (whole-make compatibility)
    INSERT INTO part_fitments (part_id, make_id, model_id, generation_id)
    VALUES (v_part_id, v_make_id, NULL, NULL);

    -- Call search_parts with that make_id AND a specific model_id
    -- The whole-make fitment (model_id IS NULL) MUST appear in the results
    SELECT COUNT(*)::integer INTO v_row_count
    FROM search_parts(
        40.1872,       -- lat
        44.5152,       -- lng
        100000,        -- radius_m (100 km to ensure vendor is included)
        v_make_id,     -- p_make_id
        v_model_id,    -- p_model_id (specific model — NULL fitment must still match)
        NULL,          -- p_generation_id
        NULL,          -- p_category_id
        NULL           -- p_query
    )
    WHERE vendor_id = v_vendor_id;

    IF v_row_count = 0 THEN
        RAISE EXCEPTION 'FITMENT_NULL FAIL: whole-make fitment (model_id IS NULL) did not appear in model-specific search. Check (model_id IS NULL OR model_id = p_model_id) predicate in search_parts.';
    END IF;

    RAISE NOTICE 'fitment_null: PASS — whole-make fitment returned % vendor row(s) for model-specific search', v_row_count;

    -- Clean up (reverse FK order)
    DELETE FROM part_fitments WHERE part_id = v_part_id;
    DELETE FROM parts WHERE id = v_part_id;
    DELETE FROM vendors WHERE id = v_vendor_id;
    DELETE FROM car_models WHERE id = v_model_id;
    DELETE FROM car_makes WHERE id = v_make_id;
END
$$;
