// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repair_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(repairSearch)
const repairSearchProvider = RepairSearchProvider._();

final class RepairSearchProvider extends $FunctionalProvider<
        AsyncValue<List<VendorResult>>,
        List<VendorResult>,
        FutureOr<List<VendorResult>>>
    with
        $FutureModifier<List<VendorResult>>,
        $FutureProvider<List<VendorResult>> {
  const RepairSearchProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'repairSearchProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$repairSearchHash();

  @$internal
  @override
  $FutureProviderElement<List<VendorResult>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<VendorResult>> create(Ref ref) {
    return repairSearch(ref);
  }
}

String _$repairSearchHash() => r'b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2';
