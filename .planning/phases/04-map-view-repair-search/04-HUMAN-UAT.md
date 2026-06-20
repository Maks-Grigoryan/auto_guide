---
status: partial
phase: 04-map-view-repair-search
source: [04-VERIFICATION.md]
started: 2026-06-20
updated: 2026-06-20
---

## Current Test

[awaiting human testing — requires local Flutter SDK + device + Yandex MapKit key + live PostGIS]

## Tests

### 1. D-04 degraded path on device (no key)
expected: `flutter run` with NO `--dart-define MAPKIT_API_KEY` → run a parts search → «Карта» segment is disabled, «Карта недоступна» notice shows, list path works end-to-end with no crash. Repeat on repair path.
result: [pending]

### 2. Map path on device WITH key
expected: `flutter run --dart-define=MAPKIT_API_KEY=<key>` → tap «Карта» → one amber marker per vendor, camera frames ALL markers, each marker shows a distance label, marker tap raises the bottom-sheet card (map visible behind), card body opens the «Карточка появится позже» /vendor/:id stub. Repeat on repair path (service count, no price). Single result → ~zoom 15; zero → Yerevan-centred + «Поблизости ничего не найдено».
result: [pending]

### 3. Native platform min versions
expected: `flutter create --platforms=ios,android .`; iOS Podfile `platform :ios, '13.0'` + `pod install` succeeds; Android `minSdkVersion >= 21`. Record confirmed minimums (resolves RESEARCH [ASSUMED] A1 / Pitfall 7).
result: [pending]

### 4. Backend e2e with live PostGIS
expected: `cd backend && npm run migrate:up && npm run test:e2e -- --testPathPattern="search|catalog"` → GET /search/repair returns repair_shop rows; radius=150000 → 400 (DoS cap); GET /catalog/service-categories returns «Развал-схождение» with Cache-Control header; migration 006 rating column present.
result: [pending]

### 5. WR-02 — raw vendor type token in UI (product decision)
expected: Decide whether to map `vendor.type` ('repair_shop'/'parts_shop') to a localized human label («Автосервис» / «Магазин запчастей») before release — current UI renders the raw token, which is poor for the non-technical/elderly audience (CLAUDE.md UX constraint). Apply the mapping or accept as-is.
result: [pending]

## Summary

total: 5
passed: 0
issues: 0
pending: 5
skipped: 0
blocked: 0

## Gaps
