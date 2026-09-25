import 'package:yandex_maps_mapkit/init.dart' as mapkit_init;

import 'map_config.dart';

/// Native Yandex MapKit initialisation (Android / iOS).
///
/// Behaviour is unchanged from the original inline block in main.dart (D-04):
/// a missing or empty key skips init entirely rather than crashing, and an
/// init failure is swallowed so the list path stays fully usable.
Future<bool> initMapSdk() async {
  if (!mapkitKeyPresent) return false;
  try {
    await mapkit_init.initMapkit(apiKey: kMapkitApiKey);
    return true;
  } catch (_) {
    // Graceful degradation — «Карта» segment will be disabled (D-04).
    return false;
  }
}
