// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categories_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(searchApi)
const searchApiProvider = SearchApiProvider._();

final class SearchApiProvider
    extends $FunctionalProvider<SearchApi, SearchApi, SearchApi>
    with $Provider<SearchApi> {
  const SearchApiProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'searchApiProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$searchApiHash();

  @$internal
  @override
  $ProviderElement<SearchApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SearchApi create(Ref ref) {
    return searchApi(ref);
  }

  /// {@macro riverpid.override_with_value}
  Override overrideWithValue(SearchApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchApi>(value),
    );
  }
}

String _$searchApiHash() => r'c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0';

@ProviderFor(categories)
const categoriesProvider = CategoriesProvider._();

final class CategoriesProvider extends $FunctionalProvider<
        AsyncValue<List<PartCategory>>,
        List<PartCategory>,
        FutureOr<List<PartCategory>>>
    with
        $FutureModifier<List<PartCategory>>,
        $FutureProvider<List<PartCategory>> {
  const CategoriesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'categoriesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$categoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<PartCategory>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<PartCategory>> create(Ref ref) {
    return categories(ref);
  }
}

String _$categoriesHash() => r'd1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0';
