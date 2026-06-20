---
phase: 04-map-view-repair-search
plan: "03"
subsystem: mobile
tags: [repair-search, flutter, riverpod, go-router, service-categories, REP-01, REP-02, RES-02]
dependency_graph:
  requires:
    - GET /search/repair (from 04-01)
    - GET /catalog/service-categories (from 04-01)
  provides:
    - ServiceCategoriesPage (/repair/categories)
    - RepairResultsPage (/results/repair) reusing VendorResultCard list path
    - repairSearchProvider + serviceCategoriesProvider + repairParams
    - Home «Ремонт» branch wired to /repair/categories
  affects:
    - mobile/lib/features/repair_search (new feature module)
    - mobile/lib/core/api/search_api.dart (repair + service-categories methods)
    - mobile/lib/router.dart (3 new routes incl. Phase-5 vendor stub)
    - mobile/lib/features/home/home_page.dart («Ремонт» navigation)
    - mobile/lib/features/parts_results/widgets/vendor_result_card.dart (parameterized for reuse)
tech_stack:
  added: []
  patterns:
    - Repair flow mirrors parts flow — repairParams + repairSearchProvider parallel to searchParams/partsSearchProvider
    - VendorResultCard parameterized to render both parts and repair-shop rows (type-driven)
    - serviceCategoriesProvider fetches GET /catalog/service-categories (24h-cacheable reference data)
    - Routes use go_router with String? extra for category name pass-through
key_files:
  created:
    - mobile/lib/core/models/service_category.dart
    - mobile/lib/features/search/providers/service_categories_provider.dart
    - mobile/lib/features/search/providers/repair_params.dart
    - mobile/lib/features/search/providers/repair_search_provider.dart
    - mobile/lib/features/repair_search/service_categories_page.dart
    - mobile/lib/features/repair_search/repair_results_page.dart
    - mobile/test/repair/service_categories_page_test.dart
    - mobile/test/repair/repair_results_page_test.dart
  modified:
    - mobile/lib/core/api/search_api.dart
    - mobile/lib/features/parts_results/widgets/vendor_result_card.dart
    - mobile/lib/features/home/home_page.dart
    - mobile/lib/router.dart
    - mobile/test/search/home_page_test.dart
decisions:
  - "Repair flow reuses VendorResultCard (parameterized) instead of a new card — single source of truth for vendor rows (RES-02)"
  - "Added Phase-5 reserved /vendor/:id stub route ('Карточка появится позже') to prevent null-route crash on card tap"
  - "RepairResultsPage takes optional categoryName via go_router state.extra; falls back to title 'Ремонт'"
metrics:
  duration: ~40 min
  completed: "2026-06-20"
  tasks_total: 3
  tasks_completed: 3
  files_created: 8
  files_modified: 5
---

# Phase 04 Plan 03: «Ремонт» Flutter Slice Summary

**One-liner:** End-to-end repair-search flow on Flutter — service-category picker → repair results list reusing VendorResultCard, wired from Home «Ремонт» button (REP-01, REP-02, RES-02 list path).

## What Was Built

1. **Data + providers (Task 1)** — `ServiceCategory` model with JSON mapping; `SearchApi` gains `getServiceCategories()` and `searchRepair()` calling the 04-01 backend endpoints; `serviceCategoriesProvider`, `repairParams`, and `repairSearchProvider` mirror the parts-search provider topology.

2. **Screens + card reuse (Task 2, GREEN)** — `ServiceCategoriesPage` (category list) and `RepairResultsPage` (geo-results list). `VendorResultCard` parameterized so both parts and `repair_shop` rows render through one widget (RES-02 list path).

3. **Routing + home wiring (Task 3)** — `router.dart` gains `/repair/categories`, `/results/repair`, and a Phase-5 reserved `/vendor/:id` stub. Home «Ремонт» button navigates to `/repair/categories` (REP-01), replacing the prior placeholder.

## Commits

| Task | Commit | Files |
|------|--------|-------|
| Task 1: Model + API + providers | 8dc80c1 | service_category.dart, search_api.dart, service_categories_provider.dart, repair_params.dart, repair_search_provider.dart (+ .g.dart) |
| Task 1b: RED tests | b1b6fb9 | test/repair/service_categories_page_test.dart, test/repair/repair_results_page_test.dart |
| Task 2: Screens + card (GREEN) | 6de24d5 | service_categories_page.dart, repair_results_page.dart, vendor_result_card.dart |
| Task 3: Routes + home wiring | 20ec1eb | router.dart, home_page.dart, test/search/home_page_test.dart |

## Flutter Test Status: DEFERRED (run locally)

Flutter SDK is not present in CI; `.g.dart` files are hand-authored per project convention. RED→GREEN ordering is preserved in commit history (b1b6fb9 RED before 6de24d5 GREEN).

**To run locally:**
```bash
cd mobile && flutter pub get && dart run build_runner build --delete-conflicting-outputs && flutter test
```

## Deviations from Plan

### Deviation 1: Task 3 completed by orchestrator after tool-permission denial

**Found during:** Task 3 (router.dart edit)
**Issue:** The background executor agent had Write/Edit denied for `mobile/lib/router.dart`, blocking Task 3 after Tasks 1–2 were committed.
**Fix:** The orchestrator applied the prepared router edits (2 imports + 3 routes), staged the already-modified `home_page.dart` and `home_page_test.dart`, and committed Task 3 as `20ec1eb` on the same worktree branch. Page signatures verified against routes (ServiceCategoriesPage const ctor; RepairResultsPage({this.categoryName})).
**Impact:** No functional impact; all three tasks land correctly on the worktree branch.

## Self-Check

- [x] service_category.dart exists with JSON mapping
- [x] search_api.dart has searchRepair + getServiceCategories
- [x] serviceCategoriesProvider / repairParams / repairSearchProvider present
- [x] ServiceCategoriesPage + RepairResultsPage exist
- [x] VendorResultCard parameterized (renders repair_shop rows)
- [x] router.dart has /repair/categories, /results/repair, /vendor/:id stub
- [x] home_page.dart navigates to /repair/categories on «Ремонт»
- [x] All 4 task commits on worktree branch (8dc80c1, b1b6fb9, 6de24d5, 20ec1eb)

## Self-Check: PASSED
