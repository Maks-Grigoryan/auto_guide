import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../../../core/models/vendor_result.dart';
import '../../../l10n/l10n.dart';
import 'vendor_summary_sheet.dart';

// ---------------------------------------------------------------------------
// Bridge to web/yandex_map.js
// ---------------------------------------------------------------------------

// The container ELEMENT is passed across, not an id: Flutter mounts platform
// views inside <flt-platform-view>, where document.getElementById cannot reach
// them, so the id-based lookup silently failed and no map was ever created.
@JS('avtoMap.render')
external void _render(
  web.HTMLDivElement container,
  JSString vendorsJson,
  JSFunction onTap,
);

@JS('avtoMap.dispose')
external void _dispose(web.HTMLDivElement container);

/// Yandex Maps JS API 2.1 view showing one amber marker per vendor with a
/// distance label — the web counterpart of the native MapKit view.
///
/// Behaviour is kept identical to results_map_view_mobile.dart:
///   - camera auto-fits the result set (D-02): empty → Yerevan zoom 12,
///     one vendor → zoom 15, two or more → bounding box;
///   - tapping a marker raises [showVendorSheet] with the map still visible
///     behind the partial-height sheet (D-03);
///   - [didUpdateWidget] re-renders when the result set changes, so switching
///     sort or filters updates markers without a re-fetch (D-01).
///
/// This widget is only ever built when `mapAvailableProvider` is true, i.e.
/// after avtoMap.init resolved true — so ymaps is guaranteed loaded here.
class ResultsMapView extends StatefulWidget {
  const ResultsMapView({super.key, required this.vendors});

  final List<VendorResult> vendors;

  @override
  State<ResultsMapView> createState() => _ResultsMapViewState();
}

class _ResultsMapViewState extends State<ResultsMapView> {
  /// Distinguishes concurrently mounted maps (parts and repair pages can each
  /// hold one) so their containers and JS-side map instances never collide.
  static int _instanceCounter = 0;

  late final String _viewType = 'avto-yandex-map-${_instanceCounter++}';

  /// The div the platform view created. Held because it — not an id — is the
  /// handle handed to the JS bridge.
  web.HTMLDivElement? _container;

  @override
  void initState() {
    super.initState();
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int _) {
      final div = web.document.createElement('div') as web.HTMLDivElement;
      div.id = _viewType; // diagnostics only; JS receives the element itself
      div.style.width = '100%';
      div.style.height = '100%';
      _container = div;
      return div;
    });
  }

  @override
  void didUpdateWidget(ResultsMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-place markers and re-fit camera when the result set changes
    // (e.g. after a filter change — D-01 instant switch, same provider).
    if (oldWidget.vendors != widget.vendors) {
      _renderVendors();
    }
  }

  @override
  void dispose() {
    final container = _container;
    if (container != null) {
      _dispose(container);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      viewType: _viewType,
      onPlatformViewCreated: (_) => _renderVendors(),
    );
  }

  // -------------------------------------------------------------------------
  // Marker placement + camera fit — delegated to avtoMap.render
  // -------------------------------------------------------------------------

  void _renderVendors() {
    final container = _container;
    if (container == null || !mounted) return;

    // Coordinate order is owned by the JS side; this payload names its fields
    // explicitly so neither end can silently swap them.
    final payload = jsonEncode([
      for (final vendor in widget.vendors)
        {
          'lat': vendor.lat,
          'lng': vendor.lng,
          'label': _formatDistance(context, vendor.distanceM),
        },
    ]);

    _render(
      container,
      payload.toJS,
      ((JSNumber jsIndex) {
        final index = jsIndex.toDartInt;
        if (!mounted || index < 0 || index >= widget.vendors.length) return;
        showVendorSheet(context, widget.vendors[index]);
      }).toJS,
    );
  }

  // -------------------------------------------------------------------------
  // Distance formatting (mirrors DistanceBadge and the mobile map view)
  // -------------------------------------------------------------------------

  String _formatDistance(BuildContext context, double distanceM) {
    if (distanceM < 1000) {
      return context.l10n.distanceMeters(distanceM.round());
    }
    final km = distanceM / 1000.0;
    return context.l10n.distanceKilometers(km.toStringAsFixed(1));
  }
}
