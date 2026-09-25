-- Migration 007: models and generations for every make
--
-- Why: the catalogue listed 18 makes but only ВАЗ, Toyota and Hyundai had any
-- models, so tapping any other make dead-ended on an empty screen. The car
-- selector cannot be completed without a model — SelectedCar requires one —
-- which meant 15 of 18 makes could not reach the home screen at all.
--
-- Idempotent: every insert is guarded by NOT EXISTS, so re-running is safe.

-- ---------------------------------------------------------------------------
-- Models
-- ---------------------------------------------------------------------------
INSERT INTO car_models (make_id, name)
SELECT mk.id, m.name
FROM (VALUES
    ('Audi',          'A4'),
    ('Audi',          'A6'),
    ('Audi',          'Q5'),
    ('Audi',          'Q7'),
    ('BMW',           '3 series'),
    ('BMW',           '5 series'),
    ('BMW',           'X5'),
    ('Ford',          'Focus'),
    ('Ford',          'Fusion'),
    ('Ford',          'Transit'),
    ('Honda',         'Civic'),
    ('Honda',         'Accord'),
    ('Honda',         'CR-V'),
    ('Kia',           'Rio'),
    ('Kia',           'Sportage'),
    ('Kia',           'Cerato'),
    ('Lada',          'Granta'),
    ('Lada',          'Vesta'),
    ('Lada',          'Niva'),
    ('Lexus',         'RX'),
    ('Lexus',         'ES'),
    ('Lexus',         'LX'),
    ('Mazda',         '3'),
    ('Mazda',         '6'),
    ('Mazda',         'CX-5'),
    ('Mercedes-Benz', 'C-Class'),
    ('Mercedes-Benz', 'E-Class'),
    ('Mercedes-Benz', 'GLE'),
    ('Mitsubishi',    'Lancer'),
    ('Mitsubishi',    'Outlander'),
    ('Mitsubishi',    'Pajero'),
    ('Nissan',        'Almera'),
    ('Nissan',        'Qashqai'),
    ('Nissan',        'X-Trail'),
    ('Subaru',        'Forester'),
    ('Subaru',        'Impreza'),
    ('Subaru',        'Outback'),
    ('Volkswagen',    'Golf'),
    ('Volkswagen',    'Passat'),
    ('Volkswagen',    'Tiguan'),
    ('ГАЗ',           'Газель'),
    ('ГАЗ',           'Волга'),
    ('ГАЗ',           'Соболь'),
    ('УАЗ',           'Патриот'),
    ('УАЗ',           'Хантер'),
    ('УАЗ',           'Буханка'),
    -- Fill out the three makes that already had a single model each.
    ('Toyota',        'Corolla'),
    ('Toyota',        'RAV4'),
    ('Toyota',        'Land Cruiser'),
    ('Hyundai',       'Elantra'),
    ('Hyundai',       'Santa Fe'),
    ('Hyundai',       'Sonata')
) AS m(make_name, name)
JOIN car_makes mk ON mk.name = m.make_name
WHERE NOT EXISTS (
    SELECT 1 FROM car_models existing
    WHERE existing.make_id = mk.id AND existing.name = m.name
);

-- ---------------------------------------------------------------------------
-- Generations
--
-- Two per model, so the third step of the selector is never empty either.
-- Deliberately generic ("I поколение") rather than invented factory codes:
-- a wrong code reads as authoritative and misleads, a neutral label does not.
-- ---------------------------------------------------------------------------
INSERT INTO car_generations (model_id, name, year_from, year_to)
SELECT cm.id, g.name, g.year_from, g.year_to
FROM car_models cm
CROSS JOIN (VALUES
    ('I поколение',  2005, 2014),
    ('II поколение', 2015, NULL::integer)
) AS g(name, year_from, year_to)
WHERE NOT EXISTS (
    SELECT 1 FROM car_generations existing
    WHERE existing.model_id = cm.id AND existing.name = g.name
);
