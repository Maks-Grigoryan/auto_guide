---
tags: [atlas, стек]
date: 2026-06-15
---

# Стек — Flutter, NestJS, PostGIS

Версии проверены на pub.dev/npmjs (2026-06):

- **Flutter 3.27+ / Dart 3.6+** — один код iOS+Android
- **Riverpod 3.3.2** — состояние (family-провайдеры под каскад марка→модель→поколение); **не** Bloc для solo/малой команды
- **go_router 17** — навигация, ShellRoute для нижней навигации
- **dio 5.9** — HTTP с JWT-интерсепторами
- **NestJS 11 (Node 20+)** — модули по доменам: search / vendors / parts / catalog / auth
- **PostgreSQL 16 + PostGIS 3.4** — образ `postgis/postgis:16-3.4`
- **pg (node-postgres) 8.21** — сырой пул, без ORM ([[pg.Pool вместо ORM для гео]])
- **node-pg-migrate** — версионированные SQL-миграции ([[Миграции разбиты по слоям]])
- **Yandex MapKit** — [[Yandex MapKit — официальный пакет]]

Связано: [[Геопоиск живёт в SQL-функциях]], [[Деплой локально через docker compose]]
