---
phase: 04-map-view-repair-search
reviewed: 2026-06-20T00:00:00Z
depth: standard
files_reviewed: 28
files_reviewed_list:
  - backend/src/catalog/catalog.controller.ts
  - backend/src/catalog/catalog.service.ts
  - backend/src/search/dto/search-repair.dto.ts
  - backend/src/search/search.controller.ts
  - backend/src/search/search.service.ts
  - backend/test/catalog.e2e-spec.ts
  - backend/test/search.e2e-spec.ts
  - db/migrations/006_add_rating_to_search_functions.sql
  - mobile/lib/core/api/search_api.dart
  - mobile/lib/core/map/map_config.dart
  - mobile/lib/core/models/service_category.dart
  - mobile/lib/core/models/vendor_result.dart
  - mobile/lib/features/home/home_page.dart
  - mobile/lib/features/parts_results/parts_results_page.dart
  - mobile/lib/features/parts_results/widgets/map_unavailable_notice.dart
  - mobile/lib/features/parts_results/widgets/results_map_view.dart
  - mobile/lib/features/parts_results/widgets/results_view_toggle.dart
  - mobile/lib/features/parts_results/widgets/sort_filter_sheet.dart
  - mobile/lib/features/parts_results/widgets/vendor_result_card.dart
  - mobile/lib/features/parts_results/widgets/vendor_summary_sheet.dart
  - mobile/lib/features/repair_search/repair_results_page.dart
  - mobile/lib/features/repair_search/service_categories_page.dart
  - mobile/lib/features/search/providers/repair_params.dart
  - mobile/lib/features/search/providers/repair_search_provider.dart
  - mobile/lib/features/search/providers/search_params.dart
  - mobile/lib/features/search/providers/service_categories_provider.dart
  - mobile/lib/features/search/providers/sorted_filtered_provider.dart
  - mobile/lib/main.dart
  - mobile/lib/router.dart
  - mobile/pubspec.yaml
  - mobile/test/repair/repair_results_page_test.dart
  - mobile/test/repair/service_categories_page_test.dart
  - mobile/test/search/home_page_test.dart
  - mobile/test/search/results_view_toggle_test.dart
  - mobile/test/search/sorted_filtered_provider_test.dart
findings:
  critical: 2
  warning: 6
  info: 4
  total: 12
status: issues_found
resolved:
  - "CR-01 (map distance label int/double compile error) — FIXED: _formatDistance(double) + .round()"
  - "CR-02 (price filter/«Сбросить» silent no-op) — FIXED: clearMinPrice/clearMaxPrice sentinels in copyWith+updateFilter, sort_filter_sheet wired, regression test added"
  - "WR-03 (VendorSearchResult missing rating) — FIXED: rating: string | null added; backend tsc green"
deferred:
  - "WR-01, WR-02, WR-04, WR-05, WR-06 + IN-01..04 — non-blocking; tracked for follow-up (WR-05/.g.dart hash resolves on local build_runner; WR-06 repair sort/filter is a documented Phase-04 deferral)"
---

# Phase 4: Code Review Report

> **Resolution (2026-06-20):** Both Critical findings (CR-01, CR-02) and WR-03 were fixed
> in commit `fix(04)` before phase close. Remaining Warnings/Info are non-blocking and tracked.
> Mobile fixes verified by source review (Flutter SDK absent in CI); backend fix verified by `tsc --noEmit` (exit 0).

**Reviewed:** 2026-06-20
**Depth:** standard
**Files Reviewed:** 28 (source) + tests
**Status:** issues_found

## Summary

Phase 04 ships three vertical slices: the repair-search backend (NestJS + PostGIS),
client-side sort/filter via a derived Riverpod provider, and the Yandex MapKit
list⇄map toggle behind D-04 graceful degradation.

The backend slice is the strongest part: queries are correctly parametrized
(`search_repair($1,$2,$3,$4)`), the DoS radius cap (`@Max(100000)`) is present on
`SearchRepairDto`, coordinate order in migration 006 (`ST_MakePoint(p_lng, p_lat)`)
is correct, and `ST_DWithin`/`ST_Distance` are correctly separated. No SQL injection
surface was found. D-04 degradation in `main.dart`/`map_config.dart` is correctly
guarded — an empty or failing key cannot crash the app.

However, two BLOCKERs prevent the map and filter slices from working as specified:

