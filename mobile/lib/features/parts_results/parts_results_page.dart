import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/location/location_service.dart';
import '../search/providers/parts_search_provider.dart';
import 'widgets/vendor_result_card.dart';
import 'widgets/empty_results_view.dart';
import 'widgets/error_view.dart';
import 'widgets/location_denied_view.dart';

/// Results screen: displays distance-sorted vendor list for a parts search.
///
/// Consumes [partsSearchProvider] via AsyncValue.when.
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
    final searchAsync = ref.watch(partsSearchProvider);

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
                if (_locationDenied)
                  LocationDeniedView(
                    isPermanent:
                        locationStatus == LocationResultStatus.deniedForever,
                    onRetry: () => ref.invalidate(partsSearchProvider),
                    onOpenSettings: () {
                      // geolocator.openAppSettings() — deferred to Phase 4
                    },
                  ),
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
