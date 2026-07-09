---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
status: planning
last_updated: "2026-07-09T13:10:48.100Z"
progress:
  total_phases: 6
  completed_phases: 4
  total_plans: 16
  completed_plans: 16
  percent: 67
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

Phase: 04 (map-view-repair-search) — EXECUTING
Plan: 1 of 4
**Phase:** 5
**Plan:** Not started
**Status:** Ready to plan

```
Progress: [ ][x][x][ ][ ][ ]  3/6 phases complete
           P1  P2  P3  P4  P5  P6
```

---

## Performance Metrics

| Metric | Value |
|--------|-------|
| Phases total | 6 |
| Phases complete | 3 |
| Plans complete | 12 |
| Requirements mapped | 28/28 |
| Requirements done | 17/28 (FND-01..05, CAT-01/02, SEL-01..04, PRT-01..03, RES-01/06/07) |

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

**Last action:** Phase 04 UI design contract created & approved (2026-06-16) → `04-UI-SPEC.md`. gsd-ui-researcher produced the contract (list⇄map `[Список]/[Карта]` toggle, Yandex marker view + marker→bottom-sheet card reusing `VendorResultCard`, «Сортировка и фильтры» instant-apply sheet, repair-search parity surface, graceful «Карта недоступна» degradation); design system carried forward UNCHANGED from Phase 2/3 (`app_theme.dart` "Asphalt & Signal"). gsd-ui-checker VERIFIED all 6 dimensions PASS first-pass — no token drift vs `app_theme.dart`/`03-UI-SPEC.md`, all CONTEXT D-01..D-04 + discretion defaults honored. Doc NOT committed (commit_docs=false). (Phase 03 execution detail retained in Current Position above.)

**IMPORTANT layout note:** Flutter app lives in `mobile/` (from Phase 02), NOT `app/` as plans 03-03/03-04/03-05 assume. Executors must target `mobile/` and adapt the planned `app/...` paths accordingly.

**Next action:** `/gsd:plan-phase 4` — planner consumes `04-CONTEXT.md` + `04-UI-SPEC.md` as design context. No `04-RESEARCH.md` yet; plan-phase runs research first (config workflow.research=true). Phase 04 backend gap stands (see below). Still pending on a dev machine with Docker + device: the 4 deferred verifications from 03-VERIFICATION.md (app launch, visual results screen, location-denial flow, OEM search e2e + backend e2e vs live PostGIS), plus the new D-04 map-degradation path once a Yandex MapKit key is provisioned.

**Phase 04 known gap:** no repair backend endpoint exists yet — only the `search_repair` SQL function + service_categories/vendor_services schema/seed (migrations 002/003/004). Phase 4 must add `GET /search/repair` + a service-categories endpoint, mirroring the parts endpoints.

**Worktree harness bug:** the runtime does a non-exist-ok `mkdir .claude/worktrees`; before spawning a worktree agent, fully remove the empty `.claude/worktrees` parent dir (and prune `.git/worktrees/*`) or spawning fails with EEXIST.

**Open questions:** Flutter SDK not in CI — `flutter test`/`analyze` run locally; backend e2e needs live PostGIS DB (deferred to local). .g.dart files hand-authored, need `build_runner` locally.

---

*State initialized: 2026-06-14*
*Last updated: 2026-06-16 — Phase 04 UI-SPEC created & approved (ui-phase)*
