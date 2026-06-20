# ROADMAP — Авто-агрегатор (СТО + запчасти)

**Milestone:** MVP-1 (Geo-search хребет)
**Granularity:** Standard
**Coverage:** 28/28 v1 requirements mapped

---

## Phases

- [x] **Phase 1: Foundation** — Docker + PostGIS + schema + indexes + seeded test data (completed 2026-06-14)
- [x] **Phase 2: Car Catalog & Selector** — catalog API + Flutter car-selector screens (make → model → generation) (completed 2026-06-16)
- [x] **Phase 3: Parts Search & List Results** — search_parts backend + Flutter list screen with real seeded data (completed 2026-06-16)
- [x] **Phase 4: Map View & Repair Search** — Yandex map markers, list⇄map toggle, repair search flow (completed 2026-06-20)
- [ ] **Phase 5: Vendor Card & Contacts** — vendor detail screen with Call + Route buttons
- [ ] **Phase 6: Accessibility & i18n** — theme, font, touch targets, contrast, RU/HY/EN localization

---

## Phase Details

### Phase 1: Foundation

**Goal**: The backend stack runs locally with one command and geo-search SQL functions return correct results on seeded Yerevan test data.
**Mode:** mvp
**Depends on**: Nothing
**Requirements**: FND-01, FND-02, FND-03, FND-04, FND-05, CAT-01 (pulled in per CONTEXT D-03)
**Success Criteria** (what must be TRUE):

  1. `docker compose up` starts PostgreSQL/PostGIS and NestJS with no manual steps
  2. `search_parts(lat=40.1872, lng=44.5152, ...)` returns at least 5 vendor rows with distance, min_price, and coordinates (smoke test passes)
  3. `EXPLAIN ANALYZE` on search_parts confirms GiST index scan (not seq scan) on `vendors.location`
  4. CIS makes (Lada/ВАЗ, ГАЗ, УАЗ) are present and searchable in the seeded database
  5. Coordinate-order smoke test passes: `ST_MakePoint(44.5152, 40.1872)` round-trips correctly in all search functions

**Plans**: 4 plans
Plans:

- [x] 01-01-PLAN.md — Docker Compose + node-pg-migrate + extensions & tables/indexes migrations (FND-01/02/03)
- [x] 01-02-PLAN.md — search_parts/search_repair SQL functions + coordinate/GiST/fitment-NULL smoke tests (FND-04)
- [x] 01-03-PLAN.md — Full vPIC+CIS catalog import + Yerevan vendors/parts/services seed (FND-05, CAT-01)
- [x] 01-04-PLAN.md — Minimal NestJS app: pg.Pool DatabaseModule + GET /search/parts + docker api service (FND-01/04)

### Phase 2: Car Catalog & Selector

**Goal**: A user can pick their car (make → model → generation) in the Flutter app and the selection is retained as an active filter.
**Mode:** mvp
**Depends on**: Phase 1
**Requirements**: CAT-02, SEL-01, SEL-02, SEL-03, SEL-04 (CAT-01 completed in Phase 1)
**Success Criteria** (what must be TRUE):

  1. `/makes`, `/models?makeId`, `/generations?modelId` return data with 24-hour HTTP cache headers
  2. User can type "Toyota" in the make list and it filters instantly without re-fetching
  3. User taps make → model → generation and the selection appears on the home screen as an active chip
  4. CIS makes (Lada, ГАЗ, УАЗ) appear in the make list alongside NHTSA-sourced brands
  5. Selecting a car persists across app sessions (Riverpod + Hive)

**Plans**: 3 plans
Plans:

- [x] 02-01-PLAN.md — NestJS catalog module: /catalog/makes|models|generations with 24h cache headers (CAT-02)
- [x] 02-02-PLAN.md — Flutter scaffold + selector state/persistence + thin end-to-end pick→confirm→chip slice (SEL-01..04)
- [x] 02-03-PLAN.md — Asphalt & Signal theme + reusable widgets + instant make filter + async states (SEL-01..04)

**UI hint**: yes

### Phase 3: Parts Search & List Results

**Goal**: A user with a selected car can search for parts by category or OEM number and sees a ranked list of nearby shops with distance, min price, and item count.
**Mode:** mvp
**Depends on**: Phase 2
**Requirements**: PRT-01, PRT-02, PRT-03, RES-01, RES-06, RES-07
**Success Criteria** (what must be TRUE):

  1. Home screen shows [Запчасти]/[Ремонт] toggle, search field, and «Выбрать авто» button
  2. User browses part categories and receives a list of vendors sorted by distance with amber distance badge, min price, and item count
  3. User searches "19216" (OEM number with spaces/dashes normalized) and finds matching vendors
  4. Parts from whole-make fitments appear in results for a specific model (NULL-semantics correctly handled)
  5. Geolocation permission prompt appears on first launch; if denied, user sees a clear fallback message with instructions to enable it

