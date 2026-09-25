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

String _$searchParamsHash() => r'a1c01101a3eb45543ac0048d983006291c071775';

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
