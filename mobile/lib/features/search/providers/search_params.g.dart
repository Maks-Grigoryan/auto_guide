// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_params.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SearchParams)
const searchParamsProvider = SearchParamsProvider._();

final class SearchParamsProvider
    extends $NotifierProvider<SearchParams, PartsQuery?> {
  const SearchParamsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'searchParamsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$searchParamsHash();

  @$internal
  @override
  SearchParams create() => SearchParams();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PartsQuery? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PartsQuery?>(value),
    );
  }
}

String _$searchParamsHash() => r'c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2';

abstract class _$SearchParams extends $Notifier<PartsQuery?> {
  PartsQuery? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PartsQuery?, PartsQuery?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<PartsQuery?, PartsQuery?>, PartsQuery?, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
