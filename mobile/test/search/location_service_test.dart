import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

import 'package:avto_app/core/location/location_service.dart';

// ---------------------------------------------------------------------------
// Unit tests for LocationService.
//
// The service wraps geolocator behind a LocationServiceDelegate interface
// so we can inject a fake without a physical device.
// Three cases per spec (RES-06):
//   1. granted  → returns actual lat/lng from device
//   2. denied   → returns Yerevan fallback (40.1872, 44.5152), status=denied
//   3. deniedForever → same fallback coords, status=deniedForever
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Fake delegates
// ---------------------------------------------------------------------------

class _GrantedDelegate implements LocationServiceDelegate {
  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<LocationPermissionStatus> checkPermission() async =>
      LocationPermissionStatus.granted;

  @override
  Future<LocationPermissionStatus> requestPermission() async =>
      LocationPermissionStatus.granted;

  @override
  Future<LatLng> getCurrentPosition() async => const LatLng(41.0, 45.0);
}

class _DeniedDelegate implements LocationServiceDelegate {
  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<LocationPermissionStatus> checkPermission() async =>
      LocationPermissionStatus.denied;

  @override
  Future<LocationPermissionStatus> requestPermission() async =>
      LocationPermissionStatus.denied;

  @override
  Future<LatLng> getCurrentPosition() async =>
      throw Exception('should not be called');
}

class _DeniedForeverDelegate implements LocationServiceDelegate {
  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<LocationPermissionStatus> checkPermission() async =>
      LocationPermissionStatus.deniedForever;

  @override
  Future<LocationPermissionStatus> requestPermission() async =>
      LocationPermissionStatus.deniedForever;

  @override
  Future<LatLng> getCurrentPosition() async =>
      throw Exception('should not be called');
}

class _DisabledDelegate implements LocationServiceDelegate {
  @override
  Future<bool> isLocationServiceEnabled() async => false;

  @override
  Future<LocationPermissionStatus> checkPermission() async =>
      LocationPermissionStatus.denied;

  @override
  Future<LocationPermissionStatus> requestPermission() async =>
      LocationPermissionStatus.denied;

  @override
  Future<LatLng> getCurrentPosition() async =>
      throw Exception('should not be called');
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  test('granted → returns device location, status=granted', () async {
    final service = LocationService(delegate: _GrantedDelegate());
    final result = await service.resolve();

    expect(result.status, LocationResultStatus.granted);
    expect(result.lat, closeTo(41.0, 0.0001));
    expect(result.lng, closeTo(45.0, 0.0001));
  });

  test('denied → returns Yerevan fallback (40.1872, 44.5152), status=denied',
      () async {
    final service = LocationService(delegate: _DeniedDelegate());
    final result = await service.resolve();

    expect(result.status, LocationResultStatus.denied);
    expect(result.lat, closeTo(40.1872, 0.0001));
    expect(result.lng, closeTo(44.5152, 0.0001));
  });

  test('deniedForever → returns Yerevan fallback, status=deniedForever',
      () async {
    final service = LocationService(delegate: _DeniedForeverDelegate());
    final result = await service.resolve();

    expect(result.status, LocationResultStatus.deniedForever);
    expect(result.lat, closeTo(40.1872, 0.0001));
    expect(result.lng, closeTo(44.5152, 0.0001));
  });

  test('location service disabled → returns Yerevan fallback, status=denied',
      () async {
    final service = LocationService(delegate: _DisabledDelegate());
    final result = await service.resolve();

    // When the service is off we treat it like denied (not deniedForever)
    // so the user can toggle location on and retry.
    expect(result.status, LocationResultStatus.denied);
    expect(result.lat, closeTo(40.1872, 0.0001));
    expect(result.lng, closeTo(44.5152, 0.0001));
  });

  _timeoutTests();
}

// ---------------------------------------------------------------------------
// Timeout guards
//
// These cover the failure that looked worst in practice: a permission prompt or
// a GPS fix that never arrives. resolve() used to await it forever, so the
// screen never opened — no spinner, no message, indistinguishable from a crash.
// ---------------------------------------------------------------------------

/// Never answers the permission prompt, like a browser tab whose dialog the
/// user ignores.
class _HangingPermissionDelegate implements LocationServiceDelegate {
  @override
  Future<bool> isLocationServiceEnabled() async => true;
  @override
  Future<LocationPermissionStatus> checkPermission() async =>
      LocationPermissionStatus.denied;
  @override
  Future<LocationPermissionStatus> requestPermission() =>
      Completer<LocationPermissionStatus>().future; // never completes
  @override
  Future<LatLng> getCurrentPosition() async => const LatLng(1, 2);
}

/// Grants permission but never produces a fix.
class _HangingPositionDelegate implements LocationServiceDelegate {
  @override
  Future<bool> isLocationServiceEnabled() async => true;
  @override
  Future<LocationPermissionStatus> checkPermission() async =>
      LocationPermissionStatus.granted;
  @override
  Future<LocationPermissionStatus> requestPermission() async =>
      LocationPermissionStatus.granted;
  @override
  Future<LatLng> getCurrentPosition() => Completer<LatLng>().future;
}

void _timeoutTests() {
  test('unanswered permission prompt → Yerevan fallback instead of hanging',
      () async {
    final service = LocationService(
      delegate: _HangingPermissionDelegate(),
      permissionTimeout: const Duration(milliseconds: 40),
    );

    final result = await service.resolve();

    expect(result.status, LocationResultStatus.denied);
    expect(result.lat, closeTo(40.1872, 0.0001));
    expect(result.lng, closeTo(44.5152, 0.0001));
  });

  test('GPS fix that never arrives → Yerevan fallback instead of hanging',
      () async {
    final service = LocationService(
      delegate: _HangingPositionDelegate(),
      positionTimeout: const Duration(milliseconds: 40),
    );

    final result = await service.resolve();

    expect(result.lat, closeTo(40.1872, 0.0001));
    expect(result.lng, closeTo(44.5152, 0.0001));
  });
}
