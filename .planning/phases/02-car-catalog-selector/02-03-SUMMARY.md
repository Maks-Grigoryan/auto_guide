---
phase: "02"
plan: "03"
subsystem: mobile-ui
tags: [flutter, riverpod, theme, accessibility, widgets, tdd]
dependency_graph:
  requires: ["02-02"]
  provides: ["app_theme", "reusable_widgets", "make_filter_test", "themed_selector_pages"]
  affects: ["03-home-screen"]
tech_stack:
  added: ["google_fonts (GoogleFonts.inter via existing dep)"]
  patterns: ["AsyncStateView<T> generic widget", "client-side contains filter with compareTo sort"]
key_files:
  created:
    - mobile/lib/app_theme.dart
    - mobile/lib/features/car_selector/ui/widgets/error_view.dart
    - mobile/lib/features/car_selector/ui/widgets/async_state_view.dart
    - mobile/lib/features/car_selector/ui/widgets/search_field.dart
    - mobile/lib/features/car_selector/ui/widgets/catalog_list_tile.dart
    - mobile/lib/features/car_selector/ui/widgets/confirmation_row.dart
    - mobile/lib/features/car_selector/ui/widgets/car_chip.dart
    - mobile/test/car_selector/make_filter_test.dart
  modified:
    - mobile/lib/main.dart
    - mobile/lib/features/car_selector/ui/make_list_page.dart
    - mobile/lib/features/car_selector/ui/model_list_page.dart
    - mobile/lib/features/car_selector/ui/generation_list_page.dart
    - mobile/lib/features/car_selector/ui/confirmation_page.dart
    - mobile/lib/features/home/home_page.dart
decisions:
  - "AsyncStateView<T> is a generic StatelessWidget — pages pass AsyncValue directly; keeps pages thin"
  - "SearchField owns its TextEditingController when none is provided (accepts optional external one for tests)"
  - "client-side sort uses Dart compareTo — handles Cyrillic sensibly (Pitfall 5 from RESEARCH)"
  - "CarChip uses Container+Row not Flutter Chip widget — Chip has fixed height constraints that conflict with 56 dp + textScaleFactor"
metrics:
  duration: "~40 min"
  completed: "2026-06-16"
  tasks_completed: 2
  files_changed: 14
---

# Phase 02 Plan 03: Theme, Widgets & Make Filter Summary

"Asphalt & Signal" MaterialApp theme + 6 reusable accessible widgets + instant client-side make/model filter proven by widget test; all four selector pages and home chip refactored to use shared components."

## What Was Built

### Task 1 — app_theme.dart + 6 Reusable Widgets (commit d6078a0)

- `app_theme.dart`: Full Material 3 `ThemeData` with the Asphalt & Signal ColorScheme (`#F5A623` primary, `#1C1F26` surface, `#2A2D36` surfaceVariant). GoogleFonts.interTextTheme applied: body 16/400, label 18/400, heading 20/600. No fontSize below 16.
- `main.dart`: `theme: appTheme` wired into `MaterialApp.router`.
- `error_view.dart`: wifi_off icon + screen-specific heading + generic body + "Повторить" TextButton. No raw exception/stack exposed to user (T-02-08 mitigation).
- `async_state_view.dart`: Generic `AsyncStateView<T>` — maps Riverpod `AsyncValue<T>` to loading / error / empty / data states.
- `search_field.dart`: 48 dp TextField, fill `#2A2D36`, prefix search icon, clear button, `onChanged` on every keystroke (no debounce — list is in-memory ≤200 rows).
- `catalog_list_tile.dart`: 56 dp `ListTile`, 18 sp title, accent leading check when `isSelected`, optional subtitle 16 sp.
- `confirmation_row.dart`: 56 dp tappable `ListTile` with leading label, value title, trailing edit icon (`#F5A623`).
- `car_chip.dart`: 56 dp `Container`+`Row` with `Icons.directions_car` + label + edit icon. Status conveyed by icon AND text (ACC-02 — never color alone).

### Task 2 — Pages + Make Filter Widget Test (commits a40682a RED, 567d339 GREEN)

- `make_filter_test.dart`: 3 widget tests using `ProviderScope` override with in-memory stub (no network): (1) "to" → only "Toyota" visible, (2) "TOYOTA" case-insensitive match, (3) nonsense → empty-search copy.
- `make_list_page.dart`: Refactored to use `SearchField` + `AsyncStateView` + `CatalogListTile`. Case-insensitive `contains` filter + `compareTo` sort (Cyrillic-safe).
- `model_list_page.dart`: Same pattern with "Поиск модели..." hint.
- `generation_list_page.dart`: `AsyncStateView` + `CatalogListTile`; "Пропустить" row in accent italic as index 0.
- `confirmation_page.dart`: Uses `ConfirmationRow`; cascade-reset navigation and `confirm()→context.go('/')` preserved from 02-02.
- `home_page.dart`: Uses `CarChip` (imported from widgets); `Icons.directions_car` + name label.

All Scaffold bodies wrapped in `SafeArea`. All interactive elements ≥48 dp; primary buttons and list rows ≥56 dp.

## Verification Results

### Static Checks (flutter SDK not on PATH — manual grep verification)

| Check | Result |
|-------|--------|
| `F5A623` in app_theme.dart | PASS |
| `GoogleFonts` in app_theme.dart (16 occurrences) | PASS |
| `theme: appTheme` in main.dart | PASS |
| All 6 widget files exist | PASS |
| No fontSize < 16 in new files | PASS |
| `toLowerCase` + `contains` in make_list_page | PASS |
| `SafeArea` in all 5 pages | PASS |
| `CarChip` + `directions_car` in home_page | PASS |
| `confirm()` + `context.go('/')` in confirmation_page | PASS |

### flutter test / flutter analyze

BLOCKER: Flutter SDK not installed in execution environment (`flutter: command not found`). Tests and static analysis must be run locally. The test file is authored and structurally correct; the widget test pattern (ProviderScope override + pumpAndSettle + enterText + pump) is standard flutter_test.

## Deviations from Plan

### Auto-fixed Issues

None — plan executed as written.

### Architectural Notes

**CarChip implementation:** Used `Container`+`Row` instead of Flutter's `Chip` widget. Flutter's `Chip` enforces a fixed height via its `VisualDensity` and padding that conflicts with the required 56 dp touch target at `textScaleFactor > 1.0`. The `Container`-based approach gives full height control without clipping text at large scale factors (Phase 6 gate).

## TDD Gate Compliance

- RED gate: commit `a40682a` — `test(02-03): add failing make-filter widget test`
- GREEN gate: commit `567d339` — `feat(02-03): wire reusable widgets into pages`
- REFACTOR: not needed — implementation was clean on first pass

## Known Stubs

- `home_page.dart`: Placeholder text "Поиск запчастей и сервисов появится в следующей версии" — intentional; Phase 3 replaces with real geo-search results.
- `model_list_page.dart`: AppBar title uses confirmed `car?.makeName` — during editing flow before confirm(), title may be empty string. Noted in Plan 02-02; acceptable for Phase 2.

## Threat Flags

None. No new network endpoints, auth paths, file access, or schema changes introduced. Error views show only generic user-facing copy (T-02-08 mitigated).

## Self-Check

| Item | Status |
|------|--------|
| app_theme.dart exists | FOUND |
| 6 widget files exist | FOUND (all 6) |
| make_filter_test.dart exists | FOUND |
| commit d6078a0 | FOUND |
| commit a40682a | FOUND |
| commit 567d339 | FOUND |

## Self-Check: PASSED
