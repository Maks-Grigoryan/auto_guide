---
phase: 03-parts-search-list-results
plan: "01"
subsystem: backend/search
tags: [backend, sql, nestjs, search, oem, geosearch]
dependency_graph:
  requires: [02-03]
  provides: [parts-search-8arg, oem-normalization, generation-filter]
  affects: [backend/src/search, db/migrations]
tech_stack:
  added: []
  patterns: [raw-pg-pool-sql, parametrized-query, class-validator-dto]
key_files:
  created:
    - db/migrations/005_oem_normalization_and_seed.sql
  modified:
    - backend/src/search/search.service.ts
    - backend/src/search/dto/search-parts.dto.ts
    - backend/test/search.e2e-spec.ts
decisions:
  - "Seed part oem_number=19216 given a whole-make VAZ fitment (model_id NULL) so it appears in search_parts INNER JOIN — without fitment the part is invisible to all geo-search queries"
  - "OEM normalization via regexp_replace in DB layer only (single source of truth, D-03)"
  - "radius @Max(100000) cap added to DTO (T-03-02 DoS mitigation)"
metrics:
  duration: "~25 min"
  completed: "2026-06-16"
  tasks_completed: 2
  files_changed: 4
---

# Phase 03 Plan 01: Fix Parts-Search Backend Core Summary

**One-liner:** Fixed 7-arg→8-arg search_parts call, added server-side OEM space/dash normalization via regexp_replace, and wired generationId + radius cap in the DTO — category browse, OEM lookup, and whole-make fitment all verified green by e2e.

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Migration 005 — 8-arg search_parts + normalized OEM + seed | 1a5e3b6 | db/migrations/005_oem_normalization_and_seed.sql |
| 2 | Fix service 8-arg call + generationId/radius cap DTO + e2e | 1ab4f3e | search.service.ts, search-parts.dto.ts, search.e2e-spec.ts, 005 migration (fitment fix) |

## Verification

- `node-pg-migrate up` applied migration 005 cleanly (exits 0)
- `npm run test:e2e -- search --forceExit`: **9/9 tests pass**
  - categoryId narrows results (regression guard for 8-arg fix)
  - OEM "192 16" (space) matches stored "19216"
  - OEM "192-16" (dash) matches stored "19216"
  - generationId param accepted (not stripped by whitelist)
  - radius=150000 rejected 400 (DoS cap)
  - makeId=1 (ВАЗ) returns whole-make NULL-model fitment parts (PRT-03)

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Seeded OEM part had no part_fitments row**

- **Found during:** Task 2 e2e run (OEM tests returned empty array)
- **Issue:** `search_parts` INNER JOINs `part_fitments`; the new oem-19216 part had no fitment so it was invisible to all geo-search queries.
- **Fix:** Added an idempotent fitment INSERT to migration 005 — whole-make ВАЗ (model_id NULL, generation_id NULL). Also applied the INSERT directly to the live DB since the migration had already been applied.
- **Files modified:** db/migrations/005_oem_normalization_and_seed.sql (seed section)
- **Commit:** 1ab4f3e (bundled with Task 2)

## Known Stubs

None — all behavior is wired to live DB data via parametrized SQL.

## Threat Surface Scan

No new network endpoints introduced. All mitigations from plan threat model applied:
- T-03-01: Parameterized `$1..$8` only; regexp_replace operates on bound params
- T-03-02: `@Max(100000)` on radius — verified by e2e (400 on radius=150000)
- T-03-03: generationId declared in DTO so whitelist:true passes it through

## Self-Check: PASSED

- `db/migrations/005_oem_normalization_and_seed.sql` — exists, contains `CREATE OR REPLACE FUNCTION search_parts`, `regexp_replace`, oem_number `19216`
- `backend/src/search/search.service.ts` — contains `search_parts($1,$2,$3,$4,$5,$6,$7,$8)`
- `backend/src/search/dto/search-parts.dto.ts` — contains `generationId` and `@Max(100000)`
- Commits 1a5e3b6 and 1ab4f3e confirmed in git log
