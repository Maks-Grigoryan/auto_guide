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

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchApi>(value),
    );
  }
}

String _$searchApiHash() => r'ee8aba8b3f852a75f5be590e08fb9202a0a530d4';

/// Fetches the flat list of part categories from GET /catalog/part-categories.
///
/// Watches the locale rather than reading it once: category names come from
/// the server, so switching language has to re-fetch them. Without the watch,
/// the chrome changed language and the list underneath stayed in Russian.

@ProviderFor(categories)
const categoriesProvider = CategoriesProvider._();

/// Fetches the flat list of part categories from GET /catalog/part-categories.
///
/// Watches the locale rather than reading it once: category names come from
/// the server, so switching language has to re-fetch them. Without the watch,
/// the chrome changed language and the list underneath stayed in Russian.

final class CategoriesProvider extends $FunctionalProvider<
        AsyncValue<List<PartCategory>>,
        List<PartCategory>,
        FutureOr<List<PartCategory>>>
    with
        $FutureModifier<List<PartCategory>>,
        $FutureProvider<List<PartCategory>> {
  /// Fetches the flat list of part categories from GET /catalog/part-categories.
  ///
  /// Watches the locale rather than reading it once: category names come from
  /// the server, so switching language has to re-fetch them. Without the watch,
  /// the chrome changed language and the list underneath stayed in Russian.
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

String _$categoriesHash() => r'1195b0db1e6f2c9619e86ea5e3b1f6ce54dfab72';
