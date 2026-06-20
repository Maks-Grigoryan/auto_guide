import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/vendor_result.dart';
import 'parts_search_provider.dart';
import 'search_params.dart';

part 'sorted_filtered_provider.g.dart';

/// Derived provider that applies client-side sort and filter to the already-
/// fetched parts search results.
///
/// Sort and availability/price filter changes update the list in-place with
/// NO new network request. Only a radius change (via updateFilter) triggers
/// a re-fetch because partsSearchProvider watches searchParamsProvider.
///
/// Sort behaviour:
///   distance — ascending distanceM (default)
///   price    — ascending minPrice; vendors with null minPrice sort LAST
///   rating   — descending rating; vendors with null rating sort LAST
///
/// Filter behaviour:
///   availabilityOnly=true  — drops vendors with null minPrice
///   minPrice=X             — keeps vendors with minPrice != null && >= X
///   maxPrice=Y             — keeps vendors with minPrice != null && <= Y
@riverpod
Future<List<VendorResult>> sortedFilteredResults(Ref ref) async {
  final params = ref.watch(searchParamsProvider);
  final raw = await ref.watch(partsSearchProvider.future);

  // Copy to a mutable list — do NOT mutate the cached raw list.
  var results = List<VendorResult>.from(raw);

  // --- Client-side filters (no network call) ---

  if (params?.availabilityOnly == true) {
    results = results.where((v) => v.minPrice != null).toList();
  }

  if (params?.minPrice != null) {
    results = results
        .where((v) => v.minPrice != null && v.minPrice! >= params!.minPrice!)
        .toList();
  }

  if (params?.maxPrice != null) {
    results = results
        .where((v) => v.minPrice != null && v.minPrice! <= params!.maxPrice!)
        .toList();
  }

  // --- Client-side sort ---

  switch (params?.sort ?? ResultSort.distance) {
    case ResultSort.distance:
      results.sort((a, b) => a.distanceM.compareTo(b.distanceM));
    case ResultSort.price:
      results.sort((a, b) {
        if (a.minPrice == null && b.minPrice == null) return 0;
        if (a.minPrice == null) return 1; // nulls last
        if (b.minPrice == null) return -1;
        return a.minPrice!.compareTo(b.minPrice!);
      });
    case ResultSort.rating:
      results.sort((a, b) {
        if (a.rating == null && b.rating == null) return 0;
        if (a.rating == null) return 1; // nulls last
        if (b.rating == null) return -1;
        return b.rating!.compareTo(a.rating!); // descending
      });
  }

  return results;
}
