---
tags: [паттерн, геопоиск, sql]
date: 2026-06-15
---

# search_parts отдаёт одну строку на продавца

`search_parts` агрегирует `GROUP BY vendor_id` → одна строка = один продавец (= один маркер на карте), с `item_count` (COUNT) и `min_price` (MIN), расстоянием и координатами. Не строка-на-деталь (иначе дубли маркеров и дедуп на клиенте).

Сигнатура: `search_parts(p_lat, p_lng, p_radius_m, p_make_id, p_model_id, p_generation_id, p_category_id, p_query)`. Аналогично `search_repair(p_lat, p_lng, p_radius_m, p_service_category_id)`.

Связано: [[part_fitments NULL означает всю марку]], [[ST_DWithin в WHERE, ST_Distance в SELECT]]
