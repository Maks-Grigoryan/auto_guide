---
phase: 04-map-view-repair-search
plan: "01"
subsystem: backend
tags: [repair-search, service-categories, postgis, migration, nestjs, e2e]
dependency_graph:
  requires: []
  provides:
    - GET /search/repair (wraps search_repair SQL function)
    - GET /catalog/service-categories (seeded service categories)
    - rating column in search_parts + search_repair (RES-04)
  affects:
    - db/migrations (adds 006)
    - backend/src/search (SearchRepairDto, searchRepair method, /repair endpoint)
    - backend/src/catalog (ServiceCategory interface, getServiceCategories, /service-categories endpoint)
    - backend/test/search.e2e-spec.ts (repair block appended)
    - backend/test/catalog.e2e-spec.ts (service-categories block appended)
tech_stack:
  added: []
  patterns:
    - SearchRepairDto mirrors SearchPartsDto decorator stack (class-validator + class-transformer)
    - searchRepair aliases service_count AS item_count and 'repair_shop' AS type to reuse VendorSearchResult
    - Service-categories cached 24h via @Header decorator (same as makes/generations/part-categories)
    - Migration 006 uses CREATE OR REPLACE — does not touch applied migrations 003/005
key_files:
  created:
    - db/migrations/006_add_rating_to_search_functions.sql
    - backend/src/search/dto/search-repair.dto.ts
  modified:
    - backend/src/search/search.service.ts
    - backend/src/search/search.controller.ts
    - backend/src/catalog/catalog.service.ts
    - backend/src/catalog/catalog.controller.ts
    - backend/test/search.e2e-spec.ts
    - backend/test/catalog.e2e-spec.ts
decisions:
  - "searchRepair SQL aliases columns to reuse VendorSearchResult unchanged — avoids interface proliferation"
  - "Migration 006 adds rating via CREATE OR REPLACE on both functions — does not touch applied 003/005"
  - "DoS radius cap @Max(100000) on SearchRepairDto — mirrors SearchPartsDto mitigation (T-04-01)"
metrics:
  duration: ~25 min
  completed: "2026-06-20"
  tasks_total: 3
  tasks_completed: 3
  files_created: 2
  files_modified: 6
---

# Phase 04 Plan 01: Repair Search Backend Slice Summary

**One-liner:** Repair-shop geo-search backend — GET /search/repair + GET /catalog/service-categories + migration 006 adding rating to both SQL functions.

## What Was Built

Three deliverables that together close the «Ремонт» backend gap and unblock the rating-sort RES-04 criterion:

1. **Migration 006** (`db/migrations/006_add_rating_to_search_functions.sql`) — `CREATE OR REPLACE` for both `search_parts` and `search_repair`, adding `rating numeric` to RETURNS TABLE, SELECT list, and GROUP BY. Applied on top of migrations 003/005 without editing them. Coordinate order `ST_MakePoint(p_lng, p_lat)` and ST_DWithin/ST_Distance separation preserved.

2. **Repair search backend slice** — `SearchRepairDto` (4 fields: lat/lng/radius with @Max(100000) DoS cap / serviceCategoryId), `SearchService.searchRepair()` parametrized query aliasing `service_count AS item_count` and `'repair_shop' AS type` so `VendorSearchResult` stays unchanged, and `GET /search/repair` handler in `SearchController`.

3. **Service categories endpoint** — `ServiceCategory` interface, `CatalogService.getServiceCategories()` running `SELECT id, name FROM service_categories ORDER BY name`, and `GET /catalog/service-categories` handler with `Cache-Control: public, max-age=86400` in `CatalogController`.

## Commits

| Task | Commit | Files |
|------|--------|-------|
| Task 1: Migration 006 | 24b81c7 | db/migrations/006_add_rating_to_search_functions.sql |
| Task 2: Backend slice | 0671af1 | search-repair.dto.ts, search.service.ts, search.controller.ts, catalog.service.ts, catalog.controller.ts |
| Task 3: e2e specs | 4388f31 | test/search.e2e-spec.ts, test/catalog.e2e-spec.ts |

