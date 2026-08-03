import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/location/location_service.dart';
import '../../l10n/l10n.dart';
import '../search/providers/repair_params.dart';
import '../search/providers/service_categories_provider.dart';
import '../parts_results/widgets/error_view.dart';

/// Browse screen for repair service categories.
///
/// Fetches categories from /catalog/service-categories via serviceCategoriesProvider.
/// On tap: resolves GPS (Yerevan fallback), submits RepairQuery, navigates to /results/repair.
/// No OEM/text search field on the repair path.
class ServiceCategoriesPage extends ConsumerWidget {
  const ServiceCategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catAsync = ref.watch(serviceCategoriesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1C1F26),
      appBar: AppBar(
        title: Text(context.l10n.serviceCategories),
        backgroundColor: const Color(0xFF2A2D36),
        leading: BackButton(
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: catAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFF5A623)),
          ),
          error: (_, __) => ErrorView(
            onRetry: () => ref.invalidate(serviceCategoriesProvider),
          ),
          data: (categories) => ListView.builder(
            itemCount: categories.length,
            itemBuilder: (_, i) {
              final category = categories[i];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _onCategoryTap(
                        context, ref, category.id, category.name),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 56),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                category.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFFE0E0E0),
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Divider(
                    color: Color(0xFF3D4050),
                    thickness: 1,
                    height: 1,
                    indent: 16,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _onCategoryTap(
    BuildContext context,
    WidgetRef ref,
    int categoryId,
    String categoryName,
  ) async {
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

    ref.read(repairParamsProvider.notifier).submit(
          RepairQuery(
            lat: result.lat,
            lng: result.lng,
            serviceCategoryId: categoryId,
          ),
        );

    if (context.mounted) {
      context.push('/results/repair', extra: categoryName);
    }
  }
}
