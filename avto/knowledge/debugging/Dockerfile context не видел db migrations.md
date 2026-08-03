---
tags: [баг, docker, fix]
date: 2026-06-15
---

# Dockerfile context не видел db migrations

**Симптом:** `docker compose up` падал бы на шаге миграций api — образ собирался с context `./backend` и не мог скопировать `../db/migrations`.

**Причина:** миграции живут вне `backend/`, а build-context был `./backend`.

**Фикс:** context → корень репо (`context: .`, `dockerfile: backend/Dockerfile`), `COPY db/migrations ./db/migrations`, команда `npx node-pg-migrate up -m ./db/migrations`. Коммит `fix(01)`.

Связано: [[Деплой локально через docker compose]], [[migrate up игнорировал путь конфига]]
