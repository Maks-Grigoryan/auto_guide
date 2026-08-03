---
tags: [atlas, архитектура, геопоиск]
date: 2026-06-15
---

# Геопоиск живёт в SQL-функциях

Самое нагруженное решение проекта: вся гео-логика — в PostGIS-функциях `search_parts` и `search_repair`, бэкенд вызывает их сырым `pg.Pool`. ORM (TypeORM/Prisma) не умеет корректно работать с типом `geography`.

Поток запроса: `Flutter → GET /search/parts (NestJS) → search.service (pg.Pool, $1..$7) → search_parts() в PostGIS → JSON`.

Ключевые правила:
- [[search_parts отдаёт одну строку на продавца]]
- [[ST_DWithin в WHERE, ST_Distance в SELECT]]
- [[Координаты PostGIS — сначала долгота]]
- [[part_fitments NULL означает всю марку]]

Связано: [[Стек — Flutter, NestJS, PostGIS]], [[pg.Pool вместо ORM для гео]], [[Схема БД минимальна — только под геопоиск]]
