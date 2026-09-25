// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_config.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the Yandex MapKit SDK was successfully initialised.
///
/// Defaults to false (unavailable). Overridden in main() via
/// ProviderScope.overrides after the init attempt (D-04 guard).
/// Consumers: ResultsViewToggle (disable «Карта» segment), MapUnavailableNotice.

@ProviderFor(mapAvailable)
const mapAvailableProvider = MapAvailableProvider._();

/// Whether the Yandex MapKit SDK was successfully initialised.
///
/// Defaults to false (unavailable). Overridden in main() via
/// ProviderScope.overrides after the init attempt (D-04 guard).
/// Consumers: ResultsViewToggle (disable «Карта» segment), MapUnavailableNotice.

final class MapAvailableProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the Yandex MapKit SDK was successfully initialised.
  ///
  /// Defaults to false (unavailable). Overridden in main() via
  /// ProviderScope.overrides after the init attempt (D-04 guard).
  /// Consumers: ResultsViewToggle (disable «Карта» segment), MapUnavailableNotice.
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

String _$mapAvailableHash() => r'f93da15ab788d2dbb62b29eef6058582e9f82c0c';
