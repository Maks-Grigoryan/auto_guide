---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
status: executing
last_updated: "2026-06-16T08:27:28.344Z"
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

Phase: 03 (parts-search-list-results) — EXECUTING
Plan: 1 of 5
**Phase:** 02 — Car Catalog Selector — COMPLETE
**Plan:** 02-03 complete (Asphalt & Signal theme + 6 widgets + make filter test)
**Status:** Executing Phase 03

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

**Last action:** Phase 03 execution started (2026-06-16). Wave 1 backend plans DONE & merged to master: 03-01 (8-arg search_parts fix + OEM normalization migration 005 + radius cap, 9 e2e green) and 03-02 (GET /catalog/part-categories, 24h cache, 9 e2e green). 03-03 (Flutter scaffold) INTERRUPTED by session limit — partial work preserved as WIP on git branch `worktree-agent-abdaa1fb55d58c374` (commits bd77525 + 56c7acf): geolocator added to mobile/pubspec.yaml + smoke harness + mobile/lib/core/{api,models} + features/parts_results scaffold. NOT built/tested, NO SUMMARY yet, NOT merged.

**IMPORTANT layout note:** Flutter app lives in `mobile/` (from Phase 02), NOT `app/` as plans 03-03/03-04/03-05 assume. Executors must target `mobile/` and adapt the planned `app/...` paths accordingly.

**Next action (resume after limit reset ~3pm Yerevan):** Finish 03-03 — complete scaffold in `mobile/`, run `flutter analyze` + `flutter test` (SDK at C:\src\flutter), record human-verify checkpoint as DEFERRED, write 03-03-SUMMARY.md, merge branch to master. Then Wave 2 (03-04 home screen) and Wave 3 (03-05 results screen). Resume from the WIP branch rather than restarting.

**Worktree harness bug:** the runtime does a non-exist-ok `mkdir .claude/worktrees`; before spawning a worktree agent, fully remove the empty `.claude/worktrees` parent dir (and prune `.git/worktrees/*`) or spawning fails with EEXIST.

**Open questions:** Flutter SDK not in CI — `flutter test`/`analyze` run locally; backend e2e needs live PostGIS DB (deferred to local). .g.dart files hand-authored, need `build_runner` locally.

---

*State initialized: 2026-06-14*
*Last updated: 2026-06-16 — Phase 03 Wave 1 partial (03-01, 03-02 done; 03-03 interrupted by session limit)*