## Backend E2E Status: DEFERRED

E2e tests require a live PostGIS DB (Docker not available in CI/worktree environment). This is consistent with the Phase 3 deferred-e2e pattern documented in STATE.md. The spec files are written and committed.

**To run locally:**
```bash
# 1. Apply migration 006 first (adds rating column — required by the endpoint)
cd backend && npm run migrate:up

# 2. Run the e2e suite
npm run test:e2e -- --testPathPattern="search|catalog"
```

**What to expect when PostGIS is available:**
- `GET /search/repair?lat=40.1872&lng=44.5152&radius=50000` → 200, JSON array of repair shop rows
- `GET /search/repair` with missing lat → 400
- `GET /search/repair` with radius=150000 → 400 (DoS cap)
- Each row: `type === 'repair_shop'`, `item_count` is numeric string
- `GET /catalog/service-categories` → 200, array containing «Развал-схождение», Cache-Control header

## Threat Model Coverage

| Threat ID | Mitigation | Status |
|-----------|------------|--------|
| T-04-01 | `@Max(100000)` on radius in SearchRepairDto | Implemented + e2e asserts radius=150000 → 400 |
| T-04-02 | Parametrized `pool.query('... search_repair($1,$2,$3,$4)', [...])` | Implemented — no string concatenation |
| T-04-03 | class-validator @IsNumber/@Min/@Max + global ValidationPipe whitelist | Implemented |
| T-04-04 | Public reference data / geo data, no PII, accepted per threat register | Accepted |

## Deviations from Plan

### Deviation 1: Accidental cwd-drift commit to master reverted

**Found during:** Task 1 commit
**Issue:** When using an explicit `cd` to the main repo path for the first git add/commit, the commit landed on `master` instead of the worktree branch `worktree-agent-a4f282bbbed5e60fa`.
**Fix:** Immediately reverted the accidental commit on master with `git revert e63be04` (commit `61a7bba`). All subsequent work used the shell's default cwd (the worktree) without explicit `cd` to the main repo path.
**Impact:** No functional impact; the revert is on master and the task commit landed correctly on the worktree branch at `24b81c7`.

### Deviation 2: node_modules symlink for tsc check

**Found during:** Task 2 verification
**Issue:** The worktree's `backend/` directory has no `node_modules` (not installed at worktree creation time). `tsc --noEmit` fails with "Cannot find module" for all npm packages.
**Fix:** Created a symlink `backend/node_modules -> /c/Users/User/OneDrive/Desktop/avto/backend/node_modules`. The symlink is not tracked by git (listed in .gitignore implicitly as node_modules). `tsc --noEmit` exits 0 after the symlink.
**Files modified:** None (symlink only, untracked).

## Known Stubs

None. All endpoints query live DB; no placeholder return values.

## Self-Check

- [x] `db/migrations/006_add_rating_to_search_functions.sql` exists with 2x `v.rating AS rating`
- [x] `backend/src/search/dto/search-repair.dto.ts` exists with `@Max(100000)` on radius
- [x] `backend/src/search/search.service.ts` contains `searchRepair` + `service_count AS item_count`
- [x] `backend/src/search/search.controller.ts` contains `@Get('repair')`
- [x] `backend/src/catalog/catalog.service.ts` contains `ServiceCategory` + `getServiceCategories`
- [x] `backend/src/catalog/catalog.controller.ts` contains `@Get('service-categories')` + `@Header('Cache-Control', ...)`
- [x] `backend/test/search.e2e-spec.ts` contains `describe('GET /search/repair (e2e)')` + `radius: 150000` DoS test
- [x] `backend/test/catalog.e2e-spec.ts` contains «Развал-схождение» assertion
- [x] All 3 task commits exist on worktree branch (24b81c7, 0671af1, 4388f31)
- [x] `tsc --noEmit` exits 0
- [x] VendorSearchResult interface unchanged

## Self-Check: PASSED
