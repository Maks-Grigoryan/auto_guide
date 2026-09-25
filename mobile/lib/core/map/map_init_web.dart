import 'dart:js_interop';

import 'map_config.dart';

/// Bridge to `window.avtoMap.init` defined in web/yandex_map.js.
///
/// The helper injects the Yandex Maps JS API 2.1 script tag with the supplied
/// key and resolves once `ymaps.ready()` settles. Resolves false instead of
/// throwing when the script fails to load.
@JS('avtoMap.init')
external JSPromise<JSBoolean> _avtoMapInit(JSString apiKey);

/// Yandex Maps JS API 2.1 initialisation (web).
///
/// Mirrors the mobile contract exactly (D-04): an empty key skips loading
/// altogether, and any failure degrades to the list-only path rather than
/// breaking the page.
///
/// NOTE: the JS API key is a *different* credential from the mobile MapKit
/// key even though both arrive via --dart-define=MAPKIT_API_KEY. Provision a
/// JavaScript API key for web builds; a MapKit key is rejected with 403.
Future<bool> initMapSdk() async {
  if (!mapkitKeyPresent) return false;
  try {
    final ok = await _avtoMapInit(kMapkitApiKey.toJS).toDart;
    return ok.toDart;
  } catch (_) {
    // Script blocked, key rejected, or helper missing — degrade to list (D-04).
    return false;
  }
}
