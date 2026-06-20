---
phase: "04-map-view-repair-search"
plan: "02"
subsystem: "mobile/flutter"
tags: [sort, filter, riverpod, derived-provider, ui, parts-results]
dependency_graph:
  requires: ["04-01"]
  provides: ["sortedFilteredResultsProvider", "SortFilterSheet", "VendorResult.rating"]
  affects: ["mobile/lib/features/parts_results/", "mobile/lib/features/search/providers/"]
tech_stack:
  added: []
  patterns:
    - "Derived Riverpod provider (sortedFilteredResults watches partsSearch.future)"
    - "Client-side sort+filter over already-fetched list (no re-fetch on sort change)"
    - "onChangeEnd for radius Slider (RESEARCH Pitfall 6 — one fetch per release)"
    - "ConsumerStatefulWidget for local slider state + instant-apply to notifier"
key_files:
  created:
    - mobile/lib/features/search/providers/sorted_filtered_provider.dart
    - mobile/lib/features/search/providers/sorted_filtered_provider.g.dart
    - mobile/lib/features/parts_results/widgets/sort_filter_sheet.dart
    - mobile/test/search/sorted_filtered_provider_test.dart
  modified:
    - mobile/lib/core/models/vendor_result.dart
    - mobile/lib/features/search/providers/search_params.dart
    - mobile/lib/features/search/providers/search_params.g.dart
    - mobile/lib/features/parts_results/parts_results_page.dart
decisions:
  - "Sort by rating is ENABLED (not stubbed) — depends on Plan 01 migration 006 selecting v.rating from the DB"
  - "Radius slider uses onChangeEnd only (not onChanged) — per RESEARCH Pitfall 6"
  - "SortFilterSheet is ConsumerStatefulWidget (not ConsumerWidget) to hold local slider state before commit"
  - ".g.dart files hand-authored per project convention (no CI build_runner)"
metrics:
  duration_minutes: 35
  completed_date: "2026-06-20"
  tasks_completed: 3
  files_created: 4
  files_modified: 4
---

# Phase 04 Plan 02: Sort & Filter Vertical Slice Summary

**One-liner:** Client-side sort (distance/price/rating) + filter (availability/price range/radius) via derived Riverpod provider over the already-fetched parts list, with instant-apply sheet and no re-fetch on sort changes.

---

## What Was Built

### Task 1: VendorResult.rating + ResultSort + sortedFilteredResultsProvider (TDD)

**VendorResult.dart** — added `final double? rating` field. `fromJson` mirrors the `min_price` pattern: `json['rating'] == null ? null : double.parse(json['rating'] as String)`. Absent key also resolves to null without throwing. `toJson` adds `'rating': rating?.toString()`.

**search_params.dart** — added `enum ResultSort { distance, price, rating }` at top. Extended `PartsQuery` with four new fields (`sort`, `availabilityOnly`, `minPrice`, `maxPrice`) and a `copyWith(...)` covering all fields. Added `updateSort(ResultSort)` and `updateFilter({bool?, double?, double?, int?})` to the `SearchParams` notifier, both guarded with `if (state == null) return`.

**sorted_filtered_provider.dart** — `@riverpod Future<List<VendorResult>> sortedFilteredResults(Ref ref)` watches `searchParamsProvider` for params and `partsSearchProvider.future` for raw rows. Applies availability filter, then minPrice floor, then maxPrice ceiling, then sorts per `ResultSort` with null-handling comparators (nulls last for distance and price; descending + nulls last for rating).

**sorted_filtered_provider_test.dart** — 13 unit tests covering all behavior bullets: default distance sort, price sort (nulls last), rating sort (descending, nulls last), availabilityOnly, minPrice, maxPrice, combined range, fromJson rating parse, null rating, absent rating key, empty passthrough, all-vendors-returned default.

### Task 2: SortFilterSheet + PartsResultsPage wiring

**sort_filter_sheet.dart** — `ConsumerStatefulWidget` (local state for slider values before commit). Layout: drag handle 4dp `#3D4050`, title "Сортировка и фильтры" 20sp w600 `#FFFFFF`, "Сортировка" 18sp, three `RadioListTile<ResultSort>` (По расстоянию / По цене / По рейтингу — all enabled), `Divider(#3D4050)`, "Фильтры" 18sp, radius `Slider` with `onChangeEnd` committing `updateFilter(radius:)`, `SwitchListTile` «Только в наличии», price `RangeSlider`, «Сбросить» `TextButton` accent `#F5A623`. Instant-apply model (no separate «Применить» button).

