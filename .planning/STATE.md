---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
status: executing
last_updated: "2026-06-16T08:27:28.344Z"
progress:
  total_phases: 6
  completed_phases: 3
  total_plans: 12
  completed_plans: 12
  percent: 50
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

**Phase:** 03 — Parts Search & List Results — COMPLETE
**Plan:** 03-05 complete (all 5 plans merged to master)
**Status:** Phase 03 complete & verified — 5/5 success criteria PASS (static analysis). Integrated `mobile/` app: `flutter analyze` clean, `flutter test` 43/43 green (from /tmp copy due to OneDrive build lock). Backend: search_parts 8-arg fix + OEM normalization (migration 005) + part-categories endpoint. Deferred to local device/Docker: 03-03 app-launch checkpoint, visual results/location-denial flows, OEM search e2e + backend e2e vs live PostGIS. See 03-VERIFICATION.md.

```
Progress: [ ][x][x][ ][ ][ ]  3/6 phases complete
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

**Last action:** Phase 03 fully executed & merged to master (2026-06-16). All 5 plans complete: 03-01 (search_parts 8-arg fix + OEM normalization migration 005 + radius cap), 03-02 (GET /catalog/part-categories), 03-03 (Flutter scaffold in mobile/), 03-04 (home screen + search providers + location service Yerevan fallback), 03-05 (results UI + 4 async states). Integrated app: `flutter analyze` clean, `flutter test` 43/43 green. Verified 5/5 success criteria (static); 4 device/DB checks deferred.

**IMPORTANT layout note:** Flutter app lives in `mobile/` (from Phase 02), NOT `app/` as plans 03-03/03-04/03-05 assume. Executors must target `mobile/` and adapt the planned `app/...` paths accordingly.

**Next action:** Start Phase 04. Before that, on a dev machine with Docker + device: run the 4 deferred verifications from 03-VERIFICATION.md (app launch, visual results screen, location-denial flow, OEM search e2e + backend e2e vs live PostGIS).

**Worktree harness bug:** the runtime does a non-exist-ok `mkdir .claude/worktrees`; before spawning a worktree agent, fully remove the empty `.claude/worktrees` parent dir (and prune `.git/worktrees/*`) or spawning fails with EEXIST.

**Open questions:** Flutter SDK not in CI — `flutter test`/`analyze` run locally; backend e2e needs live PostGIS DB (deferred to local). .g.dart files hand-authored, need `build_runner` locally.

---

*State initialized: 2026-06-14*
*Last updated: 2026-06-16 — Phase 03 Wave 1 partial (03-01, 03-02 done; 03-03 interrupted by session limit)*
