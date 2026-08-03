---
tags: [atlas, деплой, docker]
date: 2026-06-15
---

# Деплой локально через docker compose

`docker compose up` поднимает PostGIS (`db`) и NestJS (`api`) без ручных шагов:
1. `db` — `postgis/postgis:16-3.4` с healthcheck (`pg_isready`).
2. `api` — multi-stage Dockerfile; на старте `node-pg-migrate up -m ./db/migrations`, затем `node dist/main`. Зависит от `db: service_healthy`.

Локальная разработка: `cp .env.example .env`, `docker compose up -d db`, `cd backend && npm run migrate:up`.

Подводные камни, уже исправленные:
- [[migrate up игнорировал путь конфига]]
- [[Dockerfile context не видел db migrations]]

Секреты: реальный `.env` в `.gitignore`; compose читает `${POSTGRES_PASSWORD}` из env.

Связано: [[Стек — Flutter, NestJS, PostGIS]]
