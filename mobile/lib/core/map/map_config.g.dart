// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_config.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mapAvailable)
const mapAvailableProvider = MapAvailableProvider._();

final class MapAvailableProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  const MapAvailableProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'mapAvailableProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$mapAvailableHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return mapAvailable(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$mapAvailableHash() => r'a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0';
