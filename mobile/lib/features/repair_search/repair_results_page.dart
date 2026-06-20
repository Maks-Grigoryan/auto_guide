import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../search/providers/repair_search_provider.dart';
import '../parts_results/widgets/vendor_result_card.dart';
import '../parts_results/widgets/empty_results_view.dart';
import '../parts_results/widgets/error_view.dart';

/// Repair results screen — mirrors PartsResultsPage for the repair vertical.
///
/// Watches [repairSearchProvider] via AsyncValue.when.
/// Handles all async states: loading / empty / error / data.
/// No OEM/text search or location-denied banner (repair is category-browse only).
class RepairResultsPage extends ConsumerWidget {
  const RepairResultsPage({
    super.key,
    this.categoryName,
  });

  /// Service category name shown in the AppBar (e.g. "Развал-схождение").
  /// Falls back to «Ремонт» when null.
  final String? categoryName;

  String get _title => categoryName ?? 'Ремонт';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchAsync = ref.watch(repairSearchProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1C1F26),
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: const Color(0xFF2A2D36),
        leading: BackButton(
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: searchAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFF5A623)),
          ),
          error: (_, __) => ErrorView(
            onRetry: () => ref.invalidate(repairSearchProvider),
          ),
          data: (results) {
            if (results.isEmpty) {
              return EmptyResultsView(
                onBack: () => Navigator.of(context).maybePop(),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => VendorResultCard(vendor: results[i]),
            );
          },
        ),
      ),
    );
  }
}
