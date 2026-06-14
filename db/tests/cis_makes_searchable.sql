-- cis_makes_searchable.sql
-- Assert that CIS makes (ВАЗ/Lada, ГАЗ, УАЗ) are present and ILIKE-searchable in car_makes.
-- Run with: psql -v ON_ERROR_STOP=1 -f db/tests/cis_makes_searchable.sql
-- Raises an exception (and exits with non-zero) if any assertion fails.

DO $$
DECLARE
  v_count integer;
BEGIN

  -- ВАЗ exact
  SELECT count(*) INTO v_count FROM car_makes WHERE name = 'ВАЗ';
  IF v_count = 0 THEN
    RAISE EXCEPTION 'ASSERTION FAILED: car_makes has no row with name = ''ВАЗ''';
  END IF;

  -- Lada exact
  SELECT count(*) INTO v_count FROM car_makes WHERE name = 'Lada';
  IF v_count = 0 THEN
    RAISE EXCEPTION 'ASSERTION FAILED: car_makes has no row with name = ''Lada''';
  END IF;

  -- ГАЗ exact
  SELECT count(*) INTO v_count FROM car_makes WHERE name = 'ГАЗ';
  IF v_count = 0 THEN
    RAISE EXCEPTION 'ASSERTION FAILED: car_makes has no row with name = ''ГАЗ''';
  END IF;

  -- УАЗ exact
  SELECT count(*) INTO v_count FROM car_makes WHERE name = 'УАЗ';
  IF v_count = 0 THEN
    RAISE EXCEPTION 'ASSERTION FAILED: car_makes has no row with name = ''УАЗ''';
  END IF;

  -- ILIKE searchability: %ВАЗ%
  SELECT count(*) INTO v_count FROM car_makes WHERE name ILIKE '%ВАЗ%';
  IF v_count = 0 THEN
    RAISE EXCEPTION 'ASSERTION FAILED: ILIKE ''%%ВАЗ%%'' returned no rows from car_makes';
  END IF;

  -- ILIKE searchability: %Lada%
  SELECT count(*) INTO v_count FROM car_makes WHERE name ILIKE '%Lada%';
  IF v_count = 0 THEN
    RAISE EXCEPTION 'ASSERTION FAILED: ILIKE ''%%Lada%%'' returned no rows from car_makes';
  END IF;

  -- ILIKE searchability: %ГАЗ%
  SELECT count(*) INTO v_count FROM car_makes WHERE name ILIKE '%ГАЗ%';
  IF v_count = 0 THEN
    RAISE EXCEPTION 'ASSERTION FAILED: ILIKE ''%%ГАЗ%%'' returned no rows from car_makes';
  END IF;

  -- ILIKE searchability: %УАЗ%
  SELECT count(*) INTO v_count FROM car_makes WHERE name ILIKE '%УАЗ%';
  IF v_count = 0 THEN
    RAISE EXCEPTION 'ASSERTION FAILED: ILIKE ''%%УАЗ%%'' returned no rows from car_makes';
  END IF;

  -- Whole-make fitment for ВАЗ exists (model_id IS NULL)
  SELECT count(*) INTO v_count
  FROM part_fitments pf
  JOIN car_makes mk ON mk.id = pf.make_id
  WHERE mk.name = 'ВАЗ' AND pf.model_id IS NULL;
  IF v_count = 0 THEN
    RAISE EXCEPTION 'ASSERTION FAILED: no whole-make fitment (model_id IS NULL) found for ВАЗ in part_fitments';
  END IF;

  RAISE NOTICE 'ALL ASSERTIONS PASSED: ВАЗ, Lada, ГАЗ, УАЗ present and ILIKE-searchable; whole-make ВАЗ fitment exists.';
END;
$$;
