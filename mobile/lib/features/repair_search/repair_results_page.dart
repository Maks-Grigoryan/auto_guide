import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/map/map_config.dart';
import '../search/providers/repair_search_provider.dart';
import '../parts_results/widgets/map_unavailable_notice.dart';
import '../parts_results/widgets/results_map_view.dart';
import '../parts_results/widgets/results_view_toggle.dart';
import '../parts_results/widgets/vendor_result_card.dart';
import '../parts_results/widgets/empty_results_view.dart';
import '../parts_results/widgets/error_view.dart';

/// Repair results screen — mirrors PartsResultsPage for the repair vertical.
///
/// Watches [repairSearchProvider] via AsyncValue.when.
/// Hosts the same [ResultsViewToggle] + [ResultsMapView] surface (RES-02, D-01).
/// Both list and map read the SAME [repairSearchProvider] — no second fetch.
/// D-04: «Карта» disabled + [MapUnavailableNotice] when map unavailable.
/// No OEM/text search or location-denied banner (repair is category-browse only).
class RepairResultsPage extends ConsumerStatefulWidget {
  const RepairResultsPage({
    super.key,
    this.categoryName,
  });

  /// Service category name shown in the AppBar (e.g. "Развал-схождение").
  final String? categoryName;

  @override
  ConsumerState<RepairResultsPage> createState() => _RepairResultsPageState();
}

class _RepairResultsPageState extends ConsumerState<RepairResultsPage> {
  /// 0 = list view, 1 = map view. Survives filter changes (D-01).
  int _viewIndex = 0;

  String get _title => widget.categoryName ?? 'Ремонт';

  @override
  Widget build(BuildContext context) {
    // Both list and map read the SAME provider — no second fetch (D-01).
    final searchAsync = ref.watch(repairSearchProvider);
    final mapAvailable = ref.watch(mapAvailableProvider);

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
            return Column(
              children: [
                // List⇄map toggle (pinned at top, 48 dp).
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ResultsViewToggle(
                    selectedIndex: _viewIndex,
                    mapAvailable: mapAvailable,
                    onListSelected: () => setState(() => _viewIndex = 0),
                    onMapSelected: () => setState(() => _viewIndex = 1),
                  ),
                ),

                // D-04: show notice when map is unavailable.
                if (!mapAvailable) const MapUnavailableNotice(),

                // Body: list (index 0) or map (index 1), both from same provider.
                Expanded(
                  child: _viewIndex == 1 && mapAvailable
                      ? _buildMapView(results)
                      : _buildListView(results),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildListView(List<dynamic> results) {
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
  }

  Widget _buildMapView(List<dynamic> results) {
    if (results.isEmpty) {
      // Map-view empty: map centred on Yerevan + overlay notice (UI-SPEC).
      return Stack(
        children: [
          ResultsMapView(vendors: const []),
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Поблизости ничего не найдено',
                style: TextStyle(fontSize: 16, color: Color(0xFFE0E0E0)),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }
    return ResultsMapView(vendors: List.of(results));
  }
}
