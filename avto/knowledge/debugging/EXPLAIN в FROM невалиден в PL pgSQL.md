---
tags: [баг, postgis, тесты, fix]
date: 2026-06-15
---

# EXPLAIN в FROM невалиден в PL/pgSQL

**Симптом:** `db/tests/explain_gist.sql` падал с `syntax error at or near "SELECT"`.

**Причина:** `SELECT ... FROM (EXPLAIN ...)` — недопустимо; EXPLAIN нельзя как подзапрос.

**Фикс:** `FOR rec IN EXECUTE 'EXPLAIN SELECT * FROM search_parts(...)' LOOP plan_text := plan_text || rec; END LOOP;`. После фикса тест: «PASS — GiST index scan found in plan».

Связано: [[ST_DWithin в WHERE, ST_Distance в SELECT]]
