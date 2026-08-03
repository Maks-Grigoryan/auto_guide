---
tags: [баг, миграции, fix]
date: 2026-06-15
---

# migrate up игнорировал путь конфига

**Симптом:** `npm run migrate:up` падал с `ENOENT ... backend/migrations/` — искал миграции в `./migrations`, хотя они в `db/migrations`.

**Причина:** node-pg-migrate не подхватывал `.node-pg-migrate.json` (`dir`).

**Фикс:** явный флаг в скриптах — `node-pg-migrate up -m ../db/migrations` (коммит `fix(01)`).

Связано: [[Миграции разбиты по слоям]], [[Dockerfile context не видел db migrations]]
