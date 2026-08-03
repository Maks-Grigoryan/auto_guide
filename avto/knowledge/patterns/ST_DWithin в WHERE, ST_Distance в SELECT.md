---
tags: [паттерн, postgis, производительность]
date: 2026-06-15
---

# ST_DWithin в WHERE, ST_Distance в SELECT

Радиусный фильтр — только через `ST_DWithin` в WHERE (использует GiST-индекс). `ST_Distance` — только в SELECT для показа расстояния. `ST_Distance` в WHERE отключает индекс → seq scan.

Проверка: `EXPLAIN` должен показывать `Index Scan using vendors_location_gist`. Тест `db/tests/explain_gist.sql` падает, если индекс не используется.

Связано: [[Геопоиск живёт в SQL-функциях]], [[Координаты PostGIS — сначала долгота]]
