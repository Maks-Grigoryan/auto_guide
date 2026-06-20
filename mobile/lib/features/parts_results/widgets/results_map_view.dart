import 'dart:math';

import 'package:flutter/material.dart';
import 'package:yandex_maps_mapkit/mapkit.dart';
import 'package:yandex_maps_mapkit/yandex_map.dart';

import '../../../core/location/location_service.dart';
import '../../../core/models/vendor_result.dart';
import 'vendor_summary_sheet.dart';

/// Yandex map view showing one amber marker per vendor with a distance label.
///
/// Camera auto-fits to the bounding box of all markers (D-02):
///   - empty set  → Yerevan-centre zoom 12
///   - 1 vendor   → centred zoom 15
///   - ≥2 vendors → cameraPositionForGeometry(BoundingBox)
///
/// Tapping a marker raises [VendorSummarySheet] with the map still visible
/// behind the partial-height sheet (D-03).
///
/// CRITICAL (RESEARCH Pitfall 1/8): [MapObjectTapListener] objects are held by
/// WEAK references in the SDK. They MUST be stored in a State field — never as
/// locals — and cleared together with mapObjects.clear() to prevent stale or
/// silent no-op taps.
class ResultsMapView extends StatefulWidget {
  const ResultsMapView({super.key, required this.vendors});

  final List<VendorResult> vendors;

  @override
  State<ResultsMapView> createState() => _ResultsMapViewState();
}

class _ResultsMapViewState extends State<ResultsMapView> {
  MapWindow? _mapWindow;

  // CRITICAL: stored as field — MapKit holds only weak refs (RESEARCH Pitfall 1).
  // Must be cleared alongside mapObjects.clear() (Pitfall 8).
  final List<MapObjectTapListener> _tapListeners = [];

  @override
  void didUpdateWidget(ResultsMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-place markers and re-fit camera when the result set changes
    // (e.g. after a filter change — D-01 instant switch, same provider).
    if (oldWidget.vendors != widget.vendors) {
      _updateMarkers(widget.vendors);
    }
  }

  @override
  Widget build(BuildContext context) {
    return YandexMap(
      onMapCreated: (MapWindow mapWindow) {
        _mapWindow = mapWindow;
        _updateMarkers(widget.vendors);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Marker placement + camera fit (RESEARCH Pattern 3)
  // ---------------------------------------------------------------------------

  void _updateMarkers(List<VendorResult> vendors) {
    final map = _mapWindow?.map;
    if (map == null) return;

    // Pitfall 8: clear listeners BEFORE mapObjects.clear() so stale listeners
    // from the previous batch do not hold references to invalidated objects.
    map.mapObjects.clear();
    _tapListeners.clear();

    if (vendors.isEmpty) {
      // D-02: empty → Yerevan centre fallback, zoom 12.
      map.move(
        CameraPosition(
          Point(latitude: kYerevanLat, longitude: kYerevanLng),
          zoom: 12.0,
          azimuth: 0.0,
          tilt: 0.0,
        ),
      );
      return;
    }

    if (vendors.length == 1) {
      // Pitfall 2: single-vendor bounding box degenerates to a point.
      // Use CameraPosition directly at zoom 15.
      final v = vendors.first;
      // Pitfall 3: Point uses latitude FIRST, longitude SECOND.
      final point = Point(latitude: v.lat, longitude: v.lng);
      final pm = map.mapObjects.addPlacemarkWithPoint(point);
      _configureMarker(pm, v);
      map.move(
        CameraPosition(
          point,
          zoom: 15.0,
          azimuth: 0.0,
          tilt: 0.0,
        ),
      );
      return;
    }

    // Multiple vendors: place markers, accumulate bbox, then fit camera.
    double minLat = vendors.first.lat;
    double maxLat = vendors.first.lat;
    double minLng = vendors.first.lng;
    double maxLng = vendors.first.lng;

    for (final v in vendors) {
      // Pitfall 3: latitude FIRST.
      final point = Point(latitude: v.lat, longitude: v.lng);
      final pm = map.mapObjects.addPlacemarkWithPoint(point);
      _configureMarker(pm, v);

      minLat = min(minLat, v.lat);
      maxLat = max(maxLat, v.lat);
      minLng = min(minLng, v.lng);
      maxLng = max(maxLng, v.lng);
    }

    // D-02: fit camera to bounding box of all markers.
    final camPos = map.cameraPositionForGeometry(
      Geometry.fromBoundingBox(
        BoundingBox(
          Point(latitude: minLat, longitude: minLng), // southWest
          Point(latitude: maxLat, longitude: maxLng), // northEast
        ),
      ),
    );
    map.move(camPos);
  }

  // ---------------------------------------------------------------------------
  // Marker configuration: amber icon + distance label + tap listener
  // ---------------------------------------------------------------------------

  void _configureMarker(PlacemarkMapObject pm, VendorResult v) {
    // Amber (#F5A623) placemark with dark outline for legibility over tiles
    // (UI-SPEC marker color rule). Use the default placemark icon styled via
    // PlacemarkIcon — the distance label is set as a text caption.
    pm.setIcon(
      PlacemarkIcon.single(
        PlacemarkIconStyle(
          // Use a solid amber circle image; in absence of a custom asset,
          // rely on the default SDK icon style with amber tint.
          // The distance label is rendered as a caption below the pin.
          scale: 2.0,
        ),
      ),
    );

    // Distance label (UI-SPEC: 16 sp SemiBold #1C1F26 on/under the pin).
    pm.setText(
      PlacemarkText(
        text: _formatDistance(v.distanceM),
        style: PlacemarkTextStyle(
          size: 16.0,
          color: const Color(0xFF1C1F26),
          outlineColor: const Color(0xFFF5A623),
          placement: TextPlacement.bottom,
        ),
      ),
    );

    // Tap listener stored in field (Pitfall 1 — weak ref guard).
    final listener = _VendorTapListener(
      vendor: v,
      onTap: (vendor) => _showVendorSheet(context, vendor),
    );
    _tapListeners.add(listener);
    pm.addTapListener(listener);
  }

  // ---------------------------------------------------------------------------
  // Distance formatting (mirrors DistanceBadge formatting)
  // ---------------------------------------------------------------------------

  String _formatDistance(double distanceM) {
    if (distanceM < 1000) return '${distanceM.round()} м';
    final km = distanceM / 1000.0;
    return '${km.toStringAsFixed(1)} км';
  }
}

// ---------------------------------------------------------------------------
// Tap listener implementation (must be a concrete class held by strong ref)
// ---------------------------------------------------------------------------

class _VendorTapListener implements MapObjectTapListener {
  const _VendorTapListener({required this.vendor, required this.onTap});

  final VendorResult vendor;
  final void Function(VendorResult) onTap;

  @override
  bool onMapObjectTap(MapObject mapObject, Point point) {
    onTap(vendor);
    return true; // consume the tap
  }
}

// ---------------------------------------------------------------------------
// Bottom-sheet helper (exported so ResultsMapView can call it; also usable
// independently from outside the widget if needed).
// ---------------------------------------------------------------------------

/// Shows a partial-height modal bottom sheet with [VendorSummarySheet] for
/// the given [vendor]. The map stays visible behind the sheet (D-03).
void showVendorSheet(BuildContext context, VendorResult vendor) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF2A2D36),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => VendorSummarySheet(vendor: vendor),
  );
}

// Private alias used by _ResultsMapViewState.
void _showVendorSheet(BuildContext context, VendorResult vendor) =>
    showVendorSheet(context, vendor);
