// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sorted_filtered_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sortedFilteredResults)
const sortedFilteredResultsProvider = SortedFilteredResultsProvider._();

final class SortedFilteredResultsProvider extends $FunctionalProvider<
        AsyncValue<List<VendorResult>>,
        List<VendorResult>,
        FutureOr<List<VendorResult>>>
    with
        $FutureModifier<List<VendorResult>>,
        $FutureProvider<List<VendorResult>> {
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
    r'f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0';
