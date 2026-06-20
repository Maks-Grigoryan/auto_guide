import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/location/location_service.dart';
import '../search/providers/parts_search_provider.dart';
import '../search/providers/sorted_filtered_provider.dart';
import 'widgets/sort_filter_sheet.dart';
import 'widgets/vendor_result_card.dart';
import 'widgets/empty_results_view.dart';
import 'widgets/error_view.dart';
import 'widgets/location_denied_view.dart';

/// Results screen: displays vendor list for a parts search with sort & filter.
///
/// Consumes [sortedFilteredResultsProvider] (derived from [partsSearchProvider])
/// via AsyncValue.when. Sort/availability/price changes update the list in-place
/// with no new network request (RES-05). Radius re-fetches on slider release.
/// Handles all four async states: loading / empty / error / location-denied.
/// Location-denied is non-blocking — Yerevan-fallback results still render.
class PartsResultsPage extends ConsumerWidget {
  const PartsResultsPage({
    super.key,
    this.categoryName,
    this.query,
    this.locationStatus = LocationResultStatus.granted,
  });

  /// If browsing by category, the displayed name ("Тормоза").
  final String? categoryName;

  /// If searching by OEM query, the raw query string.
  final String? query;

  /// Location permission status — drives LocationDeniedView banner.
  final LocationResultStatus locationStatus;

  String get _title {
    if (categoryName != null) return categoryName!;
    if (query != null) return 'Поиск: $query';
    return 'Результаты';
  }

  bool get _locationDenied =>
      locationStatus == LocationResultStatus.denied ||
      locationStatus == LocationResultStatus.deniedForever;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the derived sorted/filtered provider — no new fetch on sort change.
    final searchAsync = ref.watch(sortedFilteredResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
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
            if (results.isEmpty) {
              return EmptyResultsView(
                onBack: () => Navigator.of(context).maybePop(),
              );
            }
            return Column(
              children: [
                // Sort & filter trigger row (48 dp height, above results)
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
                      label: const Text('Сортировка и фильтры'),
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

                // Location-denied banner (non-blocking)
                if (_locationDenied)
                  LocationDeniedView(
                    isPermanent:
                        locationStatus == LocationResultStatus.deniedForever,
                    onRetry: () => ref.invalidate(partsSearchProvider),
                    onOpenSettings: () {
                      // Wire deferred Phase-3 hook — open app location settings.
                      Geolocator.openAppSettings();
                    },
                  ),

                // Results list
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => VendorResultCard(vendor: results[i]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
