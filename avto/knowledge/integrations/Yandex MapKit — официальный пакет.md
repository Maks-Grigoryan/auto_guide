---
tags: [интеграция, карты, yandex, flutter]
date: 2026-06-15
---

# Yandex MapKit — официальный пакет

Использовать **`yandex_maps_mapkit` 4.36.0** (официальный аккаунт Yandex на pub.dev), **full**-вариант (не lite — routing нужен для кнопки «Маршрут»).

НЕ использовать старый community-пакет `yandex_mapkit` (не поддерживается).

Грабли:
- API-ключ оформляется на developer.tech.yandex.ru — возможна задержка одобрения для не-RU; начинать заранее.
- Падение на iOS в release (`dlsym`), невидимо в debug — обязателен тест на физическом устройстве в release перед сдачей фазы с картой (Phase 4).

Появится в [[index|roadmap]] на Phase 4 (карта). Связано: [[Стек — Flutter, NestJS, PostGIS]]
