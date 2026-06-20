---
phase: 04-map-view-repair-search
plan: "04"
subsystem: mobile
tags: [map-view, yandex-mapkit, list-map-toggle, graceful-degradation, D-04, RES-02, RES-03]
dependency_graph:
  requires:
    - sortedFilteredResultsProvider (from 04-02)
    - repairSearchProvider (from 04-03)
    - vendor_result_card.dart (parameterized, from 04-03)
    - router /vendor/:id stub (from 04-03)
    - kYerevanLat/kYerevanLng (location_service.dart)
  provides:
    - mapAvailableProvider + D-04 init guard (map_config.dart, main.dart)
    - ResultsViewToggle ([Список]/[Карта], «Карта» disabled when unavailable)
    - MapUnavailableNotice («Карта недоступна»)
    - ResultsMapView (YandexMap + amber markers + camera fit + marker-tap sheet)
    - VendorSummarySheet (bottom-sheet reusing vendor card, routes /vendor/:id)
    - list⇄map toggle hosted on BOTH parts + repair results pages (D-01 single provider)
  affects:
    - mobile/pubspec.yaml (yandex_maps_mapkit ^4.36.0)
    - mobile/lib/main.dart (initMapkit guard + ProviderScope override)
    - mobile/lib/features/parts_results (toggle/map/sheet widgets + page host)
    - mobile/lib/features/repair_search/repair_results_page.dart (toggle/map host)
tech_stack:
  added:
    - "yandex_maps_mapkit ^4.36.0 (FULL SDK — locked in CLAUDE.md; pubspec.lock regen DEFERRED-to-local, no Flutter SDK in CI)"
  patterns:
    - "D-04 graceful degradation — mapkitKeyPresent guard + try/catch initMapkit; mapAvailable=false default published via ProviderScope override"
    - "Single source of truth — list and map both read the same provider (sortedFilteredResultsProvider / repairSearchProvider); no re-fetch on view switch (D-01)"
    - "Weak-ref tap listeners stored in List<MapObjectTapListener> State field, cleared with mapObjects (Pitfall 1/8)"
    - "Point(latitude:, longitude:) — latitude-first, opposite of PostGIS ST_MakePoint (Pitfall 3)"
key_files:
  created:
    - mobile/lib/core/map/map_config.dart
    - mobile/lib/core/map/map_config.g.dart
    - mobile/lib/features/parts_results/widgets/results_view_toggle.dart
    - mobile/lib/features/parts_results/widgets/map_unavailable_notice.dart
    - mobile/lib/features/parts_results/widgets/results_map_view.dart
    - mobile/lib/features/parts_results/widgets/vendor_summary_sheet.dart
    - mobile/test/search/results_view_toggle_test.dart
  modified:
    - mobile/pubspec.yaml
    - mobile/lib/main.dart
    - mobile/lib/features/parts_results/parts_results_page.dart
    - mobile/lib/features/repair_search/repair_results_page.dart
decisions:
  - "Map slice ships behind D-04 graceful degradation — app compiles and the list path stays fully usable with NO MapKit key (key is an open blocker per STATE.md)"
  - "Checkpoint (Task 5) APPROVED for the degraded (no-key) path; device map-path verification + iOS Podfile/Android minSdk confirmation DEFERRED-until-key"
  - "Both results pages converted to host the toggle over a single shared provider — view index in local state survives sort/filter changes (D-01)"
metrics:
  duration: ~45 min
  completed: "2026-06-20"
  tasks_total: 5
  tasks_completed: 4
  tasks_deferred: 1
  files_created: 7
  files_modified: 4
---

# Phase 04 Plan 04: List⇄Map Slice + Graceful Degradation Summary

**One-liner:** Yandex-map presentation of results on both parts and repair screens — [Список]/[Карта] toggle, amber per-vendor markers with camera auto-fit, marker-tap summary sheet — all behind a load-bearing D-04 degradation that lets the app ship with no MapKit key.

## What Was Built (Tasks 1–4, committed to master)

1. **MapKit dependency + D-04 init guard (a592f5a)** — `yandex_maps_mapkit ^4.36.0` added to pubspec.yaml; `map_config.dart` exposes `kMapkitApiKey` (`String.fromEnvironment('MAPKIT_API_KEY')`), `mapkitKeyPresent`, and the `mapAvailable` @riverpod provider; `main.dart` runs the guarded `initMapkit` (try/catch, empty key skips init entirely) after `ensureInitialized()` and before `runApp`, publishing `mapAvailable` via `ProviderScope` override.

