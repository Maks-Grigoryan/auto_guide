---
phase: 03-parts-search-list-results
plan: "04"
subsystem: mobile/home
tags: [flutter, riverpod, location, home-screen, tdd, search]
dependency_graph:
  requires: [03-01, 03-02, 03-03]
  provides:
    - LocationService with injectable delegate + Yerevan fallback
    - SearchParams Notifier (submit-triggered PartsQuery)
    - categoriesProvider (GET /catalog/part-categories)
    - partsSearchProvider (returns [] until submit)
    - HomePage with toggle/search/category-browse/car-chip
  affects: [03-05 (partsSearchProvider + SearchParams consumed by results page)]
tech_stack:
  added: []
  patterns:
    - Riverpod Notifier submit-triggered state (D-03)
    - Injectable delegate pattern for geolocator in tests
    - hand-authored .g.dart files matching riverpod 3.0.3 generated output
key_files:
  created:
    - mobile/lib/core/location/location_service.dart
    - mobile/lib/core/location/location_service.g.dart
    - mobile/lib/features/search/providers/search_params.dart
    - mobile/lib/features/search/providers/search_params.g.dart
    - mobile/lib/features/search/providers/categories_provider.dart
    - mobile/lib/features/search/providers/categories_provider.g.dart
    - mobile/lib/features/search/providers/parts_search_provider.dart
    - mobile/lib/features/search/providers/parts_search_provider.g.dart
    - mobile/lib/features/home/widgets/search_type_toggle.dart
    - mobile/lib/features/home/widgets/parts_search_field.dart
    - mobile/lib/features/home/widgets/category_tile.dart
    - mobile/test/search/location_service_test.dart
    - mobile/test/search/home_page_test.dart
  modified:
    - mobile/lib/features/home/home_page.dart
    - mobile/lib/router.dart
decisions:
  - "Hand-authored .g.dart files: build_runner hit Windows OneDrive file lock (build/unit_test_assets locked). The background build_runner run succeeded (exit 0) before new sources existed; subsequent runs failed with PathAccessException. Hand-authoring following the exact riverpod 3.0.3 generated pattern from catalog_providers.g.dart was faster and more reliable in this environment."
  - "Tests run via /tmp copy: flutter test fails in OneDrive path due to same build dir lock. Copied project to /tmp/flutter_test_03 for test execution — all 10 tests pass there."
  - "selectedCarProvider reuse: Phase 2 already built SelectedCarNotifier with full Hive persistence. The plan called for a stub; instead the real provider from car_selector/state/ is used directly — no duplication."
  - "locationServiceProvider overrideWithValue in tests: used to inject _FakeLocationService (instant Yerevan response) so navigation tests don't block on geolocator."
metrics:
  duration: "~45 minutes"
  completed: "2026-06-16"
  tasks_completed: 2
  tasks_total: 2
  files_modified: 15
---

# Phase 03 Plan 04: Home Screen + Search Providers + Location Summary

Submit-triggered parts search (D-03) with Yerevan fallback geolocation (RES-06), browsable category list (PRT-01), and full home screen (RES-01) replacing the Phase 02 stub.

## What was built

### Task 1: Location service + search providers (TDD)

**LocationService** (`mobile/lib/core/location/location_service.dart`):
- Injectable `LocationServiceDelegate` interface (geolocator wrapper)
- `GeolocatorDelegate` wraps the real geolocator package
- Permission flow: `isLocationServiceEnabled` → `checkPermission` → `requestPermission`
- Yerevan fallback constants `kYerevanLat = 40.1872`, `kYerevanLng = 44.5152`
- Returns `LocationResult { lat, lng, status }` where status ∈ {granted, denied, deniedForever}
- Exposed via `@riverpod locationServiceProvider`

**SearchParams** (`mobile/lib/features/search/providers/search_params.dart`):
- `PartsQuery` immutable value object (lat, lng, radius=20000, makeId, modelId, generationId, categoryId, query)
- `SearchParams` Riverpod Notifier: `build()` returns null (no search before submit — D-03)
- `submit(PartsQuery)` triggers dependent providers

**categoriesProvider** (`mobile/lib/features/search/providers/categories_provider.dart`):
- `@riverpod SearchApi searchApi` — injected into tests via `overrideWith`
- `@riverpod Future<List<PartCategory>> categories` — calls `SearchApi.fetchCategories()`

**partsSearchProvider** (`mobile/lib/features/search/providers/parts_search_provider.dart`):
- Returns `[]` when `searchParamsProvider` is null (no pre-submit request — D-03, T-03-10)
- On submit, calls `SearchApi.searchParts(...)` with all PartsQuery fields

