---
phase: "05"
name: Vendor Card & Contacts
slug: vendor-card-contacts
requirements: [VEN-01, VEN-02, VEN-03]
depends_on: ["04"]
created: 2026-06-20
mode: mvp
---

# Phase 05 — Vendor Card & Contacts: Context

## Domain

The vendor detail screen and contact actions. A user taps a list card or a map
marker and lands on a full vendor page (name, address, opening hours, rating),
then contacts the vendor via **«Позвонить»** (system dialer) or **«Маршрут»**
(Yandex navigation to the vendor coordinates). This replaces the reserved
`/vendor/:id` stub route created in Phase 04.

Discussion clarified HOW to implement the roadmap-fixed scope — no new
capabilities were added.

## Decisions (locked)

### D-01 — Full vendor data via a new backend endpoint `GET /vendors/:id`
The search endpoints return name/address/phone/rating/coords but **not opening
hours** (VEN-01 requires hours). Decision: add a NestJS endpoint
`GET /vendors/:id` returning the full vendor card including opening hours, read
from the `vendors` table via parametrised `pg.Pool` query (same raw-SQL pattern
as `search.service.ts`). Mirrors the existing DTO/validation/controller stack.

### D-02 — Card loads by id (not passed pre-loaded)
The `/vendor/:id` route receives only the `vendorId`; the detail screen fetches
`GET /vendors/:id` itself (Riverpod provider keyed by id). Chosen for deep-link
friendliness and because full data (hours) only exists on the endpoint, not in
the list `VendorResult`. List card tap and map marker-tap both navigate with the
vendor id.

### D-03 — «Маршрут» → Yandex Navigator deep-link, fallback to Yandex Maps web
Attempt to open the Yandex Navigator app deep-link routed to the vendor's
lat/lng; if not installed, fall back to `maps.yandex.ru` in the browser. Use
`url_launcher` with `canLaunchUrl`/`launchUrl` + fallback. (Exact URI schemes are
a research item — see Open Questions.)

### D-04 — «Позвонить» → `tel:` URI
Open the system dialer pre-filled with the vendor phone via `url_launcher`
(`tel:<phone>`). No in-app calling.

### D-05 — Hide missing data (no empty placeholders)
If a vendor has no phone, the «Позвонить» button is NOT rendered. If opening
hours are absent, the hours row is hidden. No greyed-out "Нет данных" rows —
keep the card clean for the non-technical/elderly audience (CLAUDE.md UX).

## Canonical refs (MUST read before planning)

- `.planning/ROADMAP.md` — Phase 5 goal + success criteria (source of scope)
- `.planning/REQUIREMENTS.md` — VEN-01, VEN-02, VEN-03
- `.planning/phases/04-map-view-repair-search/04-04-SUMMARY.md` — `/vendor/:id` stub route, VendorSummarySheet, marker-tap flow to reuse
- `.planning/phases/04-map-view-repair-search/04-01-SUMMARY.md` — backend slice pattern (DTO + pg.Pool + controller) to clone for `GET /vendors/:id`
- `backend/src/search/search.service.ts` — `VendorSearchResult` interface + parametrised query pattern (the model to extend for a vendor-detail query)
- `mobile/lib/core/models/vendor_result.dart` — existing vendor fields (name, phone, address, rating, lat, lng) reused; a fuller VendorDetail model likely needed for hours
- `mobile/lib/router.dart` — the `/vendor/:id` stub route to replace
- `CLAUDE.md` — locked stack: `url_launcher` for tel:/maps URIs; theme «Asphalt & Signal»

## Code context (reusable assets)

- **VendorResultCard / VendorSummarySheet** (Phase 03/04) — card content + colours to reuse/extend on the detail screen
- **url_launcher** — already in the stack for tel: and route deep-links (VEN-02, VEN-03)
- **Backend raw-SQL + PostGIS pattern** — `pg.Pool` parametrised queries, DTO validation, `@Header` caching (from Phase 04 catalog/search slices)
- **go_router** — `/vendor/:id` route with path param; detail screen reads `state.pathParameters['id']`
- **Riverpod 3** — id-keyed provider for the vendor-detail fetch (mirrors partsSearchProvider topology)
- **Theme** — amber `#F5A623`, dark surfaces `#1C1F26`/`#2A2D36`, Inter, ≥56px touch targets

## Open questions (for research)

1. **Opening-hours storage** — does the `vendors` table already have an
   opening-hours column? If not, a migration + seed data is needed (VEN-01).
   Determine the shape (weekly schedule vs freeform text vs "open now" status).
2. **Yandex Navigator deep-link format** — exact URI scheme
   (`yandexnavi://build_route_on_map?...`) + the `maps.yandex.ru` web fallback
   URL for driving/pedestrian route to lat/lng. Verify on Android + iOS.
3. **"Open now" indicator** — should the card compute open/closed from hours, or
   just display the schedule? (Product-lightweight: display schedule; compute
   status only if hours are structured.)

## Deferred ideas (not this phase)

- Vendor reviews / rating submission (own phase — REV-* if added later)
- In-app inquiry / message-to-vendor form (separate capability)
- Photo gallery for the vendor (beyond the single card)
- Favouriting / saved vendors
