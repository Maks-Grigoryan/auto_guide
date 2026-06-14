-- coordinate_smoke.sql
-- Success criterion #5: a point stored as ST_MakePoint(lng, lat) round-trips correctly.
-- Asserts: ST_AsText(location) = 'POINT(44.5152 40.1872)' (lng first in WKT output).
-- Run via: psql -v ON_ERROR_STOP=1 -f coordinate_smoke.sql
-- Exits non-zero on failure (RAISE EXCEPTION propagates to psql exit code).

DO $$
DECLARE
    v_id      bigint;
    v_wkt     text;
    v_lat     double precision;
    v_lng     double precision;
    expected_wkt text := 'POINT(44.5152 40.1872)';
BEGIN
    -- Insert a temporary test vendor at Yerevan (lng=44.5152, lat=40.1872)
    INSERT INTO vendors (name, type, phone, address, location)
    VALUES (
        '_smoke_coord_test',
        'parts_shop',
        NULL,
        'Yerevan test',
        ST_SetSRID(ST_MakePoint(44.5152, 40.1872), 4326)
    )
    RETURNING id INTO v_id;

    -- Round-trip: read back as WKT
    SELECT ST_AsText(location)
    INTO v_wkt
    FROM vendors
    WHERE id = v_id;

    -- Assert WKT matches expected (longitude first per PostGIS convention)
    IF v_wkt IS DISTINCT FROM expected_wkt THEN
        RAISE EXCEPTION 'COORDINATE ORDER FAIL: expected % but got %', expected_wkt, v_wkt;
    END IF;

    -- Also verify ST_Y = lat and ST_X = lng
    SELECT ST_Y(location::geometry), ST_X(location::geometry)
    INTO v_lat, v_lng
    FROM vendors
    WHERE id = v_id;

    IF abs(v_lat - 40.1872) > 0.000001 THEN
        RAISE EXCEPTION 'LAT FAIL: expected 40.1872 but got %', v_lat;
    END IF;

    IF abs(v_lng - 44.5152) > 0.000001 THEN
        RAISE EXCEPTION 'LNG FAIL: expected 44.5152 but got %', v_lng;
    END IF;

    RAISE NOTICE 'coordinate_smoke: PASS — stored point round-trips to %', v_wkt;

    -- Clean up
    DELETE FROM vendors WHERE id = v_id;
END
$$;
