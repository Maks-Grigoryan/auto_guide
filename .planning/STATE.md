---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
status: executing
last_updated: "2026-06-16T00:00:00.000Z"
progress:
  total_phases: 6
  completed_phases: 1
  total_plans: 12
  completed_plans: 6
  percent: 17
---

# STATE — Авто-агрегатор (СТО + запчасти)

*Project memory. Updated at each phase transition and plan completion.*

---

## Project Reference

**Core Value:** Пользователь выбирает своё авто (марка → модель → поколение) и сразу видит ближайшие подходящие магазины/сервисы списком и на карте.

**Current Milestone:** MVP-1 (Geo-search хребет — анонимный геопоиск на тестовых данных)

**Stack:** Flutter 3.27+ / NestJS 11.x / PostgreSQL 15+ PostGIS 3.4+ / Yandex MapKit 4.36.0 / Riverpod 3 / go_router / node-pg-migrate

---

## Current Position

Phase: 02 (car-catalog-selector) — EXECUTING
Plan: 3 of 3
**Phase:** 02 — Car Catalog Selector
**Plan:** 02-02 complete (Flutter scaffold + car selector end-to-end slice)
**Status:** Ready to execute 02-03

```
Progress: [ ][>][ ][ ][ ][ ]  0/6 phases complete
           P1  P2  P3  P4  P5  P6
```

---

## Performance Metrics

| Metric | Value |
|--------|-------|
| Phases total | 6 |
| Phases complete | 0 |
| Plans complete | 0 |
| Requirements mapped | 28/28 |
| Requirements done | 0/28 |

---

## Accumulated Context

### Key Decisions (from research)

- Geo-logic lives in SQL functions (`search_parts`, `search_repair`) called via raw `pg.Pool` — no ORM for PostGIS
- Riverpod 3 with `@riverpod` code-gen for Flutter state (family providers for make→model→generation cascade)
- `yandex_maps_mapkit` 4.36.0 FULL (not lite, not old community package) — needed for routing
- `node-pg-migrate` for migrations (not Flyway/Prisma Migrate — avoids JVM, handles PostGIS DDL)
- `go_router` 17.3.0 with ShellRoute for persistent bottom nav
- Reference data cached 24h in Riverpod + Hive

### Critical Pitfalls to Gate

- [ ] P1: PostGIS coordinate smoke test — `ST_MakePoint(lng, lat)` longitude first
- [ ] P1: GiST index scan verified via `EXPLAIN ANALYZE` (not seq scan)
- [ ] P1: `part_fitments` NULL semantics tested — `(model_id IS NULL OR model_id = $x)`
- [ ] P1: CIS makes (Lada/ВАЗ, ГАЗ, УАЗ) seeded manually (NHTSA vPIC is US-only)
- [ ] P4: Yandex MapKit iOS release crash — test on physical device in release mode
- [ ] P6: Every screen passes `textScaleFactor = 2.0` test

### Todos

- Obtain Yandex MapKit API key (developer.tech.yandex.ru) — possible approval delay for non-RU entity
- Pin Node 20 in `.nvmrc` / `engines` (Node 18 is EOL)
- Ensure `riverpod_generator` version matches riverpod major version

### Blockers

None currently.

---

## Session Continuity

*Fill in before ending each session.*

**Last action:** Completed 02-02-PLAN.md — Flutter scaffold + car selector flow (make→model→generation→confirm→chip+persistence) (2026-06-16)
**Next action:** Execute plan 02-03 (UI polish: searchable lists, theme, error/empty states)
**Open questions:** Flutter SDK not found in execution environment — flutter pub get and build_runner must be run locally; .g.dart files are hand-authored and need regeneration

---

*State initialized: 2026-06-14*
*Last updated: 2026-06-14 after roadmap creation*
