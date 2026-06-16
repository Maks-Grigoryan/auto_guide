---
phase: 03-parts-search-list-results
plan: "05"
subsystem: mobile/features/parts_results
tags: [flutter, riverpod, ui, results, async-states, a11y]
dependency_graph:
  requires: ["03-04"]
  provides: [PartsResultsPage, DistanceBadge, VendorResultCard, EmptyResultsView, ErrorView, LocationDeniedView]
  affects: [mobile/lib/features/parts_results/, mobile/lib/router.dart]
tech_stack:
  added: []
  patterns: [AsyncValue.when, ConsumerWidget, ListView.builder, ConstrainedBox min-height]
key_files:
  created:
    - mobile/lib/features/parts_results/widgets/distance_badge.dart
    - mobile/lib/features/parts_results/widgets/vendor_result_card.dart
    - mobile/lib/features/parts_results/widgets/empty_results_view.dart
    - mobile/lib/features/parts_results/widgets/error_view.dart
    - mobile/lib/features/parts_results/widgets/location_denied_view.dart
    - mobile/test/search/vendor_result_card_test.dart
    - mobile/test/search/parts_results_page_test.dart
  modified:
    - mobile/lib/features/parts_results/parts_results_page.dart
decisions:
  - "LocationDeniedView is a non-blocking banner above the results list — Yerevan-fallback results render regardless of permission status (RES-06)"
  - "Error state uses local ErrorView (not the car_selector one) to keep parts_results self-contained; icons + text only, no raw exceptions (T-03-11)"
  - "Loading test uses Completer (not Future.delayed) to avoid pending-timer assertion from flutter_test"
metrics:
  duration: "~25 min"
  completed: "2026-06-16"
  tasks_completed: 2
  files_changed: 8
---

# Phase 03 Plan 05: Vendor Results Screen Summary

Ranked vendor results UI completing the parts-search vertical slice — distance-sorted VendorResultCard list with amber DistanceBadge, min-price row, RU plural item count, and all four async states (loading / empty / error / location-denied).

## Tasks Completed

| # | Name | Commit | Key Files |
|---|------|--------|-----------|
| 1 | DistanceBadge + VendorResultCard | 10c551c | distance_badge.dart, vendor_result_card.dart |
| 2 | Async state widgets + PartsResultsPage | fa8427d | empty_results_view.dart, error_view.dart, location_denied_view.dart, parts_results_page.dart |

## What Was Built

**DistanceBadge** — amber `#F5A623` container, `Icons.place` + distance text. Formats `<1000 m` as `{N} м`, `≥1000 m` as `{N.N} км` (one decimal). Text dark `#1C1F26` on amber — 9.0:1 contrast (ACC-01).

**VendorResultCard** — `#2A2D36` Card/InkWell, `ConstrainedBox(minHeight: 88)`, md padding, radius 12. Shop name 18 sp `#FFFFFF` max 2 lines ellipsis; shop type 16 sp `#E0E0E0`; price row with `Icons.sell_outlined` omitted entirely when `minPrice == null` (T-03-12); item count with `Icons.inventory_2_outlined` + RU plural (11-19 exception handled). Status via icon + text, never color-alone (ACC-02).

**EmptyResultsView** — `Icons.search_off` + "Ничего не найдено" + body + "Назад к категориям" TextButton. Empty array (including out-of-stock pitfall) routes here, never to ErrorView (T-03-12).

**ErrorView** (results-specific) — `Icons.wifi_off` + "Не удалось загрузить результаты" + body + 56 dp "Повторить" → `ref.invalidate(partsSearchProvider)`. Never exposes raw exception/stack trace (T-03-11).

**LocationDeniedView** — non-blocking banner with `Icons.location_off`, "Геолокация выключена", Yerevan-fallback explanation. Shows "Повторить" for re-requestable denial, "Открыть настройки" for `deniedForever`. Renders above the results list — results are never blocked (RES-06).

**PartsResultsPage** — `ConsumerWidget` watching `partsSearchProvider` via `AsyncValue.when`. Dispatches loading → spinner, error → ErrorView (retry invalidates provider), empty → EmptyResultsView, data → `ListView.builder` of VendorResultCard (server distance order, no client re-sort). AppBar title: `categoryName` or `"Поиск: {query}"`. `SafeArea` wraps body.

## Test Results

- `flutter test` — **43/43 passed** (full suite including prior plans)
- `flutter analyze` — **No issues found**
- Tests run from `/tmp` copy due to documented OneDrive `build/unit_test_assets` lock (Windows workaround, same as Phase 02/03-03/03-04)

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Loading test pending-timer assertion**
- **Found during:** Task 2 GREEN verification
- **Issue:** Test for loading state used `Future.delayed(Duration(days: 1))` which left a timer pending after widget disposal, triggering flutter_test assertion
- **Fix:** Replaced with `Completer<List<VendorResult>>()` — a future that never completes without creating a timer
- **Files modified:** `mobile/test/search/parts_results_page_test.dart`
- **Commit:** fa8427d

**2. [Rule 2 - Path translation] All `app/` paths translated to `mobile/`**
- Plan specified `app/lib/...` and `app/test/...` paths; actual project uses `mobile/lib/...`
- Applied per critical_layout_note in execution prompt

## Known Stubs

- `PartsResultsPage.onOpenSettings` callback body is a comment stub (`// geolocator.openAppSettings() — deferred to Phase 4`). The button renders and is tappable; the platform settings launch is deferred to Phase 4 as documented.

## Threat Flags

None — no new network endpoints, auth paths, or file access patterns introduced. Error state copy does not expose internal details (T-03-11 mitigated). Empty array correctly routes to EmptyResultsView, not error (T-03-12 mitigated).

## Self-Check: PASSED

Files created/verified in worktree:
- mobile/lib/features/parts_results/widgets/distance_badge.dart — FOUND
- mobile/lib/features/parts_results/widgets/vendor_result_card.dart — FOUND
- mobile/lib/features/parts_results/widgets/empty_results_view.dart — FOUND
- mobile/lib/features/parts_results/widgets/error_view.dart — FOUND
- mobile/lib/features/parts_results/widgets/location_denied_view.dart — FOUND
- mobile/lib/features/parts_results/parts_results_page.dart — FOUND (updated)
- mobile/test/search/vendor_result_card_test.dart — FOUND
- mobile/test/search/parts_results_page_test.dart — FOUND

Commits verified: 8771b49 (RED task1), 10c551c (GREEN task1), a53d082 (RED task2), fa8427d (GREEN task2)
