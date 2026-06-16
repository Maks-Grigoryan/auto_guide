import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_params.g.dart';

// ---------------------------------------------------------------------------
// PartsQuery — immutable value object passed to search_parts.
// ---------------------------------------------------------------------------

class PartsQuery {
  const PartsQuery({
    required this.lat,
    required this.lng,
    this.radius = 20000,
    this.makeId,
    this.modelId,
    this.generationId,
    this.categoryId,
    this.query,
  });

  final double lat;
  final double lng;
  final int radius;
  final int? makeId;
  final int? modelId;
  final int? generationId;
  final int? categoryId;
  final String? query;

  bool get isEmpty => lat == 0 && lng == 0 && categoryId == null && query == null;

  @override
  String toString() =>
      'PartsQuery(lat: $lat, lng: $lng, radius: $radius, '
      'makeId: $makeId, modelId: $modelId, generationId: $generationId, '
      'categoryId: $categoryId, query: $query)';
}

// ---------------------------------------------------------------------------
// SearchParams Notifier — submit-triggered (D-03).
//
// Starts empty (no request before submit).
// submit(q) replaces state once, triggering partsSearchProvider.
// ---------------------------------------------------------------------------

@riverpod
class SearchParams extends _$SearchParams {
  @override
  PartsQuery? build() => null; // null = no search submitted yet

  /// Submit a new search. Replaces state to trigger dependent providers.
  void submit(PartsQuery query) {
    state = query;
  }

  /// Clear search state (e.g. when user changes car selection).
  void clear() {
    state = null;
  }
}