1. A **type mismatch** in `results_map_view.dart` (`_formatDistance(int)` called with
   a `double`) is a static compile error — the map view will not build. Because the
   Flutter SDK is not in CI, this was never caught.
2. The **filter reset / range-slider-clear is a silent no-op** because `updateFilter`
   relies on `copyWith`'s `??` semantics, which cannot distinguish "set to null" from
   "leave unchanged." Once a price floor/ceiling is set, it can never be cleared, and
   «Сбросить» does not reset price filters. This is a data-correctness defect: the user
   sees a wrong (over-filtered) result set with no way to recover except restarting the search.

Six WARNINGs cover a dead accessibility/UX path (location-denied banner can never
render), raw enum values leaking into the UI as Russian-facing text, and a backend
interface type drift (`rating` selected but absent from the TS interface).

## Critical Issues

### CR-01: Map distance label fails to compile — `int` parameter fed a `double`

**File:** `mobile/lib/features/parts_results/widgets/results_map_view.dart:161,181`
**Issue:**
`_configureMarker` calls `_formatDistance(v.distanceM)`, but `VendorResult.distanceM`
is declared `final double distanceM` (`vendor_result.dart:28`). `_formatDistance` is
declared `String _formatDistance(int distanceM)`. In Dart, `double` is not assignable
to `int`, so this is a static type error: the entire mobile target will fail
`flutter analyze` / `flutter build`. The map view (RES-03 distance label) cannot run.
This slipped through because the Flutter SDK is absent in CI and `.g.dart` files are
hand-authored, so no compile step executed.

Secondary defect: even if the type were coerced, the sub-1 km branch uses
`'$distanceM м'` without `.round()`, so it would render `'523.4 м'` instead of the
spec's `'523 м'` (compare the correct `DistanceBadge._label` which uses `.round()`).

**Fix:**
```dart
String _formatDistance(double distanceM) {
  if (distanceM < 1000) return '${distanceM.round()} м';
  final km = distanceM / 1000.0;
  return '${km.toStringAsFixed(1)} км';
}
```

### CR-02: Price filter and «Сбросить» reset are silent no-ops — filters cannot be cleared

**File:** `mobile/lib/features/search/providers/search_params.dart:55-83,129-142`; `mobile/lib/features/parts_results/widgets/sort_filter_sheet.dart:56-70,205-214`
**Issue:**
`PartsQuery.copyWith` uses the `field ?? this.field` idiom for every nullable field:

```dart
minPrice: minPrice ?? this.minPrice,
maxPrice: maxPrice ?? this.maxPrice,
```

With this idiom, passing `null` is indistinguishable from "not provided" — it always
preserves the existing value. `updateFilter` forwards `null` for omitted args, so:

- `_reset()` calls `updateFilter(minPrice: null, maxPrice: null)` (sort_filter_sheet.dart:59-63).
  This is a **no-op** for the price filter: once a floor/ceiling is set, «Сбросить»
  cannot clear it. The local slider visuals reset, but the provider state (and therefore
  the actual filtered result set) keeps the stale price bounds.
- The RangeSlider `onChanged` (sort_filter_sheet.dart:210-213) passes
  `minPrice: range.start > 0 ? range.start : null`. Dragging the lower handle back to 0
  sends `minPrice: null`, which is ignored — the previous non-zero floor sticks. Same for
  `maxPrice` when dragging the upper handle to max. The user cannot widen a price range
  once narrowed.

