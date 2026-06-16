---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
status: executing
last_updated: "2026-06-16T06:29:43.688Z"
progress:
  total_phases: 6
  completed_phases: 2
  total_plans: 12
  completed_plans: 7
  percent: 33
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

Phase: 03 — next phase
**Phase:** 02 — Car Catalog Selector — COMPLETE
**Plan:** 02-03 complete (Asphalt & Signal theme + 6 widgets + make filter test)
**Status:** Phase 02 complete & verified PASSED — Flutter 3.44.2 installed (C:\src\flutter), `flutter analyze` clean, `flutter test` 9/9 green (commit 476d3c8). Deferred to device/Docker: on-device cold-start persistence (SEL-04) + catalog e2e vs live DB. Ready to start Phase 03.

```
Progress: [ ][x][ ][ ][ ][ ]  2/6 phases complete
           P1  P2  P3  P4  P5  P6
```

---

## Performance Metrics

| Metric | Value |
|--------|-------|
| Phases total | 6 |
| Phases complete | 2 |
| Plans complete | 7 |
| Requirements mapped | 28/28 |
| Requirements done | 4/28 (SEL-01..04) |

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

**Last action:** Completed 02-03-PLAN.md — Asphalt & Signal theme, 6 reusable widgets, make filter widget test, pages refactored (2026-06-16)
**Next action:** Phase 03 — Home screen geo-search
**Open questions:** Flutter SDK not in CI environment — `flutter test` and `flutter analyze` must be run locally before PR merge; .g.dart files hand-authored, need `build_runner` locally

---

*State initialized: 2026-06-14*
*Last updated: 2026-06-16 after 02-03 completion*
