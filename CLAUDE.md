<!-- Подробный рукописный бриф (модель данных, API, экраны, дизайн-система): docs/PROJECT-BRIEF.md -->

<!-- GSD:project-start source:PROJECT.md -->
## Project

**Авто-агрегатор (СТО + запчасти)**

Мобильное приложение-агрегатор для Армении / СНГ: пользователь быстро находит ближайшие
**автосервисы (СТО)** и **магазины запчастей**, смотрит варианты списком или на Яндекс-карте
и связывается с продавцом (звонок / маршрут / заявка). Стек: Flutter (iOS + Android),
NestJS-бэкенд, PostgreSQL + PostGIS. Аудитория — и пожилые, и молодые, поэтому приоритет —
понятность и практичность интерфейса, а не «красота».

**Core Value:** Пользователь выбирает своё авто (марка → модель → поколение) и сразу видит **ближайшие
подходящие магазины/сервисы списком и на карте**. Если работает только это — продукт уже полезен.

### Constraints

- **Tech stack**: Flutter (моб.), NestJS/TypeScript (бэкенд), PostgreSQL 15+ / PostGIS 3+ — выбрано в брифе для максимального контроля и геопоиска.
- **Tech stack**: Геозапросы — параметризованный SQL через `pg.Pool`, без ORM поверх PostGIS — избегаем борьбы ORM с гео-типами.
- **UX / Accessibility**: интерфейс обязан быть понятным для пожилых и молодых — шрифт 16–18, кнопки ≥56 px, контраст ≥4.5:1, никогда не полагаться только на цвет.
- **Region**: карты и геокодирование — Яндекс; данные/UI с прицелом на армянский рынок.
- **Data**: каталог авто на старте — только бесплатные датасеты (vPIC); лицензируемые базы исключены.
<!-- GSD:project-end -->

<!-- GSD:stack-start source:research/STACK.md -->
## Technology Stack

