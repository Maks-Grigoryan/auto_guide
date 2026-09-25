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
mobile/web/             оболочка веб-сборки и мост к Yandex Maps JS API 2.1
backend/                NestJS API + pg.Pool
db/migrations/          версионированная схема и seed-данные
db/tests/               SQL-инварианты PostGIS и совместимости
docker-compose.yml      PostgreSQL/PostGIS + migrator + API
.github/workflows/      сборка, анализ и автоматические тесты
```

Android, iOS и веб собираются из одного кода `mobile/lib`. Платформенно различается только
карта: мобильные используют нативный MapKit, веб — Yandex Maps JS API 2.1. Разведение сделано
через conditional imports в `core/map/map_init.dart` и
`features/parts_results/widgets/results_map_view.dart`, поэтому экраны, провайдеры,
локализация и API-клиент общие и не содержат платформенных ветвлений.

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

## Запуск веб-версии

Веб-сборка использует тот же код и тот же интерфейс, что мобильное приложение. Из каталога `mobile`:

```powershell
flutter run -d chrome `
  --web-port=8080 `
  --dart-define=API_BASE_URL=http://localhost:3000 `
  --dart-define=MAPKIT_API_KEY=your-yandex-js-api-key
```

Порт закреплён за `8080`, потому что это значение уже стоит в `CORS_ORIGINS` в `.env.example`. При другом порте добавьте его в `CORS_ORIGINS` и перезапустите API, иначе браузер заблокирует запросы.

Ключ карты для веба — **отдельный**: `MAPKIT_API_KEY` в веб-сборке передаётся в JavaScript API, а не в мобильный MapKit, и эти ключи невзаимозаменяемы — MapKit-ключ отвергается с 403. Выпустите ключ JavaScript API на `https://developer.tech.yandex.ru/`. Без ключа сайт работает полностью, кроме карты: переключатель «Карта» отключён и показано то же уведомление, что на мобильных.

Используется версия загрузчика **2.1**. Ключи бесплатного тарифа «JavaScript API» версией 3.0 не принимаются (`403 Invalid api key`), поэтому менять версию в `web/yandex_map.js` можно только после проверки, что ваш ключ принят новым загрузчиком.

Ключи удобно держать в `mobile/dart_define.json` (файл в `.gitignore`) и передавать одним флагом:

```powershell
flutter run -d chrome --web-port=8080 --dart-define-from-file=dart_define.json
```

Production-сборка:

```powershell
flutter build web --release `
  --dart-define=API_BASE_URL=https://api.example.am `
  --dart-define=MAPKIT_API_KEY=your-production-js-api-key
```

Результат — статические файлы в `mobile/build/web`, раздаются любым веб-сервером или CDN. На widescreen-мониторах раскладка ограничена по ширине и центрируется, поэтому интерфейс совпадает с мобильным один в один.

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
- `GET /vendors/:id`;
- `POST /auth/register`, `POST /auth/login`, `GET /auth/me`.

## Аккаунты и роли

Приложение открывает экран входа сразу после интро; до входа остальные экраны недоступны.

- **Обычный пользователь** регистрируется прямо в приложении: одно поле — **телефон или
  e-mail**, что-то одно — плюс пароль от 8 символов. Что именно введено, решает сервер:
  строка с `@` проверяется как адрес и ложится в колонку `login`, иначе — как номер и ложится
  в `phone`. Входить потом можно по тому же значению в любом написании.
- **Администратор создаётся только из кода.** У `POST /auth/register` нет параметра роли,
  колонка `users.role` по умолчанию `user`, а CHECK-ограничение допускает лишь `user`/`admin`.
  Единственный путь к роли `admin` — команда на сервере:

  ```bash
  docker compose exec api node dist/scripts/create-admin \
    --login=admin --password='длинный-пароль'
  # или локально: cd backend && npm run admin:create -- --login=… --password=…
  ```

  Логином админа может быть короткое слово (`admin`): регистрация такие значения отклоняет —
  без `@` и без шести цифр строка проверку не проходит, — поэтому занять их через форму
  регистрации нельзя. `--email` продолжает работать как псевдоним `--login`.

  Пароль администратора — минимум 12 символов. Он попадает в историю оболочки: начните
  команду с пробела или передайте пароль через переменную `ADMIN_PASSWORD`.

После входа сервер возвращает роль в теле ответа и в подписанном JWT, поэтому клиент
отличает администратора от обычного пользователя.

Пароли хранятся как `scrypt` (N=16384, r=8, p=1) с индивидуальной солью; неверный пароль и
несуществующий аккаунт дают одинаковый ответ, чтобы через форму входа нельзя было
проверять, какие номера и адреса зарегистрированы. `POST /auth/login` ограничен 10
попытками в минуту, `POST /auth/register` — 5.

**`JWT_SECRET` обязателен.** Без него `docker compose` не поднимет API, а сам сервис
откажется стартовать: значение по умолчанию означало бы, что подделать токен может любой,
кто читал репозиторий. Сгенерировать:

```bash
node -e "console.log(require('crypto').randomBytes(48).toString('base64url'))"
```

Все числовые параметры валидируются, SQL-запросы параметризованы, внутренние ошибки не раскрываются клиенту. Для браузерных клиентов разрешённые источники задаются через `CORS_ORIGINS`.

## Конфигурация production

- замените пароль PostgreSQL и не используйте значения из `.env.example`;
- задайте HTTPS API URL в `API_BASE_URL` при сборке приложения;
- выпустите отдельный production-ключ Yandex MapKit;
- настройте Android/iOS signing и store metadata;
- замените начальные seed-данные проверенным каталогом реальных продавцов;
- настройте резервное копирование PostgreSQL, мониторинг `/health/ready` и ротацию логов.
