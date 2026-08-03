// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_categories_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(serviceCategories)
const serviceCategoriesProvider = ServiceCategoriesProvider._();

final class ServiceCategoriesProvider extends $FunctionalProvider<
        AsyncValue<List<ServiceCategory>>,
        List<ServiceCategory>,
        FutureOr<List<ServiceCategory>>>
    with
        $FutureModifier<List<ServiceCategory>>,
        $FutureProvider<List<ServiceCategory>> {
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

String _$serviceCategoriesHash() => r'f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0';
