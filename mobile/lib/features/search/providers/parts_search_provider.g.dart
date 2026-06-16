// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parts_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(partsSearch)
const partsSearchProvider = PartsSearchProvider._();

final class PartsSearchProvider extends $FunctionalProvider<
        AsyncValue<List<VendorResult>>,
        List<VendorResult>,
        FutureOr<List<VendorResult>>>
    with
        $FutureModifier<List<VendorResult>>,
        $FutureProvider<List<VendorResult>> {
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

String _$partsSearchHash() => r'e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0';
