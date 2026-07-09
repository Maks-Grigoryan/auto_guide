---
phase: "05"
type: discussion-log
created: 2026-06-20
---

# Phase 05 — Discussion Log

Human-reference record of the discuss-phase session. Not consumed by downstream agents.

## Areas discussed

### 1. Card data source (opening hours — VEN-01)
- Options: new `GET /vendors/:id` endpoint / only existing list data / endpoint + seed hours
- **Chosen:** New endpoint `GET /vendors/:id` (full card incl. opening hours from `vendors` table)
- Note: hours column existence is an open research question.

### 2. «Маршрут» behaviour (VEN-03)
- Options: Navigator→Maps fallback / Yandex Maps only / system geo: chooser
- **Chosen:** Yandex Navigator deep-link, fallback to `maps.yandex.ru` web

### 3. Missing data handling
- Options: hide empty / show disabled "нет данных"
- **Chosen:** Hide empty (no phone → no button; no hours → row hidden)

### 4. Card navigation
- Options: pass id → fetch / pass pre-loaded VendorResult via extra
- **Chosen:** Pass id → fetch `GET /vendors/:id` (deep-link friendly, aligns with endpoint decision)

## Deferred ideas
- Vendor reviews / rating submission
- In-app inquiry / message form
- Vendor photo gallery
- Favouriting / saved vendors
