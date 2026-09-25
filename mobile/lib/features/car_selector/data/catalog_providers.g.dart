// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dio)
const dioProvider = DioProvider._();

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  const DioProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dioProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'c5edccbbab7d0d966519385e8f9e292a6795543d';

/// Fetches all car makes from GET /catalog/makes.

@ProviderFor(makes)
const makesProvider = MakesProvider._();

/// Fetches all car makes from GET /catalog/makes.

final class MakesProvider extends $FunctionalProvider<
        AsyncValue<List<Map<String, dynamic>>>,
        List<Map<String, dynamic>>,
        FutureOr<List<Map<String, dynamic>>>>
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $FutureProvider<List<Map<String, dynamic>>> {
  /// Fetches all car makes from GET /catalog/makes.
  const MakesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'makesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$makesHash();

  @$internal
  @override
  $FutureProviderElement<List<Map<String, dynamic>>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Map<String, dynamic>>> create(Ref ref) {
    return makes(ref);
  }
}

String _$makesHash() => r'832955c6ce006ac70885e025c97c6c7675f42455';

/// Fetches models for a given [makeId] from GET /catalog/models?makeId=...

@ProviderFor(models)
const modelsProvider = ModelsFamily._();

/// Fetches models for a given [makeId] from GET /catalog/models?makeId=...

final class ModelsProvider extends $FunctionalProvider<
        AsyncValue<List<Map<String, dynamic>>>,
        List<Map<String, dynamic>>,
        FutureOr<List<Map<String, dynamic>>>>
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $FutureProvider<List<Map<String, dynamic>>> {
  /// Fetches models for a given [makeId] from GET /catalog/models?makeId=...
  const ModelsProvider._(
      {required ModelsFamily super.from, required int super.argument})
      : super(
          retry: null,
          name: r'modelsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$modelsHash();

  @override
  String toString() {
    return r'modelsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Map<String, dynamic>>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Map<String, dynamic>>> create(Ref ref) {
    final argument = this.argument as int;
    return models(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ModelsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$modelsHash() => r'9a8b2d37225e023e7d1a7719b03d2a017acdd58b';

/// Fetches models for a given [makeId] from GET /catalog/models?makeId=...

final class ModelsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Map<String, dynamic>>>, int> {
  const ModelsFamily._()
      : super(
          retry: null,
          name: r'modelsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Fetches models for a given [makeId] from GET /catalog/models?makeId=...

  ModelsProvider call(
    int makeId,
  ) =>
      ModelsProvider._(argument: makeId, from: this);

  @override
  String toString() => r'modelsProvider';
}

/// Fetches generations for a given [modelId] from GET /catalog/generations?modelId=...

@ProviderFor(generations)
const generationsProvider = GenerationsFamily._();

/// Fetches generations for a given [modelId] from GET /catalog/generations?modelId=...

final class GenerationsProvider extends $FunctionalProvider<
        AsyncValue<List<Map<String, dynamic>>>,
        List<Map<String, dynamic>>,
        FutureOr<List<Map<String, dynamic>>>>
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $FutureProvider<List<Map<String, dynamic>>> {
  /// Fetches generations for a given [modelId] from GET /catalog/generations?modelId=...
  const GenerationsProvider._(
      {required GenerationsFamily super.from, required int super.argument})
      : super(
          retry: null,
          name: r'generationsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$generationsHash();

  @override
  String toString() {
    return r'generationsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Map<String, dynamic>>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Map<String, dynamic>>> create(Ref ref) {
    final argument = this.argument as int;
    return generations(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GenerationsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$generationsHash() => r'af6c7d9de98ee182f9c87a3f0d5dca20d4c7e49c';

/// Fetches generations for a given [modelId] from GET /catalog/generations?modelId=...

final class GenerationsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Map<String, dynamic>>>, int> {
  const GenerationsFamily._()
      : super(
          retry: null,
          name: r'generationsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Fetches generations for a given [modelId] from GET /catalog/generations?modelId=...

  GenerationsProvider call(
    int modelId,
  ) =>
      GenerationsProvider._(argument: modelId, from: this);

  @override
  String toString() => r'generationsProvider';
}
