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
  LocationService({LocationServiceDelegate? delegate})
      : _delegate = delegate ?? GeolocatorDelegate();

  final LocationServiceDelegate _delegate;

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
      permission = await _delegate.requestPermission();
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

    final pos = await _delegate.getCurrentPosition();
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
