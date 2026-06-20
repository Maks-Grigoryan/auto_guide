import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_params.g.dart';

// ---------------------------------------------------------------------------
// ResultSort — sort order for the derived sorted/filtered provider.
// ---------------------------------------------------------------------------

enum ResultSort { distance, price, rating }

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
    this.sort = ResultSort.distance,
    this.availabilityOnly = false,
    this.minPrice,
    this.maxPrice,
  });

  final double lat;
  final double lng;
  final int radius;
  final int? makeId;
  final int? modelId;
  final int? generationId;
  final int? categoryId;
  final String? query;

  /// Client-side sort order (does NOT trigger a network re-fetch).
  final ResultSort sort;

  /// When true, only vendors with a non-null minPrice are shown.
  final bool availabilityOnly;

  /// Client-side minimum price filter (inclusive). Null = no floor.
  final double? minPrice;

  /// Client-side maximum price filter (inclusive). Null = no ceiling.
  final double? maxPrice;

  bool get isEmpty => lat == 0 && lng == 0 && categoryId == null && query == null;

  /// Returns a new PartsQuery with the given fields replaced.
  PartsQuery copyWith({
    double? lat,
    double? lng,
    int? radius,
    int? makeId,
    int? modelId,
    int? generationId,
    int? categoryId,
    String? query,
    ResultSort? sort,
    bool? availabilityOnly,
    double? minPrice,
    double? maxPrice,
  }) {
    return PartsQuery(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      radius: radius ?? this.radius,
      makeId: makeId ?? this.makeId,
      modelId: modelId ?? this.modelId,
      generationId: generationId ?? this.generationId,
      categoryId: categoryId ?? this.categoryId,
      query: query ?? this.query,
      sort: sort ?? this.sort,
      availabilityOnly: availabilityOnly ?? this.availabilityOnly,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }

  @override
  String toString() =>
      'PartsQuery(lat: $lat, lng: $lng, radius: $radius, '
      'makeId: $makeId, modelId: $modelId, generationId: $generationId, '
      'categoryId: $categoryId, query: $query, sort: $sort, '
      'availabilityOnly: $availabilityOnly, minPrice: $minPrice, maxPrice: $maxPrice)';
}

// ---------------------------------------------------------------------------
// SearchParams Notifier — submit-triggered (D-03).
//
// Starts empty (no request before submit).
// submit(q) replaces state once, triggering partsSearchProvider.
// updateSort / updateFilter mutate sort+filter fields only — no re-fetch
// (radius via updateFilter is the one exception that DOES re-fetch since
// partsSearchProvider watches searchParamsProvider).
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

  /// Update sort order. Does NOT trigger a network re-fetch.
  /// No-op when state is null (no search submitted).
  void updateSort(ResultSort sort) {
    if (state == null) return;
    state = state!.copyWith(sort: sort);
  }

  /// Update client-side filters.
  /// Radius change WILL trigger a network re-fetch (server-side param).
  /// availabilityOnly / minPrice / maxPrice do NOT trigger a re-fetch.
  /// No-op when state is null (no search submitted).
  void updateFilter({
    bool? availabilityOnly,
    double? minPrice,
    double? maxPrice,
    int? radius,
  }) {
    if (state == null) return;
    state = state!.copyWith(
      availabilityOnly: availabilityOnly,
      minPrice: minPrice,
      maxPrice: maxPrice,
      radius: radius,
    );
  }
}
