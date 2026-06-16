// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dioHash() => r'b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0';

/// See also [dio].
@ProviderFor(dio)
final dioProvider = AutoDisposeProvider<Dio>.internal(
  dio,
  name: r'dioProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$dioHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DioRef = AutoDisposeProviderRef<Dio>;

String _$makesHash() => r'c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1';

/// See also [makes].
@ProviderFor(makes)
final makesProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
  makes,
  name: r'makesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$makesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MakesRef = AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;

String _$modelsHash() => r'd3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2';

/// See also [models].
@ProviderFor(models)
const modelsProvider = ModelsFamily();

/// See also [models].
class ModelsFamily extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [models].
  const ModelsFamily();

  /// See also [models].
  ModelsProvider call(
    int makeId,
  ) {
    return ModelsProvider(
      makeId,
    );
  }

  @override
  ModelsProvider getProviderOverride(
    covariant ModelsProvider provider,
  ) {
    return call(
      provider.makeId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'modelsProvider';
}

/// See also [models].
class ModelsProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [models].
  ModelsProvider(
    int makeId,
  ) : this._internal(
          (ref) => models(
            ref as ModelsRef,
            makeId,
          ),
          from: modelsProvider,
          name: r'modelsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$modelsHash,
          dependencies: ModelsFamily._dependencies,
          allTransitiveDependencies: ModelsFamily._allTransitiveDependencies,
          makeId: makeId,
        );

  ModelsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.makeId,
  }) : super.internal();

  final int makeId;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(ModelsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ModelsProvider._internal(
        (ref) => create(ref as ModelsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        makeId: makeId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _ModelsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ModelsProvider && other.makeId == makeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, makeId.hashCode);
    return _SystemHash.finish(hash);
  }
}

mixin ModelsRef on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  int get makeId;
}

class _ModelsProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with ModelsRef {
  _ModelsProviderElement(super.provider);

  @override
  int get makeId => (origin as ModelsProvider).makeId;
}

String _$generationsHash() =>
    r'e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3';

/// See also [generations].
@ProviderFor(generations)
const generationsProvider = GenerationsFamily();

/// See also [generations].
class GenerationsFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [generations].
  const GenerationsFamily();

  /// See also [generations].
  GenerationsProvider call(
    int modelId,
  ) {
    return GenerationsProvider(
      modelId,
    );
  }

  @override
  GenerationsProvider getProviderOverride(
    covariant GenerationsProvider provider,
  ) {
    return call(
      provider.modelId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'generationsProvider';
}

/// See also [generations].
class GenerationsProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [generations].
  GenerationsProvider(
    int modelId,
  ) : this._internal(
          (ref) => generations(
            ref as GenerationsRef,
            modelId,
          ),
          from: generationsProvider,
          name: r'generationsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$generationsHash,
          dependencies: GenerationsFamily._dependencies,
          allTransitiveDependencies:
              GenerationsFamily._allTransitiveDependencies,
          modelId: modelId,
        );

  GenerationsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.modelId,
  }) : super.internal();

  final int modelId;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(GenerationsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GenerationsProvider._internal(
        (ref) => create(ref as GenerationsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        modelId: modelId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
      createElement() {
    return _GenerationsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GenerationsProvider && other.modelId == modelId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, modelId.hashCode);
    return _SystemHash.finish(hash);
  }
}

mixin GenerationsRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  int get modelId;
}

class _GenerationsProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with GenerationsRef {
  _GenerationsProviderElement(super.provider);

  @override
  int get modelId => (origin as GenerationsProvider).modelId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    hash = 0x1fffffff & (hash + value);
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}
