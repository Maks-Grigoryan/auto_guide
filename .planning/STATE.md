---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
status: complete
last_updated: "2026-08-03T12:55:00+04:00"
progress:
  total_phases: 6
  completed_phases: 6
  total_plans: 18
  completed_plans: 18
  percent: 100
---

# STATE — Авто-агрегатор (СТО + запчасти)

*Project memory. Updated at each phase transition and plan completion.*

---

## Project Reference

**Core Value:** Пользователь выбирает своё авто (марка → модель → поколение) и сразу видит ближайшие подходящие магазины/сервисы списком и на карте.

**Current Milestone:** v1.0 (полный анонимный геопоиск запчастей и ремонта)

**Stack:** Flutter 3.27+ / NestJS 11.x / PostgreSQL 15+ PostGIS 3.4+ / Yandex MapKit 4.36.0 / Riverpod 3 / go_router / node-pg-migrate

---

## Current Position

Phase: 06 (accessibility-i18n) — COMPLETE
Plan: 1 of 1
**Phase:** 6
**Plan:** Complete
**Status:** v1.0 verified

```
Progress: [x][x][x][x][x][x]  6/6 phases complete
           P1  P2  P3  P4  P5  P6
```

---

## Performance Metrics

| Metric | Value |
|--------|-------|
| Phases total | 6 |
| Phases complete | 6 |
| Plans complete | 18 |
| Requirements mapped | 28/28 |
| Requirements done | 28/28 |

---

## Accumulated Context

### Key Decisions (from research)

- Geo-logic lives in SQL functions (`search_parts`, `search_repair`) called via raw `pg.Pool` — no ORM for PostGIS
- Riverpod 3 with `@riverpod` code-gen for Flutter state (family providers for make→model→generation cascade)
- `yandex_maps_mapkit` 4.39.1 FULL (not lite, not old community package) — needed for map markers
- `node-pg-migrate` for migrations (not Flyway/Prisma Migrate — avoids JVM, handles PostGIS DDL)
- `go_router` 17.3.0 with ShellRoute for persistent bottom nav
- Reference data cached 24h in Riverpod + Hive

### Critical Pitfalls to Gate

- [x] P1: PostGIS coordinate smoke test — `ST_MakePoint(lng, lat)` longitude first
- [x] P1: GiST index scan verified via `EXPLAIN ANALYZE` (not seq scan)
- [x] P1: `part_fitments` NULL semantics tested — `(model_id IS NULL OR model_id = $x)`
- [x] P1: CIS makes (Lada/ВАЗ, ГАЗ, УАЗ) seeded manually (NHTSA vPIC is US-only)
- [ ] P4: Yandex MapKit iOS release crash — test on physical device in release mode
- [x] P6: Every route screen passes RU/HY/EN at `textScaleFactor = 2.0`

### Todos

- Obtain Yandex MapKit API key (developer.tech.yandex.ru) — possible approval delay for non-RU entity
- Provision production Yandex MapKit key and API hostname
- Configure Android/iOS release signing in the store accounts
- Replace starter seed catalog with verified real vendor data before public launch

### Blockers

Code and automated verification have no blockers. Physical iOS release verification and store signing require Apple/Google developer credentials and real devices.

---

## Session Continuity

*Fill in before ending each session.*

**Last action:** v1.0 completed 2026-08-03. Added vendor API/detail/contact flow, full RU/HY/EN localization, native Android/iOS projects, adaptive 200% text layouts, CI, health/readiness endpoints, hardened Docker runtime and release documentation. Verified 89 Flutter tests, 33 backend e2e tests, four SQL invariants and live Docker HTTP smoke tests.

**IMPORTANT layout note:** Flutter app lives in `mobile/` (from Phase 02), NOT `app/` as plans 03-03/03-04/03-05 assume. Executors must target `mobile/` and adapt the planned `app/...` paths accordingly.

**Next action:** provision external production credentials/data, then perform physical Android/iOS release QA and store submission.

**Phase gaps:** none in the v1 requirement set.

**Worktree harness bug:** the runtime does a non-exist-ok `mkdir .claude/worktrees`; before spawning a worktree agent, fully remove the empty `.claude/worktrees` parent dir (and prune `.git/worktrees/*`) or spawning fails with EEXIST.

**Open questions:** production MapKit/API domains, store signing identities and final real vendor catalog are deployment inputs rather than code gaps.

---

*State initialized: 2026-06-14*
*Last updated: 2026-08-03 — v1.0 implementation and verification complete*