2. **ResultsViewToggle + MapUnavailableNotice (RED 2970524 → GREEN bb0650d)** — SegmentedButton toggle at 48dp; «Карта» segment `enabled: mapAvailable` (disabled, inert when no key); `MapUnavailableNotice` renders «Карта недоступна» + `Icons.map_outlined` on a #2A2D36 strip (icon+text, never colour-only — ACC-02). Widget tests authored (RED before GREEN).

3. **ResultsMapView + VendorSummarySheet (9023589)** — `YandexMap` with per-vendor amber markers (latitude-first), weak-ref tap listeners in a State field cleared with `mapObjects`, camera handling for empty (Yerevan z12) / single (z15) / multi (BoundingBox fit) cases; `VendorSummarySheet` reuses the vendor card content and routes toward `/vendor/:id`.

4. **Host toggle in both pages (97296e5)** — parts + repair results pages host the toggle over a single shared provider (D-01, no re-fetch); empty map path overlays «Поблизости ничего не найдено»; degraded default keeps both pages on the list with the notice.

## Commits

| Task | Commit | Files |
|------|--------|-------|
| 1: MapKit dep + config + guard | a592f5a | pubspec.yaml, map_config.dart(+.g), main.dart |
| 2 RED: toggle/notice tests | 2970524 | test/search/results_view_toggle_test.dart |
| 2 GREEN: toggle + notice | bb0650d | results_view_toggle.dart, map_unavailable_notice.dart |
| 3: map view + summary sheet | 9023589 | results_map_view.dart, vendor_summary_sheet.dart |
| 4: host toggle (D-01) | 97296e5 | parts_results_page.dart, repair_results_page.dart |

## Checkpoint (Task 5): APPROVED — degraded path

The human-action checkpoint was **approved for the degraded (no-key) path** on 2026-06-20. The app compiles and the list path is fully usable with no MapKit key (D-04, the shippable state). The following are **DEFERRED-until-key / DEFERRED-to-local** (require Flutter SDK + device + provisioned Yandex MapKit key — an open blocker per STATE.md):

- Device map-path verification (RES-02, RES-03, D-02, D-03): amber marker per vendor, camera fit, distance labels, marker-tap sheet, `/vendor/:id` stub open.
- iOS Podfile minimum + Android minSdk confirmation (RESEARCH [ASSUMED] A1 / Pitfall 7) — run `flutter create --platforms=ios,android .`, set `platform :ios, '13.0'`, `pod install`, confirm `minSdkVersion >= 21`.

## Flutter CLI Verifications: DEFERRED-to-local (no Flutter SDK in CI)

`.g.dart` hand-authored per project convention; lock/tests run locally:
```bash
cd mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test test/search/results_view_toggle_test.dart --no-pub   # toggle + D-04 degradation
flutter test --no-pub                                             # full suite regression
flutter run                                                       # degraded path (no key): «Карта» disabled, notice, list works
```

## Threat Model Coverage

| Threat ID | Mitigation | Status |
|-----------|------------|--------|
| T-04-11 | MAPKIT_API_KEY via --dart-define, never committed; region/quota restriction | Accept (industry standard for mobile SDK keys) |
| T-04-12 | D-04 guard: initMapkit try/catch, empty key skips init, mapAvailable=false | Implemented — degraded path approved |
| T-04-13 | Tap listeners in State field, cleared with mapObjects (weak-ref GC) | Implemented (Pitfall 1/8) |
| T-04-SC | yandex_maps_mapkit official verified publisher, locked in CLAUDE.md | Accept (vetted in 04-RESEARCH) |

## Self-Check

- [x] pubspec.yaml contains yandex_maps_mapkit dependency
- [x] map_config.dart has String.fromEnvironment('MAPKIT_API_KEY') + mapAvailable @riverpod provider
- [x] main.dart wraps initMapkit in try/catch + ProviderScope override, after ensureInitialized, before runApp
- [x] results_view_toggle.dart has «Список»/«Карта» + ButtonSegment enabled: mapAvailable
- [x] map_unavailable_notice.dart has «Карта недоступна» + Icons.map_outlined
- [x] results_map_view.dart: List<MapObjectTapListener> field cleared with mapObjects; latitude-first Points; empty/single/multi camera cases
- [x] vendor_summary_sheet.dart calls showModalBottomSheet + routes to /vendor/
- [x] both results pages reference ResultsViewToggle + ResultsMapView and watch mapAvailableProvider
- [x] All 5 task commits on master (a592f5a, 2970524, bb0650d, 9023589, 97296e5)
- [~] Flutter analyze/test — DEFERRED-to-local (no SDK)
- [~] Device map-path + platform-min — DEFERRED-until-key (checkpoint approved for degraded path)

## Self-Check: PASSED (degraded path; device verification deferred)
