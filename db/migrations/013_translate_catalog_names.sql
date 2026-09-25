-- Migration 013: Armenian and English names for the catalogue's own vocabulary
--
-- Why: switching the app to Armenian translated the chrome but left the lists
-- themselves in Russian — «Двигатель и КПП» sitting under an Armenian heading.
-- Those strings come from the database, which held exactly one spelling each.
--
-- Only the product's OWN vocabulary is translated here: part categories,
-- service categories, and the generation labels the seed invented. Makes,
-- models and vendor names are proper nouns and stay as they are — «Toyota» is
-- «Toyota» in every locale, and translating a shop's name would be wrong.
--
-- Columns rather than a separate translations table: the vocabulary is 17 rows
-- across three fixed locales, and a join table would add a query for nothing.
-- The new columns are nullable and the API falls back to `name`, so a category
-- added later still appears — untranslated rather than missing.

ALTER TABLE part_categories    ADD COLUMN name_hy text, ADD COLUMN name_en text;
ALTER TABLE service_categories ADD COLUMN name_hy text, ADD COLUMN name_en text;
ALTER TABLE car_generations    ADD COLUMN name_hy text, ADD COLUMN name_en text;

-- ---------------------------------------------------------------------------
-- Part categories
-- ---------------------------------------------------------------------------
UPDATE part_categories SET name_hy = t.hy, name_en = t.en
FROM (VALUES
    ('Тормоза',          'Արգելակներ',               'Brakes'),
    ('Двигатель',        'Շարժիչ',                   'Engine'),
    ('Подвеска',         'Կախոց',                    'Suspension'),
    ('Фильтры',          'Զտիչներ',                  'Filters'),
    ('Электрика',        'Էլեկտրասարքավորում',       'Electrics'),
    ('Трансмиссия',      'Փոխանցատուփ',              'Transmission'),
    ('Масла и жидкости', 'Յուղեր և հեղուկներ',       'Oils and fluids'),
    ('Шины и диски',     'Անվադողեր և սկավառակներ',  'Tyres and wheels')
) AS t (ru, hy, en)
WHERE part_categories.name = t.ru;

-- ---------------------------------------------------------------------------
-- Service categories
-- ---------------------------------------------------------------------------
UPDATE service_categories SET name_hy = t.hy, name_en = t.en
FROM (VALUES
    ('Замена масла',                  'Յուղի փոխարինում',                  'Oil change'),
    ('Развал-схождение',              'Անիվների հավասարեցում',             'Wheel alignment'),
    ('Диагностика',                   'Ախտորոշում',                        'Diagnostics'),
    ('Шиномонтаж',                    'Անվադողերի մոնտաժ',                 'Tyre fitting'),
    ('Тормоза',                       'Արգելակներ',                        'Brakes'),
    ('Подвеска и рулевое',            'Կախոց և ղեկային համակարգ',          'Suspension and steering'),
    ('Электрика и электроника',       'Էլեկտրասարքավորում և էլեկտրոնիկա',  'Electrics and electronics'),
    ('Двигатель и КПП',               'Շարժիչ և փոխանցատուփ',              'Engine and gearbox'),
    ('ТО (техническое обслуживание)', 'Տեխնիկական սպասարկում',             'Servicing')
) AS t (ru, hy, en)
WHERE service_categories.name = t.ru;

-- ---------------------------------------------------------------------------
-- Generations
--
-- The seed labelled these «I поколение» / «Первое поколение» rather than with
-- real factory codes, so only the word «поколение» carries meaning and can be
-- swapped. Rows already holding a genuine code (XV70) contain no Russian and
-- are left untouched by both statements.
-- ---------------------------------------------------------------------------
UPDATE car_generations
   SET name_hy = replace(name, 'поколение', 'սերունդ'),
       name_en = replace(name, 'поколение', 'generation')
 WHERE name LIKE '%поколение%';

UPDATE car_generations
   SET name_hy = 'Առաջին սերունդ',
       name_en = 'First generation'
 WHERE name = 'Первое поколение';
