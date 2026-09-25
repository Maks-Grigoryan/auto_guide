import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_service.g.dart';

// ---------------------------------------------------------------------------
// Yerevan city centre — fallback when location is denied (RES-06).
// ---------------------------------------------------------------------------
const double kYerevanLat = 40.1872;
const double kYerevanLng = 44.5152;

// ---------------------------------------------------------------------------
// Value objects
// ---------------------------------------------------------------------------

enum LocationPermissionStatus { granted, denied, deniedForever }

enum LocationResultStatus { granted, denied, deniedForever }

class LatLng {
  const LatLng(this.lat, this.lng);
  final double lat;
  final double lng;
}

class LocationResult {
  const LocationResult({
    required this.lat,
    required this.lng,
    required this.status,
  });
  final double lat;
  final double lng;
  final LocationResultStatus status;
}

// ---------------------------------------------------------------------------
// Delegate interface — injectable for tests.
// ---------------------------------------------------------------------------

abstract interface class LocationServiceDelegate {
  Future<bool> isLocationServiceEnabled();
  Future<LocationPermissionStatus> checkPermission();
  Future<LocationPermissionStatus> requestPermission();
  Future<LatLng> getCurrentPosition();
}

// ---------------------------------------------------------------------------
// Real delegate — thin wrapper over geolocator package.
// ---------------------------------------------------------------------------

class GeolocatorDelegate implements LocationServiceDelegate {
  @override
  Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    final p = await Geolocator.checkPermission();
    return _convert(p);
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    final p = await Geolocator.requestPermission();
    return _convert(p);
  }

  @override
  Future<LatLng> getCurrentPosition() async {
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      ),
    );
    return LatLng(pos.latitude, pos.longitude);
  }

  LocationPermissionStatus _convert(LocationPermission p) {
    switch (p) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationPermissionStatus.granted;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.denied;
    }
  }
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

/// Resolves device location with a Yerevan fallback on denial (RES-06).
///
/// Pitfall-3 guard: returns lat first, lng second in [LocationResult].
/// Consumers must pass lat before lng to SearchApi.searchParts.
class LocationService {
  LocationService({
    LocationServiceDelegate? delegate,
    Duration? permissionTimeout,
    Duration? positionTimeout,
  })  : _delegate = delegate ?? GeolocatorDelegate(),
        // Injectable so tests can exercise the fallback without waiting out the
        // real durations.
        _permissionTimeout = permissionTimeout ?? defaultPermissionTimeout,
        _positionTimeout = positionTimeout ?? defaultPositionTimeout;

  final LocationServiceDelegate _delegate;
  final Duration _permissionTimeout;
  final Duration _positionTimeout;

  /// Long enough for a person to read the system prompt and decide, short
  /// enough that ignoring it does not look like a frozen app.
  static const defaultPermissionTimeout = Duration(seconds: 12);

  /// A first GPS fix indoors can take a while; past this the city centre is a
  /// better answer than a blank screen.
  static const defaultPositionTimeout = Duration(seconds: 8);

  Future<LocationResult> resolve() async {
    final serviceEnabled = await _delegate.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationResult(
        lat: kYerevanLat,
        lng: kYerevanLng,
        status: LocationResultStatus.denied,
      );
    }

    var permission = await _delegate.checkPermission();
    if (permission == LocationPermissionStatus.deniedForever) {
      return const LocationResult(
        lat: kYerevanLat,
        lng: kYerevanLng,
        status: LocationResultStatus.deniedForever,
      );
    }

    if (permission == LocationPermissionStatus.denied) {
      // A permission prompt that is never answered used to hang resolve()
      // forever: the caller awaited it, so the screen simply never opened —
      // no spinner, no message, indistinguishable from a crash. Treat silence
      // as a refusal and carry on with the Yerevan fallback.
      permission = await _delegate.requestPermission().timeout(
            _permissionTimeout,
            onTimeout: () => LocationPermissionStatus.denied,
          );
    }

    if (permission == LocationPermissionStatus.deniedForever) {
      return const LocationResult(
        lat: kYerevanLat,
        lng: kYerevanLng,
        status: LocationResultStatus.deniedForever,
      );
    }

    if (permission != LocationPermissionStatus.granted) {
      return const LocationResult(
        lat: kYerevanLat,
        lng: kYerevanLng,
        status: LocationResultStatus.denied,
      );
    }

    // Same guard on the fix itself: a granted permission does not guarantee a
    // position ever arrives (indoors, GPS off mid-flight, a browser that stalls).
    final pos = await _delegate.getCurrentPosition().timeout(
      _positionTimeout,
      onTimeout: () => const LatLng(kYerevanLat, kYerevanLng),
    );
    return LocationResult(
      lat: pos.lat,
      lng: pos.lng,
      status: LocationResultStatus.granted,
    );
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

@riverpod
LocationService locationService(Ref ref) => LocationService();
