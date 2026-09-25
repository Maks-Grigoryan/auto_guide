// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sorted_filtered_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(sortedFilteredResults)
const sortedFilteredResultsProvider = SortedFilteredResultsProvider._();

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

final class SortedFilteredResultsProvider extends $FunctionalProvider<
        AsyncValue<List<VendorResult>>,
        List<VendorResult>,
        FutureOr<List<VendorResult>>>
    with
        $FutureModifier<List<VendorResult>>,
        $FutureProvider<List<VendorResult>> {
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
  const SortedFilteredResultsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sortedFilteredResultsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sortedFilteredResultsHash();

  @$internal
  @override
  $FutureProviderElement<List<VendorResult>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<VendorResult>> create(Ref ref) {
    return sortedFilteredResults(ref);
  }
}

String _$sortedFilteredResultsHash() =>
    r'63e8070d8f7c23d6ecb7b428e3d71359404c6712';
