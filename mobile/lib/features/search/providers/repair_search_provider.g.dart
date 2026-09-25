// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repair_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Returns repair search results for the current [RepairParams].
///
/// Returns [] immediately when params are null (no submit yet).
/// On submit, calls SearchApi.searchRepair with the submitted RepairQuery.

@ProviderFor(repairSearch)
const repairSearchProvider = RepairSearchProvider._();

/// Returns repair search results for the current [RepairParams].
///
/// Returns [] immediately when params are null (no submit yet).
/// On submit, calls SearchApi.searchRepair with the submitted RepairQuery.

final class RepairSearchProvider extends $FunctionalProvider<
        AsyncValue<List<VendorResult>>,
        List<VendorResult>,
        FutureOr<List<VendorResult>>>
    with
        $FutureModifier<List<VendorResult>>,
        $FutureProvider<List<VendorResult>> {
  /// Returns repair search results for the current [RepairParams].
  ///
  /// Returns [] immediately when params are null (no submit yet).
  /// On submit, calls SearchApi.searchRepair with the submitted RepairQuery.
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

String _$repairSearchHash() => r'34bda881c1ff5c77f04baf8678d8656b909a7193';
