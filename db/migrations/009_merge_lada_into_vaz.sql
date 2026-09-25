-- Migration 009: merge the duplicate «Lada» make into «ВАЗ»
--
-- Why: the catalogue carried the same manufacturer twice — «ВАЗ» (id 1, with
-- Гранта / Нива / Приора / 2107 / 2110 and all 15 part fitments) and «Lada»
-- (id 2, with Granta / Niva / Vesta and no fitments). A person looking for
-- Lada parts saw two brands and had no way to tell which one held the stock;
-- picking «Lada» led to a search that could never match a fitment.
--
-- ВАЗ is kept because every fitment already points at it. Lada's three models
-- are dropped rather than reparented: Granta and Niva are the same cars as
-- Гранта and Нива, and Vesta arrives as «Веста» with the rest of the ВАЗ
-- lineup in migration 010. Carrying the Latin spellings across would have
-- rebuilt the very duplication this migration exists to remove, one level
-- down — «Vesta» and «Веста» side by side in the same model list.
--
-- Idempotent: each statement is scoped by name and no-ops once «Lada» is gone.

-- ---------------------------------------------------------------------------
-- 1. Drop everything under «Lada» — generations first, they reference the
--    models by foreign key.
-- ---------------------------------------------------------------------------
DELETE FROM car_generations
 WHERE model_id IN (
       SELECT id FROM car_models
        WHERE make_id = (SELECT id FROM car_makes WHERE name = 'Lada')
 );

DELETE FROM car_models
 WHERE make_id = (SELECT id FROM car_makes WHERE name = 'Lada');

-- ---------------------------------------------------------------------------
-- 2. Remove the duplicate make itself.
-- ---------------------------------------------------------------------------
DELETE FROM car_makes WHERE name = 'Lada';
