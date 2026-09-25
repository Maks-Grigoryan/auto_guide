/// Platform-neutral entry point for the results map.
///
/// Both implementations expose the identical surface —
/// `ResultsMapView({required List<VendorResult> vendors})` — so
/// PartsResultsPage and RepairResultsPage import this file and stay unchanged:
///
///   * mobile → native Yandex MapKit (results_map_view_mobile.dart)
///   * web    → Yandex Maps JS API 3.0 (results_map_view_web.dart)
///
/// `showVendorSheet` is re-exported for callers that already import it from
/// here; it is defined once in vendor_summary_sheet.dart.
library;

export 'vendor_summary_sheet.dart' show showVendorSheet;

export 'results_map_view_stub.dart'
    if (dart.library.io) 'results_map_view_mobile.dart'
    if (dart.library.js_interop) 'results_map_view_web.dart';