Net effect: the result set stays over-filtered and the user has no in-app way to recover
(short of re-submitting the whole search), directly violating RES-05 ("results update
without full page reload") and the «Сбросить» contract claimed in 04-02-SUMMARY.md.

Note the same `??` pattern affects `availabilityOnly` only benignly (it is a non-null
`bool`, so `false ?? x == false` works), but `minPrice`/`maxPrice` are genuinely nullable
and broken.

**Fix:** Use sentinel-based clearing so `null` is an explicit value. One option:
```dart
// search_params.dart — explicit-clear flags
PartsQuery copyWith({
  // ...
  bool clearMinPrice = false,
  bool clearMaxPrice = false,
  double? minPrice,
  double? maxPrice,
}) {
  return PartsQuery(
    // ...
    minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
    maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
  );
}

void updateFilter({
  bool? availabilityOnly,
  double? minPrice,
  double? maxPrice,
  int? radius,
  bool clearMinPrice = false,
  bool clearMaxPrice = false,
}) {
  if (state == null) return;
  state = state!.copyWith(
    availabilityOnly: availabilityOnly,
    minPrice: minPrice,
    maxPrice: maxPrice,
    radius: radius,
    clearMinPrice: clearMinPrice,
    clearMaxPrice: clearMaxPrice,
  );
}
```
Then `_reset()` calls `updateFilter(clearMinPrice: true, clearMaxPrice: true, availabilityOnly: false)`
and the slider passes `clearMinPrice: range.start == 0`. Add a regression unit test that
sets then clears a price bound.

## Warnings

### WR-01: Location-denied banner in PartsResultsPage is dead code — can never render

**File:** `mobile/lib/features/parts_results/parts_results_page.dart:53-55,132-141`; `mobile/lib/router.dart:55-58`
**Issue:**
`PartsResultsPage._locationDenied` gates a `LocationDeniedView` banner on
`widget.locationStatus`. But the only route that constructs the page
(`/results/parts`, router.dart:57) uses `const PartsResultsPage()`, which falls back
to the constructor default `locationStatus = LocationResultStatus.granted`. The actual
resolved status from `home_page.dart:_resolveLocationAndSearch` is never threaded
through (it surfaces only as a transient SnackBar on the Home screen). Therefore
`_locationDenied` is always `false` and the banner — including the "open settings"
recovery path — is unreachable dead code. Users who denied location see a Yerevan-
fallback result set on the results screen with no in-context indication or recovery
affordance.

**Fix:** Either pass the status through navigation (e.g. `context.push('/results/parts', extra: result.status)`
and read it in the route builder), or read a shared location-status provider inside
`PartsResultsPage` instead of relying on the constructor argument. If the banner is
intentionally deferred, remove the dead `_locationDenied`/`LocationDeniedView` wiring
to avoid the false impression of coverage.

### WR-02: Raw vendor `type` enum leaks into the UI as user-facing text

**File:** `mobile/lib/features/parts_results/widgets/vendor_result_card.dart:88-93`; `mobile/lib/features/parts_results/widgets/vendor_summary_sheet.dart:103-109`
**Issue:**
Both the list card and the marker summary sheet render `vendor.type` directly as the
"shop type" line. For repair results the backend aliases `'repair_shop' AS type`
(search.service.ts:44) and parts rows carry `'parts_shop'`, so the user sees the raw
machine token «repair_shop» / «parts_shop» as a label. This is shown to an audience that
explicitly includes non-technical/elderly users (CLAUDE.md UX constraint). It is a
correctness/clarity defect, not just style.

**Fix:** Map `type` to a localized human label before display, e.g.
```dart
String _typeLabel(String type) => switch (type) {
  'repair_shop' => 'Автосервис',
  'parts_shop' => 'Магазин запчастей',
  _ => type,
};
```
and render `_typeLabel(vendor.type)`.

### WR-03: `VendorSearchResult` interface omits `rating` although the SQL selects it

**File:** `backend/src/search/search.service.ts:7-18,42-50`
**Issue:**
Migration 006 adds `rating` to both functions, and `searchRepair` explicitly selects
`... min_price, rating`. `searchParts` uses `SELECT *`, so it too now returns a `rating`
column. But the `VendorSearchResult` interface (lines 7-18) has no `rating` field. The
rows are typed `VendorSearchResult`, so `rating` is present at runtime (and correctly
serialized to the client, which the Flutter model consumes) yet invisible to the type
system. Any backend code that later reads `row.rating` would fail to type-check, and the
interface no longer documents the true response shape — a maintainability/contract drift
that undermines the rating-sort feature this migration was created for.

**Fix:** Add `rating: string | null;` to the `VendorSearchResult` interface to match the
NUMERIC column (pg returns NUMERIC as string, consistent with `min_price`).

### WR-04: ServiceCategoriesPage error UI swallows the underlying error

**File:** `mobile/lib/features/repair_search/service_categories_page.dart:36-38`; `mobile/lib/features/repair_search/repair_results_page.dart:59-61`; `mobile/lib/features/parts_results/parts_results_page.dart:75-77`
**Issue:**
Every `.when(error: (_, __) => ...)` discards both the error object and stack trace.
While a generic `ErrorView` is acceptable for the user, dropping the error entirely
means there is no logging/telemetry hook anywhere on the repair or parts result paths.
Per the project error-handling rule ("never silently swallow errors; log detailed error
context"), at minimum the error should be logged before showing the generic view. This
matters for diagnosing the deferred live-DB integration (e.g. a 400 from a bad
`serviceCategoryId` would be indistinguishable from a network failure).

**Fix:** Capture and log the error, e.g. `error: (e, st) { debugPrint('serviceCategories failed: $e'); return ErrorView(...); }`,
or route through a shared logging utility.

### WR-05: `map_config.g.dart` contains a fabricated provider hash

**File:** `mobile/lib/core/map/map_config.g.dart:51`
**Issue:**
`_$mapAvailableHash()` returns the literal `r'a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0'`.
This is a hand-typed placeholder, not a real content hash. Riverpod uses these hashes
for hot-reload provider-identity diffing; a stale/fake hash can cause incorrect
hot-reload behavior in development. It is tolerable under the documented "`.g.dart`
hand-authored, no build_runner in CI" convention, but it is a latent correctness risk
that will be silently overwritten (and could mask a real diff) the first time
`build_runner` runs locally. Flagging so it is regenerated before any release build.

**Fix:** Run `dart run build_runner build --delete-conflicting-outputs` locally and commit
the real generated hashes for all `.g.dart` files prior to a release build; do not rely on
hand-typed hash literals.

### WR-06: Repair flow has no sort/filter surface despite reusing the shared results page

**File:** `mobile/lib/features/repair_search/repair_results_page.dart:62-90`
**Issue:**
`RepairResultsPage` reads `repairSearchProvider` directly (unsorted/unfiltered) and does
not host the «Сортировка и фильтры» trigger that `PartsResultsPage` has. The phase
research (REP-01/REP-02 parity, RES-04 "sort by distance/price/rating") and 04-UI-SPEC
frame the results surface as shared and parameterized. The result is an inconsistent UX:
repair results cannot be sorted by rating/price or filtered, even though the data
(`rating`, `min_price`) is present on the repair rows. If this asymmetry is intentional
for Phase 04 it should be documented as a deferred item; as written it reads as an
incomplete parity implementation.

**Fix:** Either introduce a repair-side derived sort/filter provider mirroring
`sortedFilteredResultsProvider` and host the same `SortFilterSheet` trigger, or explicitly
document the repair-path sort/filter omission as deferred in the phase summary.

## Info

### IN-01: `_ruItemCount` / `_ruServiceCount` duplicated across two widgets

**File:** `mobile/lib/features/parts_results/widgets/vendor_result_card.dart:7-25`; `mobile/lib/features/parts_results/widgets/vendor_summary_sheet.dart:8-25`
**Issue:** The Russian pluralization helpers are copy-pasted verbatim into both files.
DRY violation — a fix to plural rules must be made in two places.
**Fix:** Extract to a shared utility (e.g. `core/format/ru_plural.dart`) and import in both.

### IN-02: `ResultsMapView` marker re-render relies on referential inequality

**File:** `mobile/lib/features/parts_results/widgets/results_map_view.dart:42-49`; `mobile/lib/features/parts_results/parts_results_page.dart:190`
**Issue:** `didUpdateWidget` re-places markers only when `oldWidget.vendors != widget.vendors`
(reference comparison). The page always passes `List.of(results)`, creating a new list
instance each build, so the guard is effectively "always true" and markers are rebuilt on
every parent rebuild. Functionally correct but wasteful and the guard gives a false
impression of change-detection. Consider comparing by content (e.g. vendor ids) or
accepting unconditional rebuild and removing the misleading guard.

### IN-03: `PartsQuery.isEmpty` is defined but never used

**File:** `mobile/lib/features/search/providers/search_params.dart:52`
**Issue:** `bool get isEmpty => ...` has no callers in the reviewed scope. Dead accessor.
Its definition (`lat == 0 && lng == 0 && ...`) is also a fragile equality check on doubles.
**Fix:** Remove if unused, or wire it where an "empty query" guard is actually needed.

### IN-04: `searchApiProvider` imported via comment-justified side-channel

**File:** `mobile/lib/features/search/providers/repair_search_provider.dart:4`; `mobile/lib/features/search/providers/service_categories_provider.dart:4`
**Issue:** Both new providers import `categories_provider.dart` solely "for searchApiProvider",
coupling unrelated repair/service-category providers to the parts categories module. Minor
cohesion smell — the shared `searchApiProvider` would be better hosted in a neutral
`core/api/` provider file.
**Fix:** Relocate `searchApiProvider` to a dedicated DI module (e.g. `core/api/search_api_provider.dart`)
and import it from there.

---

_Reviewed: 2026-06-20_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
