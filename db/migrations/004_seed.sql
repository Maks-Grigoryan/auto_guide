-- Migration 004: Seed data — Yerevan vendors, parts, fitments, services
-- Prerequisites: Run `node scripts/import_catalog.mjs` first to populate
--   car_makes / car_models / car_generations / part_categories / service_categories.
-- Coordinate convention: ST_SetSRID(ST_MakePoint(lng, lat), 4326) — longitude first (PITFALLS #1).
-- All amounts in AMD. Vendors jittered within ~5 km of Yerevan center (lat 40.1872, lng 44.5152).

-- ---------------------------------------------------------------------------
-- Catalog bootstrap (inline minimal catalog so migration is self-contained
-- even without running import_catalog.mjs first).
-- import_catalog.mjs is the canonical source; this ensures the migration
-- applies cleanly in CI or a fresh Docker environment.
-- ---------------------------------------------------------------------------

-- CIS makes
INSERT INTO car_makes (name) VALUES
  ('ВАЗ'), ('Lada'), ('ГАЗ'), ('УАЗ'),
  ('Toyota'), ('Hyundai'), ('Kia'), ('Mercedes-Benz'), ('BMW'),
  ('Volkswagen'), ('Nissan'), ('Honda'), ('Mitsubishi'), ('Lexus'),
  ('Ford'), ('Mazda'), ('Audi'), ('Subaru')
ON CONFLICT DO NOTHING;

-- Key models for ВАЗ (used in fitments)
INSERT INTO car_models (make_id, name)
SELECT id, m.name FROM car_makes, (VALUES
  ('Приора'), ('Гранта'), ('Нива'), ('2107'), ('2110')
) AS m(name) WHERE car_makes.name = 'ВАЗ'
ON CONFLICT DO NOTHING;

-- Generation for Приора
INSERT INTO car_generations (model_id, name, year_from, year_to)
SELECT cm.id, 'Первое поколение', 2007, 2018
FROM car_models cm JOIN car_makes mk ON mk.id = cm.make_id
WHERE mk.name = 'ВАЗ' AND cm.name = 'Приора'
ON CONFLICT DO NOTHING;

INSERT INTO car_generations (model_id, name, year_from, year_to)
SELECT cm.id, 'Первое поколение', 2011, 2024
FROM car_models cm JOIN car_makes mk ON mk.id = cm.make_id
WHERE mk.name = 'ВАЗ' AND cm.name = 'Гранта'
ON CONFLICT DO NOTHING;

-- Toyota Camry
INSERT INTO car_models (make_id, name)
SELECT id, 'Camry' FROM car_makes WHERE name = 'Toyota'
ON CONFLICT DO NOTHING;

INSERT INTO car_generations (model_id, name, year_from, year_to)
SELECT cm.id, 'XV70', 2017, 2024
FROM car_models cm JOIN car_makes mk ON mk.id = cm.make_id
WHERE mk.name = 'Toyota' AND cm.name = 'Camry'
ON CONFLICT DO NOTHING;

-- Hyundai Tucson
INSERT INTO car_models (make_id, name)
SELECT id, 'Tucson' FROM car_makes WHERE name = 'Hyundai'
ON CONFLICT DO NOTHING;

-- Part categories (inline minimal set)
INSERT INTO part_categories (name) VALUES
  ('Тормоза'), ('Двигатель'), ('Подвеска'), ('Фильтры'),
  ('Электрика'), ('Трансмиссия'), ('Масла и жидкости'), ('Шины и диски')
ON CONFLICT DO NOTHING;

-- Service categories
INSERT INTO service_categories (name) VALUES
  ('Замена масла'), ('Развал-схождение'), ('Диагностика'),
  ('Шиномонтаж'), ('Тормоза'), ('Подвеска и рулевое'),
  ('Электрика и электроника'), ('Двигатель и КПП'), ('ТО (техническое обслуживание)')
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------------------
-- Vendors — 10 parts_shops + 7 repair_shops near Yerevan
-- ---------------------------------------------------------------------------
INSERT INTO vendors (name, type, phone, address, location, rating, is_verified, hours) VALUES
  -- Parts shops
  ('АвтоДетали Центр',     'parts_shop',  '+37410123456', 'ул. Тиграняна 5, Ереван',          ST_SetSRID(ST_MakePoint(44.5120, 40.1890), 4326), 4.5, true,  '{"mon-fri":"09:00-19:00","sat":"10:00-17:00"}'),
  ('Запчасти Маштоца',     'parts_shop',  '+37410234567', 'пр. Маштоца 42, Ереван',            ST_SetSRID(ST_MakePoint(44.5080, 40.1830), 4326), 4.2, true,  '{"mon-fri":"08:30-20:00","sat":"09:00-18:00"}'),
  ('АрмоАвто Запчасти',    'parts_shop',  '+37410345678', 'ул. Баграмяна 18, Ереван',          ST_SetSRID(ST_MakePoint(44.5200, 40.1950), 4326), 4.7, true,  '{"mon-fri":"09:00-20:00","sat":"09:00-17:00"}'),
  ('Детали для Lada/ВАЗ',  'parts_shop',  '+37410456789', 'ул. Абовяна 77, Ереван',            ST_SetSRID(ST_MakePoint(44.5160, 40.1790), 4326), 4.0, false, '{"mon-sat":"09:00-19:00"}'),
  ('Автозапчасти Нор Норк', 'parts_shop', '+37410567890', 'Нор Норк, ул. Народная 3, Ереван', ST_SetSRID(ST_MakePoint(44.5420, 40.1920), 4326), 3.9, false, '{"mon-fri":"09:00-18:00"}'),
  ('Мотор-Сервис Запчасти','parts_shop',  '+37410678901', 'ул. Давид Бека 12, Ереван',         ST_SetSRID(ST_MakePoint(44.5050, 40.1860), 4326), 4.3, true,  '{"mon-fri":"08:00-19:00","sat":"09:00-16:00"}'),
  ('АвтоМир Ереван',       'parts_shop',  '+37410789012', 'ул. Армии 24, Ереван',              ST_SetSRID(ST_MakePoint(44.5300, 40.1800), 4326), 4.1, true,  '{"mon-sat":"09:00-20:00"}'),
  ('Японские Запчасти',    'parts_shop',  '+37410890123', 'ул. Комитаса 33, Ереван',           ST_SetSRID(ST_MakePoint(44.5100, 40.2050), 4326), 4.6, true,  '{"mon-fri":"09:00-19:00"}'),
  ('АвтоДом Арабкир',     'parts_shop',   '+37410901234', 'Арабкир, ул. Цицернакаберди 7',     ST_SetSRID(ST_MakePoint(44.4980, 40.1920), 4326), 4.4, false, '{"mon-fri":"09:00-18:00","sat":"10:00-16:00"}'),
  ('Европейские Запчасти', 'parts_shop',  '+37411012345', 'ул. Паронян 15, Ереван',            ST_SetSRID(ST_MakePoint(44.5190, 40.1840), 4326), 4.8, true,  '{"mon-fri":"08:30-19:30"}'),
  -- Repair shops
  ('СТО Центр Ереван',     'repair_shop', '+37412123456', 'ул. Ширакаци 8, Ереван',            ST_SetSRID(ST_MakePoint(44.5140, 40.1870), 4326), 4.6, true,  '{"mon-fri":"08:00-20:00","sat":"09:00-17:00"}'),
  ('Автосервис Маштоц',    'repair_shop', '+37412234567', 'пр. Маштоца 60, Ереван',            ST_SetSRID(ST_MakePoint(44.5070, 40.1820), 4326), 4.3, true,  '{"mon-fri":"08:30-19:00"}'),
  ('СТО Нор Норк',         'repair_shop', '+37412345678', 'Нор Норк, пр. Азатутян 4, Ереван', ST_SetSRID(ST_MakePoint(44.5390, 40.1900), 4326), 4.0, false, '{"mon-sat":"09:00-18:00"}'),
  ('Автосервис Арабкир',   'repair_shop', '+37412456789', 'Арабкир, ул. Молодёжная 11',        ST_SetSRID(ST_MakePoint(44.4960, 40.1940), 4326), 4.5, true,  '{"mon-fri":"08:00-19:00"}'),
  ('Ванадзорская СТО',     'repair_shop', '+37412567890', 'Ванадзор, пр. Тиграна Меца 2',      ST_SetSRID(ST_MakePoint(44.4890, 40.8180), 4326), 4.1, false, '{"mon-sat":"09:00-18:00"}'),
  ('ПрофСервис Ереван',    'repair_shop', '+37412678901', 'ул. Гарегина Нжде 3, Ереван',       ST_SetSRID(ST_MakePoint(44.5230, 40.1760), 4326), 4.4, true,  '{"mon-fri":"08:00-20:00","sat":"09:00-16:00"}'),
  ('АвтоЭксперт',          'repair_shop', '+37412789012', 'ул. Аршакуняц 22, Ереван',          ST_SetSRID(ST_MakePoint(44.5180, 40.1910), 4326), 4.7, true,  '{"mon-fri":"09:00-19:00"}');

-- ---------------------------------------------------------------------------
-- Parts — for each parts_shop, several parts with categories
-- ---------------------------------------------------------------------------

-- Helper: insert parts referencing vendors by name
-- Parts shop 1: АвтоДетали Центр
INSERT INTO parts (vendor_id, category_id, title, brand, oem_number, price, currency, in_stock)
SELECT v.id, pc.id, p.title, p.brand, p.oem, p.price, 'AMD', true
FROM vendors v, part_categories pc,
(VALUES
  ('Тормозные колодки передние ВАЗ 2107', 'TRIALLI', 'CFT0080', 4500),
  ('Масляный фильтр Toyota Camry XV70',   'MANN',    'W71280',  2800),
  ('Воздушный фильтр Hyundai Tucson',     'FILTRON', 'AP1822',  3200),
  ('Амортизатор передний Lada Granta',    'СААЗ',    '11180-2905004', 8500),
  ('Ремень ГРМ Toyota Camry 2.0',         'GATES',   'T203',    6500)
) AS p(title, brand, oem, price)
WHERE v.name = 'АвтоДетали Центр'
  AND pc.name = CASE
    WHEN p.title LIKE '%колодки%'  THEN 'Тормоза'
    WHEN p.title LIKE '%фильтр%'   THEN 'Фильтры'
    WHEN p.title LIKE '%Амортизатор%' THEN 'Подвеска'
    WHEN p.title LIKE '%Ремень%'   THEN 'Двигатель'
    ELSE 'Двигатель' END;

-- Parts shop 2: Запчасти Маштоца
INSERT INTO parts (vendor_id, category_id, title, brand, oem_number, price, currency, in_stock)
SELECT v.id, pc.id, p.title, p.brand, p.oem, p.price, 'AMD', true
FROM vendors v, part_categories pc,
(VALUES
  ('Тормозной диск передний ВАЗ Нива',    'LPR',      'DF1234',      6200),
  ('Свечи зажигания Toyota Camry (4шт)',   'DENSO',    'K20HR-U11',   7800),
  ('Масло моторное 5W-40 4л',              'MOBIL',    '153590',      18000),
  ('Колодки задние Hyundai Elantra',       'SANGSIN',  'SP1186',      5100),
  ('Стойка стабилизатора Kia Sportage',    'MOOG',     'HY-SB-0978',  3900)
) AS p(title, brand, oem, price)
WHERE v.name = 'Запчасти Маштоца'
  AND pc.name = CASE
    WHEN p.title LIKE '%диск%'     THEN 'Тормоза'
    WHEN p.title LIKE '%Свечи%'    THEN 'Двигатель'
    WHEN p.title LIKE '%Масло%'    THEN 'Масла и жидкости'
    WHEN p.title LIKE '%Колодки%'  THEN 'Тормоза'
    WHEN p.title LIKE '%стабилиз%' THEN 'Подвеска'
    ELSE 'Двигатель' END;

-- Parts shop 3: АрмоАвто Запчасти
INSERT INTO parts (vendor_id, category_id, title, brand, oem_number, price, currency, in_stock)
SELECT v.id, pc.id, p.title, p.brand, p.oem, p.price, 'AMD', true
FROM vendors v, part_categories pc,
(VALUES
  ('Ступичный подшипник передний Toyota Camry', 'NSK',     '40BWD12',     9500),
  ('Сайлентблок рычага Volkswagen Passat B8',   'LEMFORDER','3375201',     4700),
  ('Топливный фильтр Nissan X-Trail',            'FILTRON', 'PP910',       2900),
  ('Датчик ABS BMW 3 Series',                   'BOSCH',   '0265008035',  8200),
  ('Поршневые кольца ВАЗ 2110 79мм',            'ТМЗ',     '2110-1000108',3600)
) AS p(title, brand, oem, price)
WHERE v.name = 'АрмоАвто Запчасти'
  AND pc.name = CASE
    WHEN p.title LIKE '%подшипник%' THEN 'Подвеска'
    WHEN p.title LIKE '%Сайлентблок%' THEN 'Подвеска'
    WHEN p.title LIKE '%фильтр%'    THEN 'Фильтры'
    WHEN p.title LIKE '%ABS%'       THEN 'Электрика'
    WHEN p.title LIKE '%Поршн%'     THEN 'Двигатель'
    ELSE 'Двигатель' END;

-- Parts shop 4: Детали для Lada/ВАЗ
INSERT INTO parts (vendor_id, category_id, title, brand, oem_number, price, currency, in_stock)
SELECT v.id, pc.id, p.title, p.brand, p.oem, p.price, 'AMD', true
FROM vendors v, part_categories pc,
(VALUES
  ('Генератор ВАЗ 2107 (восстановленный)',  'ПРАМО',  '37.3701-02',  22000),
  ('Стартер ВАЗ 2110',                      'ПРАМО',  '5712.3708',   18500),
  ('Карбюратор Solex ВАЗ 2107',             'SOLEX',  '21073-1107010',12000),
  ('Тяга рулевая ВАЗ Нива 2121',            'СААЗ',   '2121-3414010', 4800),
  ('Помпа ВАЗ 21213 Нива',                  'FENOX',  'WP0128',       6300)
) AS p(title, brand, oem, price)
WHERE v.name = 'Детали для Lada/ВАЗ'
  AND pc.name = CASE
    WHEN p.title LIKE '%Генератор%' THEN 'Электрика'
    WHEN p.title LIKE '%Стартер%'   THEN 'Электрика'
    WHEN p.title LIKE '%Карбюратор%' THEN 'Двигатель'
    WHEN p.title LIKE '%Тяга%'      THEN 'Рулевое управление'
    ELSE 'Двигатель' END;

-- Parts shop 5: Автозапчасти Нор Норк
INSERT INTO parts (vendor_id, category_id, title, brand, oem_number, price, currency, in_stock)
SELECT v.id, pc.id, p.title, p.brand, p.oem, p.price, 'AMD', true
FROM vendors v, part_categories pc,
(VALUES
  ('Колодки передние Mercedes E-Class W213', 'ATE',    '13046072412',  14500),
  ('Фильтр салона BMW 5 G30',                'MANN',   'CU29005',       3200),
  ('Рычаг подвески передний Audi Q5',        'FEBI',   '44543',        16800),
  ('Термостат Volkswagen Golf Mk8',          'WAHLER', '4101.87',       5600),
  ('Тормозная жидкость DOT 4 500мл',         'TEXTAR', '95000200',      2800)
) AS p(title, brand, oem, price)
WHERE v.name = 'Автозапчасти Нор Норк'
  AND pc.name = CASE
    WHEN p.title LIKE '%Колодки%'   THEN 'Тормоза'
    WHEN p.title LIKE '%Фильтр%'    THEN 'Фильтры'
    WHEN p.title LIKE '%Рычаг%'     THEN 'Подвеска'
    WHEN p.title LIKE '%Термостат%' THEN 'Двигатель'
    ELSE 'Масла и жидкости' END;

-- Parts shop 6: Мотор-Сервис Запчасти
INSERT INTO parts (vendor_id, category_id, title, brand, oem_number, price, currency, in_stock)
SELECT v.id, pc.id, p.title, p.brand, p.oem, p.price, 'AMD', true
FROM vendors v, part_categories pc,
(VALUES
  ('Комплект сцепления Lada Granta',      'VALEO',  '826527',     38000),
  ('ШРУС наружный Toyota Camry XV50',     'GKN',    '302024',     24000),
  ('Граната ВАЗ 2110 наружная',           'ТРИАЛ',  '2110-2215012',11000),
  ('Диск тормозной задний Kia Rio YB',    'SANGSIN','SD4113',      8500),
  ('Прокладка ГБЦ ГАЗ Газель дв.402',    'Payen',  'BW030',      12000)
) AS p(title, brand, oem, price)
WHERE v.name = 'Мотор-Сервис Запчасти'
  AND pc.name = CASE
    WHEN p.title LIKE '%сцепления%' THEN 'Трансмиссия'
    WHEN p.title LIKE '%ШРУС%' OR p.title LIKE '%Граната%' THEN 'Трансмиссия'
    WHEN p.title LIKE '%диск%' OR p.title LIKE '%Диск%' THEN 'Тормоза'
    ELSE 'Двигатель' END;

-- Parts shop 7: АвтоМир Ереван
INSERT INTO parts (vendor_id, category_id, title, brand, oem_number, price, currency, in_stock)
SELECT v.id, pc.id, p.title, p.brand, p.oem, p.price, 'AMD', true
FROM vendors v, part_categories pc,
(VALUES
  ('Аккумулятор 60Ah Bosch S5',           'BOSCH',  '0092S50050',  48000),
  ('Фары LED комплект Hyundai Tucson NX4', 'OSRAM',  'LEDriving',   95000),
  ('Лямбда-зонд ВАЗ 2110 1.6',            'BOSCH',  '0258006537',  14500),
  ('Датчик температуры Toyota Camry',      'NGK',    'EP45',         4200),
  ('Ремень поликлиновой 6PK1780',          'GATES',  '6PK1780',      6800)
) AS p(title, brand, oem, price)
WHERE v.name = 'АвтоМир Ереван'
  AND pc.name = CASE
    WHEN p.title LIKE '%Аккумулятор%' THEN 'Электрика'
    WHEN p.title LIKE '%Фары%'        THEN 'Электрика'
    WHEN p.title LIKE '%Лямбда%' OR p.title LIKE '%Датчик%' THEN 'Электрика'
    ELSE 'Двигатель' END;

-- Parts shop 8: Японские Запчасти
INSERT INTO parts (vendor_id, category_id, title, brand, oem_number, price, currency, in_stock)
SELECT v.id, pc.id, p.title, p.brand, p.oem, p.price, 'AMD', true
FROM vendors v, part_categories pc,
(VALUES
  ('Маслосъёмные колпачки Honda Civic 1.8',  'VICTOR REINZ', '12-53543-01', 7500),
  ('Сальник коленвала Toyota 1ZZ-FE',         'NOK',          '90311-38066', 3800),
  ('Помпа Toyota Camry 2.5 2ARFE',            'GMB',          'GWP57AF',    19500),
  ('Натяжитель цепи ГРМ Nissan X-Trail',      'DAYCO',        'APV2740',    11200),
  ('Прокладка клапанной крышки Honda CR-V',   'ELRING',       '024741',      4100)
) AS p(title, brand, oem, price)
WHERE v.name = 'Японские Запчасти'
  AND pc.name = CASE
    WHEN p.title LIKE '%колпачки%' OR p.title LIKE '%Сальник%' THEN 'Двигатель'
    WHEN p.title LIKE '%Помпа%'    THEN 'Охлаждение'
    WHEN p.title LIKE '%Натяжитель%' OR p.title LIKE '%Прокладка%' THEN 'Двигатель'
    ELSE 'Двигатель' END;

-- Parts shop 9: АвтоДом Арабкир
INSERT INTO parts (vendor_id, category_id, title, brand, oem_number, price, currency, in_stock)
SELECT v.id, pc.id, p.title, p.brand, p.oem, p.price, 'AMD', true
FROM vendors v, part_categories pc,
(VALUES
  ('Стойка амортизатора передняя ВАЗ Приора', 'KAYABA',   'KYB334836',  16500),
  ('Пружина задняя ВАЗ 2110',                 'СААЗ',     '2110-2912712', 5800),
  ('Рулевая рейка б/у Subaru Outback BS',     'SUBARU',   '34110AL020', 45000),
  ('Наконечник рулевой Mitsubishi Outlander', 'MOOG',     'MI-ES-0750',  4900),
  ('Опора стойки BMW X5 G05',                 'LEMFORDER','4347001',     21000)
) AS p(title, brand, oem, price)
WHERE v.name = 'АвтоДом Арабкир'
  AND pc.name = CASE
    WHEN p.title LIKE '%амортизатора%' OR p.title LIKE '%Пружина%' THEN 'Подвеска'
    WHEN p.title LIKE '%Рулевая%' OR p.title LIKE '%Наконечник%' OR p.title LIKE '%Опора%' THEN 'Подвеска'
    ELSE 'Подвеска' END;

-- Parts shop 10: Европейские Запчасти
INSERT INTO parts (vendor_id, category_id, title, brand, oem_number, price, currency, in_stock)
SELECT v.id, pc.id, p.title, p.brand, p.oem, p.price, 'AMD', true
FROM vendors v, part_categories pc,
(VALUES
  ('Комплект ГРМ Volkswagen 2.0 TDI',    'CONTITECH', 'CT1175K1',  42000),
  ('Турбина BMW 320d F30',                'GARRETT',   '810358-001',155000),
  ('ТНВД Audi A4 2.0 TDI',               'BOSCH',     '0445010091',185000),
  ('EGR клапан Mercedes C-Class W205',    'PIERBURG',  '7.00868.03', 38500),
  ('Форсунка Volkswagen Passat B8 2.0',   'BOSCH',     '0445117021', 62000)
) AS p(title, brand, oem, price)
WHERE v.name = 'Европейские Запчасти'
  AND pc.name = 'Двигатель';

-- ---------------------------------------------------------------------------
-- Part fitments
-- ---------------------------------------------------------------------------

-- Whole-make fitment for ВАЗ (model_id NULL) — PITFALLS #5 smoke test
INSERT INTO part_fitments (part_id, make_id, model_id, generation_id)
SELECT p.id, mk.id, NULL, NULL
FROM parts p
JOIN vendors v ON v.id = p.vendor_id
JOIN car_makes mk ON mk.name = 'ВАЗ'
WHERE v.name IN ('АвтоДетали Центр', 'Детали для Lada/ВАЗ', 'АвтоДом Арабкир', 'Мотор-Сервис Запчасти')
  AND (p.title LIKE '%ВАЗ%' OR p.title LIKE '%Lada%' OR p.title LIKE '%Нива%' OR p.title LIKE '%Приора%' OR p.title LIKE '%Гранта%');

-- Specific model fitments: Toyota Camry XV70
INSERT INTO part_fitments (part_id, make_id, model_id, generation_id)
SELECT p.id, mk.id, cm.id, cg.id
FROM parts p
JOIN vendors v ON v.id = p.vendor_id
JOIN car_makes mk ON mk.name = 'Toyota'
JOIN car_models cm ON cm.make_id = mk.id AND cm.name = 'Camry'
JOIN car_generations cg ON cg.model_id = cm.id AND cg.name = 'XV70'
WHERE p.title LIKE '%Toyota Camry%';

-- Hyundai Tucson fitments (model-level, generation NULL)
INSERT INTO part_fitments (part_id, make_id, model_id, generation_id)
SELECT p.id, mk.id, cm.id, NULL
FROM parts p
JOIN vendors v ON v.id = p.vendor_id
JOIN car_makes mk ON mk.name = 'Hyundai'
JOIN car_models cm ON cm.make_id = mk.id AND cm.name = 'Tucson'
WHERE p.title LIKE '%Hyundai%';

-- Universal fitments for generic parts (oil, brake fluid, etc.) — whole-make Toyota
INSERT INTO part_fitments (part_id, make_id, model_id, generation_id)
SELECT p.id, mk.id, NULL, NULL
FROM parts p
JOIN car_makes mk ON mk.name = 'Toyota'
WHERE p.title LIKE '%Toyota%'
  AND NOT EXISTS (
    SELECT 1 FROM part_fitments pf WHERE pf.part_id = p.id AND pf.make_id = mk.id
  );

-- Whole-make fitment for ГАЗ (covers Газель, Волга)
INSERT INTO part_fitments (part_id, make_id, model_id, generation_id)
SELECT p.id, mk.id, NULL, NULL
FROM parts p
JOIN car_makes mk ON mk.name = 'ГАЗ'
WHERE p.title LIKE '%ГАЗ%';

-- Generic parts (oil, belts, filters) — also fit ВАЗ (whole-make)
INSERT INTO part_fitments (part_id, make_id, model_id, generation_id)
SELECT p.id, mk.id, NULL, NULL
FROM parts p
JOIN car_makes mk ON mk.name = 'ВАЗ'
WHERE (p.title LIKE '%Масло%' OR p.title LIKE '%ремень%' OR p.title LIKE '%Ремень%')
  AND NOT EXISTS (
    SELECT 1 FROM part_fitments pf WHERE pf.part_id = p.id AND pf.make_id = mk.id
  );

-- ---------------------------------------------------------------------------
-- Vendor services for repair shops
-- ---------------------------------------------------------------------------
INSERT INTO vendor_services (vendor_id, service_category_id, price_from, price_to)
SELECT v.id, sc.id, s.price_from, s.price_to
FROM vendors v, service_categories sc,
(VALUES
  ('СТО Центр Ереван',    'Замена масла',               3500,  7000),
  ('СТО Центр Ереван',    'Развал-схождение',            6000,  9000),
  ('СТО Центр Ереван',    'Диагностика',                 5000,  8000),
  ('СТО Центр Ереван',    'Тормоза',                     8000, 25000),
  ('СТО Центр Ереван',    'ТО (техническое обслуживание)',15000,45000),
  ('Автосервис Маштоц',   'Замена масла',               3000,  6500),
  ('Автосервис Маштоц',   'Шиномонтаж',                 1500,  3000),
  ('Автосервис Маштоц',   'Диагностика',                4500,  7000),
  ('Автосервис Маштоц',   'Подвеска и рулевое',         6000, 30000),
  ('СТО Нор Норк',        'Замена масла',               2500,  5500),
  ('СТО Нор Норк',        'Тормоза',                    7000, 22000),
  ('СТО Нор Норк',        'Развал-схождение',           5500,  8500),
  ('СТО Нор Норк',        'Шиномонтаж',                 1200,  2500),
  ('Автосервис Арабкир',  'Диагностика',                4000,  7500),
  ('Автосервис Арабкир',  'Электрика и электроника',    5000, 35000),
  ('Автосервис Арабкир',  'Двигатель и КПП',           25000,200000),
  ('Автосервис Арабкир',  'ТО (техническое обслуживание)',12000,40000),
  ('ПрофСервис Ереван',   'Развал-схождение',           6500,  9500),
  ('ПрофСервис Ереван',   'Замена масла',               3200,  7000),
  ('ПрофСервис Ереван',   'Шиномонтаж',                 1500,  3000),
  ('ПрофСервис Ереван',   'Тормоза',                    7500, 24000),
  ('ПрофСервис Ереван',   'Подвеска и рулевое',         7000, 35000),
  ('АвтоЭксперт',         'Диагностика',                5500,  9000),
  ('АвтоЭксперт',         'Электрика и электроника',    6000, 40000),
  ('АвтоЭксперт',         'Двигатель и КПП',           30000,250000),
  ('АвтоЭксперт',         'ТО (техническое обслуживание)',14000,50000),
  ('АвтоЭксперт',         'Развал-схождение',           7000, 10000)
) AS s(vname, scname, price_from, price_to)
WHERE v.name = s.vname AND sc.name = s.scname;
