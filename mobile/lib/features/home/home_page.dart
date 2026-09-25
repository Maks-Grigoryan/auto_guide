import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../car_selector/data/catalog_providers.dart';
import '../car_selector/domain/selected_car.dart';
import '../car_selector/state/selected_car_notifier.dart';
import '../car_selector/ui/widgets/car_chip.dart';
import '../search/providers/categories_provider.dart';
import '../search/providers/repair_params.dart';
import '../search/providers/search_params.dart';
import '../search/providers/service_categories_provider.dart';
import '../../core/location/location_service.dart';
import '../../core/widgets/language_picker.dart';
import '../../l10n/l10n.dart';
import 'widgets/category_tile.dart';
import 'widgets/parts_search_field.dart';

/// Search section — parts OR repair, never both (D-01).
///
/// UI-SPEC zones:
///   AppBar "Авто-агрегатор"
///   «Выбрать авто» 56dp button OR CarChip (D-04 car integration)
///   PartsSearchField 48dp submit-triggered (D-03, parts section only)
///   "Категории запчастей" / "Категории услуг" section label
///   flat ListView of categories (PRT-01 browse / REP-01 repair browse)
///
/// Which section renders is fixed by [initialIndex]: the hub passes it via
/// `extra` so each tile lands on its own section (0 = parts, 1 = repair).
/// There is deliberately no in-screen switcher: a section entered from the hub
/// stays that section, and the frame no longer jumps between two modes.
///
/// Ремонт branch (REP-01): service categories instead of parts, no OEM field —
///
/// an article number identifies a part, not a workshop, and offering it would
/// invite a search that cannot succeed.
class HomePage extends ConsumerWidget {
  const HomePage({super.key, this.initialIndex = 0});

  /// Which section to show: 0 = Запчасти, 1 = Ремонт.
  /// The hub passes this via `extra` so each tile lands on its own section.
  final int initialIndex;

  bool get _isRepair => initialIndex == 1;

