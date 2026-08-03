# Авто Армения

Мобильный агрегатор магазинов автозапчастей и автосервисов Армении. Пользователь выбирает автомобиль, ищет запчасть по категории или OEM-номеру, находит подходящие магазины и СТО рядом с собой, сравнивает выдачу и связывается с продавцом.

## Возможности

- подбор автомобиля: марка → модель → поколение с локальным сохранением;
- поиск запчастей по категории, названию и нормализованному OEM-номеру;
- учёт совместимости детали с маркой, моделью и поколением;
- поиск СТО по категории услуги;
- геопоиск PostGIS с радиусом, сортировкой и фильтрами;
- список и Яндекс-карта с единым набором результатов;
- карточка продавца, часы работы, рейтинг, звонок и маршрут;
- понятные состояния загрузки, ошибки, пустая выдача и fallback геолокации;
- русский, армянский и английский языки, цены в AMD;
- адаптация всех экранов к системному масштабу текста 200%;
- Android и iOS проекты, Docker Compose и CI.

## Архитектура

```text
mobile/                 Flutter + Riverpod + Dio + go_router + Yandex MapKit
backend/                NestJS API + pg.Pool
db/migrations/          версионированная схема и seed-данные
db/tests/               SQL-инварианты PostGIS и совместимости
docker-compose.yml      PostgreSQL/PostGIS + migrator + API
.github/workflows/      сборка, анализ и автоматические тесты
```

Географическая логика выполняется в SQL-функциях `search_parts` и `search_repair`. Координаты хранятся как `geography(Point, 4326)`, поиск использует GiST, а текстовый поиск — `pg_trgm`.

## Быстрый запуск API

Требуются Docker Desktop и Docker Compose.

```powershell
Copy-Item .env.example .env
docker compose up -d --build
```

Compose сначала ждёт PostGIS, затем одноразово применяет миграции и запускает API от непривилегированного пользователя. Проверка готовности:

```powershell
Invoke-RestMethod http://localhost:3000/health/ready
```

Остановка без удаления данных:

```powershell
docker compose down
```

Том базы не удаляется. `docker compose down -v` удалит все локальные данные и должен использоваться только осознанно.

## Запуск Flutter

Требуются Flutter 3.38.4+, Android SDK либо Xcode. Из каталога `mobile`:

```powershell
flutter pub get
flutter run `
  --dart-define=API_BASE_URL=http://10.0.2.2:3000 `
  --dart-define=MAPKIT_API_KEY=your-yandex-mapkit-key
```

Для Android Emulator адрес хоста — `10.0.2.2`. Для iOS Simulator используйте `127.0.0.1`, а для физического устройства — LAN-адрес компьютера. Без `MAPKIT_API_KEY` приложение продолжает работать в режиме списка и показывает понятное уведомление о недоступной карте.

## Проверки

Backend:

```powershell
cd backend
npm ci
npm run build
npm run migrate:up
npm run test:e2e -- --runInBand
npm run audit:prod
```

Flutter:

```powershell
cd mobile
flutter analyze --no-pub
flutter test --no-pub
```

CI повторяет эти проверки на чистой PostGIS и дополнительно собирает debug APK. SQL-тесты проверяют порядок координат, использование GiST, NULL-семантику совместимости и доступность марок ВАЗ/Lada, ГАЗ и УАЗ.

## Release-сборка

Android:

1. Создайте upload-keystore.
2. Скопируйте `mobile/android/key.properties.example` в `mobile/android/key.properties` и заполните значения.
3. Выполните:

```powershell
cd mobile
flutter build appbundle --release `
  --dart-define=API_BASE_URL=https://api.example.am `
  --dart-define=MAPKIT_API_KEY=your-production-key
```

Файлы `key.properties`, `*.jks`, `.env` и реальные ключи не коммитятся. Для iOS откройте `mobile/ios/Runner.xcworkspace`, настройте Team/Bundle ID и соберите Archive в Xcode.

## API

Основные маршруты:

- `GET /health/live`, `GET /health/ready`;
- `GET /catalog/makes`, `/models`, `/generations`;
- `GET /catalog/part-categories`, `/service-categories`;
- `GET /search/parts`, `GET /search/repair`;
- `GET /vendors/:id`.

Все числовые параметры валидируются, SQL-запросы параметризованы, внутренние ошибки не раскрываются клиенту. Для браузерных клиентов разрешённые источники задаются через `CORS_ORIGINS`.

## Конфигурация production

- замените пароль PostgreSQL и не используйте значения из `.env.example`;
- задайте HTTPS API URL в `API_BASE_URL` при сборке приложения;
- выпустите отдельный production-ключ Yandex MapKit;
- настройте Android/iOS signing и store metadata;
- замените начальные seed-данные проверенным каталогом реальных продавцов;
- настройте резервное копирование PostgreSQL, мониторинг `/health/ready` и ротацию логов.
