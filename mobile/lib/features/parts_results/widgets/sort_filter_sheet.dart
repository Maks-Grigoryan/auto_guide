import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/search/providers/search_params.dart';

/// Sort & filter bottom sheet for the parts results screen.
///
/// UI-SPEC Surface 4 — «Сортировка и фильтры»
///   Sheet bg #2A2D36, top radius 16, drag handle 4dp #3D4050
///   Title 20sp SemiBold #FFFFFF «Сортировка и фильтры»
///   3 RadioListTile (По расстоянию / По цене / По рейтингу) — all ENABLED
///   Divider #3D4050
///   Slider «Радиус» committed via onChangeEnd (RESEARCH Pitfall 6)
///   SwitchListTile «Только в наличии»
///   RangeSlider «Цена, ₽»
///   TextButton «Сбросить»
///
/// All changes apply instantly (no separate «Применить» button).
/// Radius slider is the only control that triggers a re-fetch.
class SortFilterSheet extends ConsumerStatefulWidget {
  const SortFilterSheet({super.key});

  @override
  ConsumerState<SortFilterSheet> createState() => _SortFilterSheetState();
}

class _SortFilterSheetState extends ConsumerState<SortFilterSheet> {
  // Local slider state — only committed to provider on change end.
  late double _radiusKm;
  late double _minPriceLocal;
  late double _maxPriceLocal;

  static const double _maxRadiusKm = 20.0; // matches PartsQuery default 20000 m
  static const double _maxPriceRange = 50000.0;

  @override
  void initState() {
    super.initState();
    final params = ref.read(searchParamsProvider);
    _radiusKm = (params?.radius ?? 20000) / 1000.0;
    _minPriceLocal = params?.minPrice ?? 0.0;
    _maxPriceLocal = params?.maxPrice ?? _maxPriceRange;
  }

  String _sortLabel(ResultSort sort) {
    switch (sort) {
      case ResultSort.distance:
        return 'По расстоянию';
      case ResultSort.price:
        return 'По цене';
      case ResultSort.rating:
        return 'По рейтингу';
    }
  }

  void _reset() {
    final notifier = ref.read(searchParamsProvider.notifier);
    notifier.updateSort(ResultSort.distance);
    notifier.updateFilter(
      availabilityOnly: false,
      clearMinPrice: true,
      clearMaxPrice: true,
    );
    final params = ref.read(searchParamsProvider);
    setState(() {
      _radiusKm = (params?.radius ?? 20000) / 1000.0;
      _minPriceLocal = 0.0;
      _maxPriceLocal = _maxPriceRange;
    });
  }

  @override
  Widget build(BuildContext context) {
    final params = ref.watch(searchParamsProvider);
    final currentSort = params?.sort ?? ResultSort.distance;
    final availabilityOnly = params?.availabilityOnly ?? false;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF3D4050),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'Сортировка и фильтры',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFFFFFF),
              ),
            ),
            const SizedBox(height: 12),

            // Sort section label
            const Text(
              'Сортировка',
              style: TextStyle(fontSize: 18, color: Color(0xFFFFFFFF)),
            ),

            // Sort radio tiles
            ...ResultSort.values.map(
              (sort) => RadioListTile<ResultSort>(
                value: sort,
                groupValue: currentSort,
                onChanged: (v) {
                  if (v != null) {
                    ref.read(searchParamsProvider.notifier).updateSort(v);
                  }
                },
                title: Text(
                  _sortLabel(sort),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
                // M3 RadioListTile default row height satisfies ≥48dp
              ),
            ),

            const Divider(color: Color(0xFF3D4050)),

            // Filters section label
            const Text(
              'Фильтры',
              style: TextStyle(fontSize: 18, color: Color(0xFFFFFFFF)),
            ),

            // Radius slider — committed on release (RESEARCH Pitfall 6)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Радиус: ${_radiusKm.round()} км',
                style: const TextStyle(fontSize: 16, color: Color(0xFFE0E0E0)),
              ),
            ),
            Slider(
              value: _radiusKm,
              min: 1.0,
              max: _maxRadiusKm,
              divisions: 19,
              label: '${_radiusKm.round()} км',
              activeColor: const Color(0xFFF5A623),
              onChanged: (v) {
                // Update local display only — no re-fetch per drag frame
                setState(() => _radiusKm = v);
              },
              onChangeEnd: (v) {
                // Commit to provider on release — triggers re-fetch
                ref
                    .read(searchParamsProvider.notifier)
                    .updateFilter(radius: (v * 1000).round());
              },
            ),

            // Availability switch
            SwitchListTile(
              value: availabilityOnly,
              onChanged: (v) {
                ref
                    .read(searchParamsProvider.notifier)
                    .updateFilter(availabilityOnly: v);
              },
              title: const Text(
                'Только в наличии',
                style: TextStyle(fontSize: 16, color: Color(0xFFFFFFFF)),
              ),
              activeColor: const Color(0xFFF5A623),
              // M3 SwitchListTile default row height satisfies ≥48dp
            ),

            // Price range slider
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Цена, ₽',
                style: TextStyle(fontSize: 16, color: Color(0xFFE0E0E0)),
              ),
            ),
            RangeSlider(
              values: RangeValues(_minPriceLocal, _maxPriceLocal),
              min: 0,
              max: _maxPriceRange,
              divisions: 100,
              labels: RangeLabels(
                '${_minPriceLocal.round()} ₽',
                '${_maxPriceLocal.round()} ₽',
              ),
              activeColor: const Color(0xFFF5A623),
              onChanged: (range) {
                setState(() {
                  _minPriceLocal = range.start;
                  _maxPriceLocal = range.end;
                });
                ref.read(searchParamsProvider.notifier).updateFilter(
                      minPrice: range.start > 0 ? range.start : null,
                      maxPrice: range.end < _maxPriceRange ? range.end : null,
                      clearMinPrice: range.start <= 0,
                      clearMaxPrice: range.end >= _maxPriceRange,
                    );
              },
            ),

            // Reset button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _reset,
                child: const Text(
                  'Сбросить',
                  style: TextStyle(
                    color: Color(0xFFF5A623),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