  Future<void> _resolveLocationAndSearch(
    BuildContext context,
    WidgetRef ref, {
    int? categoryId,
    String? query,
  }) async {
    final locService = ref.read(locationServiceProvider);
    final result = await locService.resolve();

    if (!context.mounted) return;

    if (result.status == LocationResultStatus.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.locationFallback,
          ),
        ),
      );
    } else if (result.status == LocationResultStatus.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.locationSettingsHelp,
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
      // Carried even when a generation is set: the two narrow on different
      // things, and a car whose generation is unknown still has a year.
      year: car?.year,
    );

    ref.read(searchParamsProvider.notifier).submit(params);
    if (context.mounted) context.push('/results/parts');
  }

  void _onQuerySubmit(BuildContext context, WidgetRef ref, String query) {
    _resolveLocationAndSearch(context, ref, query: query);
  }

  void _onCategoryTap(BuildContext context, WidgetRef ref, int categoryId) {
    _resolveLocationAndSearch(context, ref, categoryId: categoryId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCar = ref.watch(selectedCarProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1C1F26),
      appBar: AppBar(
        // The title doubles as the way back to the hub. `go` rather than `pop`
        // because this screen is also reached straight from the car-selector
        // redirect, where there is no hub underneath to pop back to.
        // Align keeps the tap target on the words instead of stretching the
        // ripple across the whole bar.
        title: Align(
          alignment: AlignmentDirectional.centerStart,
          child: InkWell(
            onTap: () => context.go('/'),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(context.l10n.appTitle),
            ),
          ),
        ),
        backgroundColor: const Color(0xFF2A2D36),
        // The admin badge and sign-out live on the main screen now: this is a
        // section reached from there, and two ways out of the account in one
        // stack is one too many. The language stays — it is useful anywhere.
        actions: const [LanguageButton()],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Car chip ─────────────────────────────────────────────────────
            // Rendered first so the header never jumps between the sections.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _buildCarSection(context, ref, selectedCar),
            ),

            if (!_isRepair) ...[
              // ── Search field ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: PartsSearchField(
                  onSubmit: (query) => _onQuerySubmit(context, ref, query),
                ),
              ),

              // ── Categories label ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text(
                  context.l10n.partsCategories,
                  style: const TextStyle(
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
                  error: (e, _) => _buildCategoryError(context, ref),
                  data: (cats) => ListView.builder(
                    itemCount: cats.length,
                    itemBuilder: (context, i) => CategoryTile(
                      category: cats[i],
                      onTap: () =>
                          _onCategoryTap(context, ref, cats[i].id),
                    ),
                  ),
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text(
                  context.l10n.serviceCategories,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE0E0E0),
                  ),
                ),
              ),

              Expanded(
                child: ref.watch(serviceCategoriesProvider).when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFF5A623),
                        ),
                      ),
                      error: (e, _) =>
                          _buildServiceCategoryError(context, ref),
                      data: (services) => ListView.builder(
                        itemCount: services.length,
                        itemBuilder: (context, i) => _ServiceCategoryTile(
                          name: services[i].name,
                          onTap: () => _onServiceCategoryTap(
                            context,
                            ref,
                            services[i].id,
                            services[i].name,
                          ),
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

  /// Resolves location, submits the repair query and opens the results.
  ///
  /// Mirrors ServiceCategoriesPage: the GPS prompt and Yerevan fallback belong
  /// to the search, not to the screen it was started from.
  Future<void> _onServiceCategoryTap(
    BuildContext context,
    WidgetRef ref,
    int categoryId,
    String categoryName,
  ) async {
    final result = await ref.read(locationServiceProvider).resolve();
    if (!context.mounted) return;

    if (result.status == LocationResultStatus.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.locationFallback)),
      );
    } else if (result.status == LocationResultStatus.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.locationSettingsHelp)),
      );
    }

    ref.read(repairParamsProvider.notifier).submit(
          RepairQuery(
            lat: result.lat,
            lng: result.lng,
            serviceCategoryId: categoryId,
          ),
        );

    if (context.mounted) context.push('/results/repair', extra: categoryName);
  }

  Widget _buildServiceCategoryError(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.l10n.serviceCategoriesLoadError,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Color(0xFFE0E0E0)),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => ref.invalidate(serviceCategoriesProvider),
          child: Text(context.l10n.retry),
        ),
      ],
    );
  }

  Widget _buildCarSection(
    BuildContext context,
    WidgetRef ref,
    SelectedCar? car,
  ) {
    // No «Выбрать авто» button here: picking a car is the app's first step, so
    // by the time this screen renders one is always set (see the redirect in
    // router.dart). The chip shows the current car and is how it gets changed.
    if (car == null) return const SizedBox.shrink();
    return CarChip(
      label: _chipLabel(context, ref, car),
      onTap: () => context.push('/selector/make'),
    );
  }

  String _chipLabel(BuildContext context, WidgetRef ref, SelectedCar car) {
    // The year rides along with the make and model rather than replacing the
    // generation: they answer different questions, and a car can have one
    // without the other.
    final year = car.year != null ? ' ${car.year}' : '';
    final base = '${car.makeName} ${car.modelName}$year';
    if (car.generationId == null) {
      return '$base · ${context.l10n.generationNotSpecified}';
    }

    // The label stored with the car is a snapshot taken in whatever language
    // was current when it was picked, so on its own it kept reading
    // «I поколение» under an Armenian interface. Re-resolve it from the
    // locale-aware generations list, and fall back to the stored text while
    // that is loading or if the request fails — a briefly stale label beats a
    // chip that flickers empty.
    final localised = ref.watch(generationsProvider(car.modelId)).maybeWhen(
          data: (rows) {
            for (final row in rows) {
              if (row['id'].toString() == car.generationId.toString()) {
                return row['name'] as String?;
              }
            }
            return null;
          },
          orElse: () => null,
        );

    return '$base · ${localised ?? car.generationLabel}';
  }

  Widget _buildCategoryError(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.l10n.categoriesLoadError,
          style: const TextStyle(color: Color(0xFFE0E0E0), fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => ref.invalidate(categoriesProvider),
          child: Text(
            context.l10n.retry,
            style: const TextStyle(color: Color(0xFFF5A623), fontSize: 16),
          ),
        ),
      ],
    );
  }
}

/// Row for one repair service category.
///
/// Deliberately plain: parts categories carry an icon because they are a fixed,
/// recognisable set, while service names are free text from the catalogue and a
/// generic icon on every row would add noise without adding meaning.
class _ServiceCategoryTile extends StatelessWidget {
  const _ServiceCategoryTile({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            // 56 dp: the project's minimum tap target (ACC-01).
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFFE0E0E0),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0xFF3D4050)),
      ],
    );
  }
}
