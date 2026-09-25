/// Platform-neutral map SDK initialisation.
///
/// Exposes a single entry point, `Future<bool> initMapSdk()`, which returns
/// true only when a map SDK is ready to render. The return value feeds
/// [mapAvailableProvider] (see map_config.dart) and drives the D-04 graceful
/// degradation path: when it is false the «Карта» segment stays disabled and
/// MapUnavailableNotice is shown, while the list path remains fully usable.
///
/// Mobile uses the native Yandex MapKit SDK; web uses the Yandex Maps JS API
/// 3.0, which is a different product with a different API key. Neither
/// implementation is compiled into the other platform's bundle.
library;

export 'map_init_stub.dart'
    if (dart.library.io) 'map_init_mobile.dart'
    if (dart.library.js_interop) 'map_init_web.dart';