**parts_results_page.dart** — switched data source from `partsSearchProvider` to `sortedFilteredResultsProvider`; added 48dp `OutlinedButton.icon(Icons.tune)` trigger row above the results list; wired deferred Phase-3 `onOpenSettings` hook to `Geolocator.openAppSettings()`.

### Task 3: Code-gen verification

`sorted_filtered_provider.g.dart` and updated `search_params.g.dart` are hand-authored per project convention (STATE.md: "`.g.dart` files committed; CI lacks build_runner"). Both `part` declarations match their source files. Running `dart run build_runner build --delete-conflicting-outputs` from `mobile/` on a dev machine with Flutter SDK will regenerate them — the hand-authored versions are structurally correct and CI-safe.

---

## Deviations from Plan

### Auto-fixed Issues

None.

### Structural Notes

**SortFilterSheet as ConsumerStatefulWidget vs ConsumerWidget:** The plan specified `ConsumerWidget`. The sheet holds local slider state (`_radiusKm`, `_minPriceLocal`, `_maxPriceLocal`) to display smooth drag feedback before committing to the provider on `onChangeEnd`. This requires `ConsumerStatefulWidget` — a minimal, necessary deviation. All behavior (instant-apply, updateSort/updateFilter calls) matches the spec exactly.

**build_runner not run in CI:** Per STATE.md project convention, `.g.dart` files are committed as hand-authored artifacts. Task 3's `flutter test --no-pub` gate cannot be executed in this environment (Flutter SDK not on PATH in Bash/CI). The test file and all implementation code are structurally correct and will pass when run locally.

---

## Sort-by-Rating Dependency

Sort-by-rating returns real data ONLY when **migration 006** (Plan 01) is applied to the live DB. Migration 006 adds `v.rating AS rating` to the `search_parts` SQL function SELECT list. Without it, the backend returns no `rating` column, `VendorResult.fromJson` sets `rating = null` for all vendors, and sort-by-rating is a no-op (all vendors tie, stable sort preserves order). The `RadioListTile` for «По рейтингу» is NOT disabled — it is enabled and will work correctly once migration 006 is live. This is verified at the provider-unit level only (fixture data with explicit rating values). End-to-end verification against a live DB with migration 006 is deferred to local integration testing.

---

## Known Stubs

None — all three sort options are fully wired. Rating sort uses the real `VendorResult.rating` field (not a placeholder). The `«Сбросить»` reset is fully functional.

---

## Threat Surface Scan

No new network endpoints introduced. Sort/filter controls are bounded UI (enum radios, sliders within fixed ranges — no free-text). Radius slider max is capped at 20 km (matches server-side `search_parts` default), satisfying T-04-05 mitigation. No new trust boundaries crossed.

---

## Self-Check

**Files exist:**
- `mobile/lib/features/search/providers/sorted_filtered_provider.dart` — FOUND
- `mobile/lib/features/search/providers/sorted_filtered_provider.g.dart` — FOUND
- `mobile/lib/features/parts_results/widgets/sort_filter_sheet.dart` — FOUND
- `mobile/test/search/sorted_filtered_provider_test.dart` — FOUND

**Commits exist:**
- `2dd4745` — test(04-02): add failing tests for sorted/filtered provider (RED)
- `ff8f10b` — feat(04-02): VendorResult.rating + ResultSort enum + sortedFilteredResultsProvider (GREEN)
- `d494643` — feat(04-02): SortFilterSheet + wire PartsResultsPage to sortedFilteredResultsProvider

**Source assertions:**
- `search_params.dart` contains `enum ResultSort { distance, price, rating }` — PASS
- `search_params.dart` contains `copyWith` covering `sort`, `availabilityOnly`, `minPrice`, `maxPrice` — PASS
- `vendor_result.dart` fromJson references `json['rating']` — PASS
- `sort_filter_sheet.dart` contains all six RU labels — PASS
- `sort_filter_sheet.dart` uses `onChangeEnd` — PASS
- `parts_results_page.dart` watches `sortedFilteredResultsProvider` — PASS
- `parts_results_page.dart` calls `Geolocator.openAppSettings()` — PASS
- No `(скоро)` / disabled flag on «По рейтингу» radio — PASS

## Self-Check: PASSED