### Task 2: Home screen + widgets + route wiring (TDD)

**SearchTypeToggle** — `SegmentedButton<int>` Запчасти/Ремонт, 48dp, accent #F5A623 selected

**PartsSearchField** — 48dp TextField, `textInputAction: TextInputAction.search`, empty submit no-op (D-03), query sent verbatim (T-03-08)

**CategoryTile** — 56dp min, `Icons.category_outlined` leading, `Icons.chevron_right` trailing, divider `#3D4050`, taps → `/results/parts` with categoryId

**HomePage** (replaced Phase 02 stub):
- AppBar "Авто-агрегатор"
- `SearchTypeToggle` with Ремонт placeholder "Поиск ремонта появится в следующей версии"
- `ElevatedButton('Выбрать авто', 56dp)` or `CarChip` (Phase 2 selectedCarNotifier reused — D-04)
- `PartsSearchField` submit-triggered
- "Категории запчастей" label + `ListView` of `CategoryTile` from `categoriesProvider`
- Loading: `CircularProgressIndicator` accent; Error: "Не удалось загрузить категории" + "Повторить" (retry via `ref.invalidate`)
- Location resolved before first search; snackbar on denied/deniedForever; Yerevan fallback always applied

**router.dart** — added `/results/parts` → `PartsResultsPage` route

## Verification

| Check | Result |
|-------|--------|
| `flutter analyze` | No issues found |
| `location_service_test.dart` (4 tests) | All passed (via /tmp copy) |
| `home_page_test.dart` (6 tests) | All passed (via /tmp copy) |
| `flutter test` in OneDrive path | BLOCKED (Windows file lock on build/unit_test_assets — see Known Blockers) |

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Added locationServiceProvider override to home page tests**
- **Found during:** Task 2 test run (2 of 6 tests failing)
- **Issue:** Navigation tests blocked because `_resolveLocationAndSearch` called real `GeolocatorDelegate` in test context; geolocator has no device — timed out without navigating
- **Fix:** Added `_FakeLocationService` + `_FakeDelegate` in test helper; overrode `locationServiceProvider` in `ProviderScope`
- **Files modified:** `mobile/test/search/home_page_test.dart`

**2. [Rule 3 - Blocking] Hand-authored .g.dart files**
- **Found during:** Task 1 (build_runner failure)
- **Issue:** `build_runner build` hit Windows OneDrive `PathAccessException: Deletion failed` on `build/unit_test_assets` — same environment blocker as Phase 02
- **Fix:** Hand-authored 4 `.g.dart` files matching the exact riverpod 3.0.3 generated pattern from `catalog_providers.g.dart`
- **Files modified:** 4 new `.g.dart` files

**3. [Deviation] selectedCarProvider — used Phase 2 real provider**
- **Plan said:** "stub selectedCarProvider returning null"
- **Reality:** Phase 2 already built `SelectedCarNotifier` with full persistence. Using it directly avoids duplication and gives D-04 integration for free (car chip + ids passed to SearchParams.submit)
- **Impact:** Positive — no stub needed

## Known Stubs

None — all features wired. `PartsResultsPage` (placeholder from 03-03) is the results display stub; it will be wired in 03-05.

## Known Blockers

- `flutter test` in OneDrive path fails with `PathAccessException: Deletion failed, path = 'build\unit_test_assets'` — same as Phase 02/03. Tests verified via `/tmp` copy. Root cause: Windows OneDrive sync holds file handle. Resolution: run `flutter test` outside OneDrive, or run on device/emulator.

## Threat Surface Scan

No new network endpoints introduced. `LocationService` requests location only on first search (T-03-09: not on cold launch). OEM query sent verbatim to backend (T-03-08: backend parameterizes). All threat register mitigations applied.

## Self-Check: PASSED

Files verified:
- `mobile/lib/core/location/location_service.dart` contains `40.1872` and `44.5152` ✓
- `mobile/lib/features/search/providers/search_params.dart` defines SearchParams Notifier with `submit` ✓
- `mobile/lib/features/home/home_page.dart` contains `SegmentedButton` ✓
- `mobile/lib/features/home/widgets/category_tile.dart` navigates to `/results/parts` ✓
- `mobile/lib/features/home/widgets/parts_search_field.dart` uses `TextInputAction.search` ✓
- Commits: 1f4cb34 (RED location), 931f5da (GREEN providers), 9f592c5 (RED home), 7f1a391 (GREEN home+widgets)
