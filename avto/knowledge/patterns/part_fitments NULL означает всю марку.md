---
tags: [паттерн, бд, совместимость]
date: 2026-06-15
---

# part_fitments NULL означает всю марку

В `part_fitments` `model_id IS NULL` = «подходит ко всей марке»; `generation_id IS NULL` = «вся модель». Фильтр обязан учитывать NULL:

`AND (model_id IS NULL OR model_id = $x)` — иначе `model_id = $x` молча отбросит детали с whole-make совместимостью.

Тест `db/tests/fitment_null.sql` проверяет, что whole-make деталь видна в поиске по конкретной модели. `make_id` — NOT NULL (CHECK).

Связано: [[search_parts отдаёт одну строку на продавца]], [[Геопоиск живёт в SQL-функциях]]