**Plans**: 5 plans
Plans:
**Wave 1**

- [x] 03-01-PLAN.md — Migration 005: 8-arg search_parts fix + server-side OEM normalization + seed OEM 19216; service/DTO fix + e2e (PRT-02, PRT-03)
- [x] 03-02-PLAN.md — GET /catalog/part-categories endpoint + e2e (PRT-01, RES-01)
- [x] 03-03-PLAN.md — Flutter app scaffold: locked stack + theme + dio client + models + go_router + test harness (RES-01)

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 03-04-PLAN.md — Home screen (toggle/search/category browse) + submit-triggered search providers + geolocation Yerevan fallback (PRT-01, RES-01, RES-06)

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 03-05-PLAN.md — Ranked vendor results list + distance badge/card + empty/error/location-denied states (PRT-01, RES-07)

**UI hint**: yes

### Phase 4: Map View & Repair Search

**Goal**: A user can switch between list and Yandex map views for parts results, and can also find nearby repair shops for a chosen service category.
**Mode:** mvp
**Depends on**: Phase 3
**Requirements**: REP-01, REP-02, RES-02, RES-03, RES-04, RES-05
**Success Criteria** (what must be TRUE):

  1. Tapping the map toggle shows a Yandex map with one marker per vendor; tapping a marker opens a summary card
  2. Each list card shows a distance badge, min price, and item/service count; map markers display the distance label
  3. User can sort results by distance, price, or rating
  4. User can filter by radius, in-stock status, and price range; results update without full page reload
  5. User browses repair service categories (e.g., «Развал-схождение») and sees the nearest repair shops offering that service

**Plans**: 4 plans
Plans:
**Wave 1**

- [x] 04-01-PLAN.md — Repair backend: GET /search/repair + GET /catalog/service-categories + migration 006 (rating in both search fns) + e2e (REP-01, REP-02, RES-04)

**Wave 2** *(blocked on Wave 1 completion; 04-02 ∥ 04-03 run in parallel — file-disjoint)*

- [x] 04-02-PLAN.md — Sort & filter slice: PartsQuery sort/filter fields + VendorResult.rating + sortedFilteredProvider + «Сортировка и фильтры» sheet (RES-04, RES-05)
- [x] 04-03-PLAN.md — Repair frontend slice: ServiceCategory + repair providers + service-categories/repair-results pages + router (+/vendor/:id stub) + home «Ремонт» wiring (REP-01, REP-02, RES-02)

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 04-04-PLAN.md — Map view slice: yandex_maps_mapkit + map_config/init guard + [Список]/[Карта] toggle + ResultsMapView + summary sheet + D-04 degradation + platform setup checkpoint (RES-02, RES-03)

**UI hint**: yes

### Phase 5: Vendor Card & Contacts

**Goal**: A user can open a vendor's detail page, see full info and hours, and contact the vendor via phone call or Yandex navigation.
**Mode:** mvp
**Depends on**: Phase 4
**Requirements**: VEN-01, VEN-02, VEN-03
**Success Criteria** (what must be TRUE):

  1. Tapping a list card or map marker opens the vendor detail screen showing name, address, opening hours, and rating
  2. Tapping «Позвонить» opens the system phone dialer with the vendor's number pre-filled (tel: URI)
  3. Tapping «Маршрут» opens Yandex Navigator (or Yandex Maps) deep-link routed to the vendor's coordinates

**Plans**: TBD
**UI hint**: yes

### Phase 6: Accessibility & i18n

**Goal**: Every screen is fully usable by elderly users at 2x system font scale, meets contrast requirements, and displays correctly in Russian, Armenian, and English.
**Mode:** mvp
**Depends on**: Phase 5
**Requirements**: ACC-01, ACC-02, ACC-03
**Success Criteria** (what must be TRUE):

  1. Every screen passes `textScaleFactor = 2.0` test with no text clipping, no button overlap, no hidden content
  2. All interactive elements have touch targets ≥48 dp; primary action buttons are ≥56 px tall; contrast ratio ≥4.5:1 for all text
  3. Status indicators (e.g., «В наличии», «Открыто») use icon + label, never color alone
  4. Switching app language to Armenian (hy) or English (en) displays all screens without untranslated strings or layout breaks
  5. All prices display in AMD by default; locale-aware number formatting applied throughout

**Plans**: TBD
**UI hint**: yes

---

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation | 4/4 | Complete   | 2026-06-14 |
| 2. Car Catalog & Selector | 3/3 | Complete   | 2026-06-16 |
| 3. Parts Search & List Results | 5/5 | Complete   | 2026-06-16 |
| 4. Map View & Repair Search | 4/4 | Complete   | 2026-06-20 |
| 5. Vendor Card & Contacts | 0/? | Not started | - |
| 6. Accessibility & i18n | 0/? | Not started | - |

---

*Roadmap created: 2026-06-14*
*Last updated: 2026-06-17 after Phase 4 planning*