## Recommended Stack
### Core Technologies
| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| Flutter | 3.27+ (SDK) | iOS + Android from one codebase | Only credible cross-platform option with native performance; Dart 3.6 included; required by go_router 17 |
| NestJS | 11.x (latest 11.1.26) | REST API backend | Module-by-domain structure maps cleanly to this project's domains (search, vendors, catalog, auth); Express v5 now default in NestJS 11; requires Node 20+ |
| PostgreSQL | 15+ | Relational store + geo | PostGIS 3+ requires PG 12+ but PG 15 adds better vacuuming and logical replication; use PG 16 or 17 on new infra |
| PostGIS | 3.4+ | Geography columns, ST_DWithin, ST_MakePoint | The only production-grade geospatial extension for PG; GiST index on `geography(Point,4326)` gives sub-10ms radius queries at city scale |
| node-postgres (pg) | 8.21.0 | Raw SQL pool for NestJS | Direct `pg.Pool` bypasses ORM translation layer entirely; critical for calling PostGIS functions that ORMs mishandle; parametrised queries prevent SQL injection |
### Flutter Libraries
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| flutter_riverpod | 3.3.2 | State management | Always — see rationale below |
| riverpod_generator | (matches riverpod 3) | Code-gen for providers | Use with `@riverpod` annotation; removes boilerplate |
| go_router | 17.3.0 | Declarative navigation + deep links | All screen routing; Flutter-team maintained; supports ShellRoute for bottom nav with persistent state |
| dio | 5.9.2 | HTTP client | All API calls; interceptors for JWT injection, retry, and error normalisation — essential for production app |
| yandex_maps_mapkit | 4.36.0 | Full Yandex MapKit SDK | Map display + placemarks; use full (not lite) because routing and pedestrian navigation ("Маршрут" button) require full SDK |
| geolocator | 14.0.3 | Device GPS / location permission | Acquiring user lat/lng for all geo-search queries |
| firebase_messaging | 16.3.0 | Push notifications (FCM) | Delivery of inquiry status updates and vendor notifications |
| flutter_secure_storage | 10.3.1 | Secure token storage | JWT / refresh token persistence; uses Keychain (iOS) and AES-encrypted prefs (Android) |
| google_fonts | latest stable | Inter typeface | Design system requires Inter; this is the correct pub.dev package |
| cached_network_image | latest stable | Photo caching | Vendor and part photos from S3; critical for list-view performance |
| url_launcher | latest stable | tel: and maps: URI | "Позвонить" (call) and "Маршрут" (route) CTA buttons |
| flutter_localizations + intl | SDK bundled | i18n (hy / ru / en) | Required from day one per CLAUDE.md; ARB files for all three locales |
| permission_handler | latest stable | Runtime permission requests | Location permission flow (iOS NSLocationWhenInUseUsageDescription + Android) |
### NestJS / Backend Libraries
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| @nestjs/core + @nestjs/common | 11.x | Framework core | Always |
| pg (node-postgres) | 8.21.0 | PostgreSQL pool | All DB access — no ORM |
| class-validator | latest (0.14.x) | DTO validation decorators | Every request DTO; `ValidationPipe({ transform: true, whitelist: true })` globally |
| class-transformer | latest (0.5.x) | DTO class instantiation | Paired with class-validator; handles query param coercion |
| node-pg-migrate | latest stable | SQL migration versioning | Plain `.sql` migrations; PostgreSQL-only so PostGIS DDL is fully supported; no JVM required unlike Flyway |
| @nestjs/config | 3.x | `ConfigModule` + env vars | `DATABASE_URL`, Yandex API keys, JWT secret |
| @nestjs/jwt + passport-jwt | latest | JWT auth (future phases) | Not needed for anonymous geo-search MVP, add in Phase 1 vendor panel |
| @nestjs/throttler | latest | Rate limiting | Anti-spam for `/inquiries` and `/reviews` endpoints |
| multer + aws-sdk (or minio client) | latest | S3 photo upload | Vendor photo uploads in seller panel (Phase 1) |
### Development & Tooling
| Tool | Purpose | Notes |
|------|---------|-------|
| Docker Compose | Local PG + PostGIS | Official `postgis/postgis:16-3.4` image; avoids native PG install |
| node-pg-migrate CLI | Run migrations | `npx node-pg-migrate up` pointing at `DATABASE_URL` |
| Flutter DevTools | Widget inspector, performance | Built into SDK; profiling for map + list rendering |
| @nestjs/cli | Scaffold modules, controllers | `nest generate module search` etc. |
## Flutter State Management: Riverpod (Not Bloc)
## Geo Query Approach: pg.Pool + Raw SQL (Not ORM)
- PostGIS `geography` type is not natively understood by TypeORM or Prisma. Both attempt to map it to `text` or unsupported types, requiring workarounds and generating incorrect SQL.
- `ST_DWithin`, `ST_Distance`, `ST_MakePoint` return correct results only when called as raw SQL. An ORM abstraction layer introduces risk of coordinate-order bugs and cast errors.
- The search functions (`search_parts`, `search_repair`) live in the DB as SQL functions. Calling them via ORM is awkward; calling them via `pg.Pool` is two lines: `pool.query('SELECT * FROM search_parts($1,$2,...)', [lat, lng, ...])`.
- This is already a firm constraint in the project brief (`CLAUDE.md §15`).
## Yandex Maps Package: yandex_maps_mapkit (Full, Not Lite)
- The old `yandex_mapkit` package (community) is unmaintained — do not use.
- `yandex_maps_mapkit_lite` excludes routing. The "Маршрут" button must open a pedestrian/driving route — requires the full SDK.
- `yandex_maps_mapkit` (full) 4.36.0 is published by Yandex's official verified pub.dev account and updated 26 days ago.
- Note: Yandex MapKit requires an API key provisioned at `https://developer.tech.yandex.ru/`. The key is region-restricted; register under the project's target region (Russia/Armenia).
## Alternatives Considered
| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| flutter_riverpod 3 | bloc 9.x | Large team (5+) with existing Bloc conventions; enterprise strict event-tracing |
| go_router 17 | auto_route | Only if you need more codegen-heavy nested router patterns; go_router is Flutter-team maintained and sufficient |
| node-pg-migrate | Flyway | Flyway is fine but requires JVM in Docker; node-pg-migrate is JS-native and runs in the same Node environment |
| node-pg-migrate | Prisma Migrate | Prisma is excellent when you use Prisma ORM; since we use raw SQL, Prisma's migration format adds unnecessary lock-in |
| dio | http (dart) | Only for trivial one-off requests; dio's interceptors are required for JWT injection and centralised error handling |
| yandex_maps_mapkit (full) | yandex_maps_mapkit_lite | Only if routing ("Маршрут") is removed from scope; lite version is smaller bundle |
| PostgreSQL + PostGIS | MongoDB with geo | Mongo 2dsphere works for point-in-circle but lacks `pg_trgm` text search; relational data (parts fitments, reviews) is painful without JOINs |
## What NOT to Use
| Avoid | Why | Use Instead |
|-------|-----|-------------|
| TypeORM or Prisma for geo queries | Cannot generate correct PostGIS SQL; `geography` type unsupported; coordinate order bugs | `pg.Pool` with raw parametrised SQL |
| `yandex_mapkit` (old community package) | Unmaintained; lags behind MapKit SDK releases | `yandex_maps_mapkit` 4.36.0 from official Yandex account |
| Provider (Flutter) | Predecessor to Riverpod; lacks compile-time safety, no family/autoDispose; Riverpod is direct successor | `flutter_riverpod` 3.x |
| GetX | Mixes routing + state + DI in one opinionated package; hard to test; removes separation of concerns | Riverpod (state) + go_router (routing) |
| `http` package (dart) | No interceptors; requires manual retry, auth injection, error normalisation | `dio` 5.9.2 |
| NestJS global exception filter that leaks stack traces | Exposes internal structure to clients; security risk | Custom `HttpExceptionFilter` returning only `{ error, message }` |
## Version Compatibility
| Package A | Compatible With | Notes |
|-----------|-----------------|-------|
| flutter_riverpod ^3.3.2 | Dart 3.6+, Flutter 3.27+ | riverpod_generator must match major riverpod version |
| go_router ^17.3.0 | Flutter 3.27+, Dart 3.6+ | Requires same Flutter minimum; check pubspec SDK constraint |
| yandex_maps_mapkit ^4.36.0 | iOS 13+, Android API 21+ | Verify MapKit API key quota for production load |
| NestJS 11.x | Node.js 20+ | Node 18 is EOL; provision Node 20 LTS on server |
| pg 8.21.0 | PostgreSQL 12–17, PostGIS 3.x | No pg 9 yet; 8.x is stable series |
| node-pg-migrate | pg (node-postgres) | Uses same `DATABASE_URL` convention |
## Installation
# NestJS backend
# Flutter pubspec.yaml dependencies
## Sources
- pub.dev/packages/flutter_riverpod — version 3.3.2, verified 2026-06-14 (HIGH confidence)
- pub.dev/packages/go_router — version 17.3.0, verified 2026-06-14 (HIGH confidence)
- pub.dev/packages/yandex_maps_mapkit — version 4.36.0 from maps.yandex.ru, verified 2026-06-14 (HIGH confidence)
- pub.dev/packages/yandex_maps_mapkit_lite — version 4.36.0, lite vs full feature comparison (HIGH confidence)
- pub.dev/packages/geolocator — version 14.0.3, verified 2026-06-14 (HIGH confidence)
- pub.dev/packages/dio — version 5.9.2, verified 2026-06-14 (HIGH confidence)
- pub.dev/packages/firebase_messaging — version 16.3.0, verified 2026-06-14 (HIGH confidence)
- npmjs.com/package/pg — version 8.21.0 (HIGH confidence via WebSearch cross-check)
- trilon.io/blog/announcing-nestjs-11-whats-new — NestJS 11, Express v5, Node 20 requirement (HIGH confidence)
- npmjs.com/package/@nestjs/core — version 11.1.26 confirmed (HIGH confidence)
- salsita.github.io/node-pg-migrate — PostgreSQL-only migrations, no JVM, actively maintained (MEDIUM confidence)
- WebSearch: Flutter state management 2025 consensus — Riverpod for greenfield, Bloc for large teams (MEDIUM confidence — multiple independent sources agree)
- Yandex MapKit docs: yandex.com/maps-api/docs/mapkit/flutter/generated/getting_started.html — lite vs full feature matrix (HIGH confidence)
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

