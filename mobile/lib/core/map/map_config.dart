import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_config.g.dart';

/// Yandex MapKit API key — passed via --dart-define=MAPKIT_API_KEY=... at build.
/// Empty string = degraded mode (D-04). NEVER commit the real key.
const String kMapkitApiKey = String.fromEnvironment(
  'MAPKIT_API_KEY',
  defaultValue: '',
);

/// True when a non-empty key was provided at build time.
bool get mapkitKeyPresent => kMapkitApiKey.isNotEmpty;

/// Whether the Yandex MapKit SDK was successfully initialised.
///
/// Defaults to false (unavailable). Overridden in main() via
/// ProviderScope.overrides after the init attempt (D-04 guard).
/// Consumers: ResultsViewToggle (disable «Карта» segment), MapUnavailableNotice.
@riverpod
bool mapAvailable(Ref ref) => false;
