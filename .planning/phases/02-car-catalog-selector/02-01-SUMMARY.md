---
phase: 02-car-catalog-selector
plan: "01"
subsystem: backend-catalog
tags: [nestjs, catalog, geo, cache, postgresql, tdd]
dependency_graph:
  requires: [01-foundation]
  provides: [catalog-api-endpoints]
  affects: [02-03-flutter-car-selector]
tech_stack:
  added: []
  patterns: [pg-pool-raw-sql, nestjs-module, cache-control-header, class-validator-dto]
key_files:
  created:
    - backend/src/catalog/catalog.controller.ts
    - backend/src/catalog/catalog.service.ts
    - backend/src/catalog/catalog.module.ts
    - backend/src/catalog/dto/get-models.dto.ts
    - backend/src/catalog/dto/get-generations.dto.ts
    - backend/test/catalog.e2e-spec.ts
    - backend/tsconfig.test.json
  modified:
    - backend/src/app.module.ts
    - backend/test/jest-e2e.json
    - backend/package.json
decisions:
  - Used hardcoded seeded IDs (ВАЗ makeId=1, modelId=1) in e2e tests because ORDER BY name returns Audi first which has no seeded models
  - @Header decorator applied per-method (not class) to match plan Pitfall 4 requirement
  - Added @types/jest@29 dev dependency (was missing from package.json, breaking all e2e type compilation)
metrics:
  duration: "~20 minutes"
  completed: "2026-06-15"
  tasks: 2
  files: 9
---

# Phase 02 Plan 01: Catalog API Endpoints Summary

**One-liner:** Read-only NestJS catalog module exposing /makes, /models?makeId, /generations?modelId with 24h Cache-Control headers over seeded PostgreSQL tables.

## What Was Built

Three GET endpoints under the `/catalog` prefix backed by parametrized `pg.Pool` queries:

- `GET /catalog/makes` — returns `{id, name}[]` from `car_makes ORDER BY name`
- `GET /catalog/models?makeId=N` — returns `{id, make_id, name}[]` from `car_models WHERE make_id = $1`
- `GET /catalog/generations?modelId=N` — returns `{id, model_id, name, year_from, year_to}[]` from `car_generations WHERE model_id = $1`

Each route carries `Cache-Control: public, max-age=86400` via per-method `@Header` decorator.

Input validation: `makeId` and `modelId` are required positive integers (via `class-validator` + `@Type(() => Number)`). Missing or non-numeric values return HTTP 400 via the global `ValidationPipe`.

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Write failing catalog e2e spec (RED) | 7d08c46 | backend/test/catalog.e2e-spec.ts, jest-e2e.json, tsconfig.test.json |
| 2 | Implement CatalogModule (GREEN) | d0314c8 | catalog.controller.ts, catalog.service.ts, catalog.module.ts, 2 DTOs, app.module.ts |

## Verification

- All 7 e2e test cases pass with `DATABASE_URL=postgres://autoapp:autoapp@localhost:5432/autoapp npm run test:e2e -- --testPathPattern=catalog`
- `npm run build` compiles with no TypeScript errors
- `grep -c "@Header('Cache-Control', 'public, max-age=86400')" catalog.controller.ts` = 3
- `app.module.ts` imports `CatalogModule` after `SearchModule`

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Missing @types/jest caused all e2e tests to fail TypeScript compilation**
- **Found during:** Task 1 RED verification
- **Issue:** `@types/jest` was absent from `package.json` devDependencies; `it`, `describe`, `expect` were unknown TypeScript globals
- **Fix:** Installed `@types/jest@29`, created `tsconfig.test.json` extending `tsconfig.json` with `types: ["jest","node"]`, updated `jest-e2e.json` to reference `tsconfig.test.json` via `globals.ts-jest.tsconfig`
- **Files modified:** `package.json`, `backend/tsconfig.test.json`, `backend/test/jest-e2e.json`
- **Commit:** 7d08c46

**2. [Rule 1 - Bug] Test hardcoded first-make assumption broke generations test**
- **Found during:** Task 2 GREEN verification
- **Issue:** Test used `makes[0]` (ORDER BY name = "Audi") which has 0 seeded models, causing `expect(models.length).toBeGreaterThan(0)` to fail
- **Fix:** Updated generations and models tests to use hardcoded `makeId=1` (ВАЗ) and `modelId=1` (Приора) which are always seeded with data
- **Files modified:** `backend/test/catalog.e2e-spec.ts`
- **Commit:** d0314c8

## Known Stubs

None. All three endpoints are fully wired to the PostgreSQL database.

## Threat Flags

None. All threat model mitigations applied:
- T-02-01: Parametrized SQL (`$1`) + `@IsNumber/@IsPositive/@Type` via global ValidationPipe — implemented
- T-02-03: SafeExceptionFilter inherited from Phase 1 — no per-file work needed

## Self-Check: PASSED

- backend/src/catalog/catalog.controller.ts: exists
- backend/src/catalog/catalog.service.ts: exists
- backend/src/catalog/catalog.module.ts: exists
- backend/src/catalog/dto/get-models.dto.ts: exists
- backend/src/catalog/dto/get-generations.dto.ts: exists
- backend/test/catalog.e2e-spec.ts: exists
- Commits 7d08c46 and d0314c8: confirmed in git log
