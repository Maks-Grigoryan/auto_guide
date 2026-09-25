// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_categories_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches the flat list of service categories from GET /catalog/service-categories.
///
/// Does NOT redefine searchApiProvider — imports it from categories_provider.dart.
///
/// Watches the locale for the same reason as the part categories: these names
/// are server data, so a language switch has to re-fetch them rather than
/// leaving «Двигатель и КПП» sitting under an Armenian heading.

@ProviderFor(serviceCategories)
const serviceCategoriesProvider = ServiceCategoriesProvider._();

/// Fetches the flat list of service categories from GET /catalog/service-categories.
///
/// Does NOT redefine searchApiProvider — imports it from categories_provider.dart.
///
/// Watches the locale for the same reason as the part categories: these names
/// are server data, so a language switch has to re-fetch them rather than
/// leaving «Двигатель и КПП» sitting under an Armenian heading.

final class ServiceCategoriesProvider extends $FunctionalProvider<
        AsyncValue<List<ServiceCategory>>,
        List<ServiceCategory>,
        FutureOr<List<ServiceCategory>>>
    with
        $FutureModifier<List<ServiceCategory>>,
        $FutureProvider<List<ServiceCategory>> {
  /// Fetches the flat list of service categories from GET /catalog/service-categories.
  ///
  /// Does NOT redefine searchApiProvider — imports it from categories_provider.dart.
  ///
  /// Watches the locale for the same reason as the part categories: these names
  /// are server data, so a language switch has to re-fetch them rather than
  /// leaving «Двигатель и КПП» sitting under an Armenian heading.
  const ServiceCategoriesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'serviceCategoriesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$serviceCategoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<ServiceCategory>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<ServiceCategory>> create(Ref ref) {
    return serviceCategories(ref);
  }
}

String _$serviceCategoriesHash() => r'898ea92021458b271c85894526755351ad2e6ab3';
