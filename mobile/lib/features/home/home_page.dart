import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../car_selector/domain/selected_car.dart';
import '../car_selector/state/selected_car_notifier.dart';
import '../car_selector/ui/widgets/car_chip.dart';
import '../search/providers/categories_provider.dart';
import '../search/providers/search_params.dart';
import '../../core/location/location_service.dart';
import 'widgets/category_tile.dart';
import 'widgets/parts_search_field.dart';
import 'widgets/search_type_toggle.dart';

/// Full home screen — toggle + search + category browse + car chip (D-01).
///
/// UI-SPEC zones:
///   AppBar "Авто-агрегатор"
///   SegmentedButton Запчасти(default)/Ремонт
///   «Выбрать авто» 56dp button OR CarChip (D-04 car integration)
///   PartsSearchField 48dp submit-triggered (D-03)
///   "Категории запчастей" section label
///   flat ListView of CategoryTile (PRT-01 browse)
///
/// Ремонт branch (REP-01): navigates to /repair/categories (Plan 04-03).
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _toggleIndex = 0; // 0=Запчасти, 1=Ремонт

  Future<void> _resolveLocationAndSearch({
    int? categoryId,
    String? query,
  }) async {
    final locService = ref.read(locationServiceProvider);
    final result = await locService.resolve();

    if (!mounted) return;

    if (result.status == LocationResultStatus.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Местоположение недоступно. Используем Ереван как центр поиска.',
          ),
        ),
      );
    } else if (result.status == LocationResultStatus.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Разрешите доступ к местоположению в настройках для точного поиска.',
          ),
        ),
      );
    }

    final car = ref.read(selectedCarProvider);
    final params = PartsQuery(
      lat: result.lat,
      lng: result.lng,
      makeId: car?.makeId,
      modelId: car?.modelId,
      generationId: car?.generationId,
      categoryId: categoryId,
      query: query,
    );

    ref.read(searchParamsProvider.notifier).submit(params);
    if (mounted) context.push('/results/parts');
  }

  void _onQuerySubmit(String query) {
    _resolveLocationAndSearch(query: query);
  }

  void _onCategoryTap(int categoryId) {
    _resolveLocationAndSearch(categoryId: categoryId);
  }

  @override
  Widget build(BuildContext context) {
    final selectedCar = ref.watch(selectedCarProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1C1F26),
      appBar: AppBar(
        title: const Text('Авто-агрегатор'),
        backgroundColor: const Color(0xFF2A2D36),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Toggle ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: SearchTypeToggle(
                selectedIndex: _toggleIndex,
                onPartsSelected: () => setState(() => _toggleIndex = 0),
                onRepairSelected: () {
                  setState(() => _toggleIndex = 1);
                  // REP-01: navigate to repair service-category browse (Plan 04-03)
                  context.push('/repair/categories');
                },
              ),
            ),

            if (_toggleIndex == 0) ...[
              // ── Car chip / select button ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _buildCarSection(selectedCar),
              ),

              // ── Search field ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: PartsSearchField(onSubmit: _onQuerySubmit),
              ),

              // ── Categories label ─────────────────────────────────────────
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text(
                  'Категории запчастей',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE0E0E0),
                  ),
                ),
              ),

              // ── Category list ────────────────────────────────────────────
              Expanded(
                child: categoriesAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFF5A623),
                    ),
                  ),
                  error: (e, _) => _buildCategoryError(),
                  data: (cats) => ListView.builder(
                    itemCount: cats.length,
                    itemBuilder: (context, i) => CategoryTile(
                      category: cats[i],
                      onTap: () => _onCategoryTap(cats[i].id),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCarSection(SelectedCar? car) {
    if (car == null) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF5A623),
          foregroundColor: const Color(0xFF1C1F26),
          minimumSize: const Size(double.infinity, 56),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: () => context.push('/selector/make'),
        child: const Text('Выбрать авто'),
      );
    }
    return CarChip(
      label: _chipLabel(car),
      onTap: () => context.push('/selector/make'),
    );
  }

  String _chipLabel(SelectedCar car) {
    final base = '${car.makeName} ${car.modelName}';
    if (car.generationLabel != null) return '$base · ${car.generationLabel}';
    return '$base · Поколение не указано';
  }

  Widget _buildCategoryError() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Не удалось загрузить категории',
          style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => ref.invalidate(categoriesProvider),
          child: const Text(
            'Повторить',
            style: TextStyle(color: Color(0xFFF5A623), fontSize: 16),
          ),
        ),
      ],
    );
  }
}
