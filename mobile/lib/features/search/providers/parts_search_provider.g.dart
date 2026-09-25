// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parts_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Returns search results for the current [SearchParams].
///
/// Returns [] immediately when params are null (no submit yet — D-03).
/// On submit, calls SearchApi.searchParts with the submitted PartsQuery.

@ProviderFor(partsSearch)
const partsSearchProvider = PartsSearchProvider._();

/// Returns search results for the current [SearchParams].
///
/// Returns [] immediately when params are null (no submit yet — D-03).
/// On submit, calls SearchApi.searchParts with the submitted PartsQuery.

final class PartsSearchProvider extends $FunctionalProvider<
        AsyncValue<List<VendorResult>>,
        List<VendorResult>,
        FutureOr<List<VendorResult>>>
    with
        $FutureModifier<List<VendorResult>>,
        $FutureProvider<List<VendorResult>> {
  /// Returns search results for the current [SearchParams].
  ///
  /// Returns [] immediately when params are null (no submit yet — D-03).
  /// On submit, calls SearchApi.searchParts with the submitted PartsQuery.
  const PartsSearchProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'partsSearchProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$partsSearchHash();

  @$internal
  @override
  $FutureProviderElement<List<VendorResult>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<VendorResult>> create(Ref ref) {
    return partsSearch(ref);
  }
}

String _$partsSearchHash() => r'5eb4a087a26ca010f307d3ba2315df442d1ad14a';
