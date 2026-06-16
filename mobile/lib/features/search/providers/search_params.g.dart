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

String _$searchParamsHash() => r'b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0';

abstract class _$SearchParams extends $Notifier<PartsQuery?> {
  PartsQuery? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PartsQuery?, PartsQuery?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<PartsQuery?, PartsQuery?>,
        PartsQuery?,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