Conventions not yet established. Will populate as patterns emerge during development.
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

Architecture not yet mapped. Follow existing patterns found in the codebase.
<!-- GSD:architecture-end -->

<!-- GSD:skills-start source:skills/ -->
## Project Skills

No project skills found. Add skills to any of: `.claude/skills/`, `.agents/skills/`, `.cursor/skills/`, `.github/skills/`, or `.codex/skills/` with a `SKILL.md` index file.
<!-- GSD:skills-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd-quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd-debug` for investigation and bug fixing
- `/gsd-execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->



<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd-profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->

## Obsidian Knowledge Vault

Хранилище знаний: `C:\Users\User\OneDrive\Desktop\avto\avto\`

### При старте сессии
Прочитай `avto/00-home/index.md` и `avto/00-home/текущие приоритеты.md`.
Если задача касается модуля — прочитай связанную заметку из `avto/knowledge/` или `avto/atlas/`.

### При завершении (пользователь: "сохрани сессию")
1. Создай заметку в `avto/sessions/` с датой
2. Обнови `avto/00-home/текущие приоритеты.md`
3. Если принято решение — создай в `avto/knowledge/decisions/`
4. Если баг — создай в `avto/knowledge/debugging/`
5. Обнови `avto/00-home/index.md`, если появились новые заметки

Правила заметок: имена-утверждения (не категории), wiki-ссылки `[[имя]]`, frontmatter с `tags` и `date`, язык русский.
