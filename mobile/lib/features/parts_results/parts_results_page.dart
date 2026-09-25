import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/location/location_service.dart';
import '../../core/map/map_config.dart';
import '../../l10n/l10n.dart';
import '../search/providers/parts_search_provider.dart';
import '../search/providers/sorted_filtered_provider.dart';
import 'widgets/map_empty_notice.dart';
import 'widgets/map_unavailable_notice.dart';
import 'widgets/results_map_view.dart';
import 'widgets/results_view_toggle.dart';
import 'widgets/sort_filter_sheet.dart';
import '../../core/models/vendor_result.dart';
import 'widgets/vendor_result_card.dart';
import 'widgets/empty_results_view.dart';
import 'widgets/error_view.dart';
import 'widgets/location_denied_view.dart';

/// Results screen: parts search results with list⇄map toggle (RES-02, D-01).
///
/// Consumes [sortedFilteredResultsProvider] (derived from [partsSearchProvider])
/// for BOTH list and map views — switching is instant with no re-fetch (D-01).
/// Sort/availability/price changes update the list in-place (RES-05).
/// Radius re-fetches on slider release.
///
/// D-04: when the MapKit key is missing, [mapAvailableProvider] is false;
/// the «Карта» segment is disabled and [MapUnavailableNotice] is shown.
class PartsResultsPage extends ConsumerStatefulWidget {
  const PartsResultsPage({
    super.key,
    this.categoryName,
    this.query,
    this.locationStatus = LocationResultStatus.granted,
  });

  final String? categoryName;
  final String? query;
  final LocationResultStatus locationStatus;

  @override
  ConsumerState<PartsResultsPage> createState() => _PartsResultsPageState();
}

class _PartsResultsPageState extends ConsumerState<PartsResultsPage> {
  /// 0 = list view, 1 = map view. Survives sort/filter changes (D-01).
  int _viewIndex = 0;

  String _title(BuildContext context) {
    if (widget.categoryName != null) return widget.categoryName!;
    if (widget.query != null) {
      return context.l10n.searchResultsFor(widget.query!);
    }
    return context.l10n.results;
  }

  bool get _locationDenied =>
      widget.locationStatus == LocationResultStatus.denied ||
      widget.locationStatus == LocationResultStatus.deniedForever;

  @override
  Widget build(BuildContext context) {
    // Both list and map read the SAME provider — no second fetch (D-01).
    final searchAsync = ref.watch(sortedFilteredResultsProvider);
    final mapAvailable = ref.watch(mapAvailableProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_title(context)),
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
            onRetry: () => ref.invalidate(partsSearchProvider),
          ),
          data: (results) {
            return Column(
              children: [
                // List⇄map toggle (pinned at top, 48 dp, full-width md padding).
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

                // Sort & filter trigger row (visible in both list and map views).
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.tune),
                      label: Text(context.l10n.sortAndFilters),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        foregroundColor: const Color(0xFFFFFFFF),
                        side: const BorderSide(color: Color(0xFF3D4050)),
                      ),
                      onPressed: () {
                        showModalBottomSheet<void>(
                          context: context,
                          backgroundColor: const Color(0xFF2A2D36),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          isScrollControlled: true,
                          builder: (_) => const SortFilterSheet(),
                        );
                      },
                    ),
                  ),
                ),

                // Location-denied banner (non-blocking; only in list/parts).
                if (_locationDenied)
                  LocationDeniedView(
                    isPermanent: widget.locationStatus ==
                        LocationResultStatus.deniedForever,
                    onRetry: () => ref.invalidate(partsSearchProvider),
                    onOpenSettings: () {
                      Geolocator.openAppSettings();
                    },
                  ),

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
      // The map stays whole even with nothing to show: it is the point of the
      // tab, and the user still wants to see the area being searched. The
      // notice sits in a band at the top rather than centred across the map,
      // which covered exactly the part worth looking at.
      return Stack(
        children: [
          const ResultsMapView(vendors: []),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: MapEmptyNotice(text: context.l10n.nothingNearby),
          ),
        ],
      );
    }
    return ResultsMapView(vendors: List<VendorResult>.from(results));
  }
}
