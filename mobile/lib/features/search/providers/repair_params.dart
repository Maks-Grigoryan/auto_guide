import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'repair_params.g.dart';

// ---------------------------------------------------------------------------
// RepairQuery — immutable value object passed to search_repair.
// ---------------------------------------------------------------------------
//
// Sequencing note: This file does NOT import ResultSort (introduced by Plan 02)
// and RepairQuery has no sort field. Repair sort/filter UI is added in Plan 04.
// ---------------------------------------------------------------------------

class RepairQuery {
  const RepairQuery({
    required this.lat,
    required this.lng,
    this.radius = 20000,
    this.serviceCategoryId,
  });

  final double lat;
  final double lng;
  final int radius;
  final int? serviceCategoryId;

  RepairQuery copyWith({
    double? lat,
    double? lng,
    int? radius,
    int? serviceCategoryId,
  }) {
    return RepairQuery(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      radius: radius ?? this.radius,
      serviceCategoryId: serviceCategoryId ?? this.serviceCategoryId,
    );
  }

  @override
  String toString() =>
      'RepairQuery(lat: $lat, lng: $lng, radius: $radius, '
      'serviceCategoryId: $serviceCategoryId)';
}

// ---------------------------------------------------------------------------
// RepairParams Notifier — submit-triggered.
//
// Starts empty (no request before submit).
// submit(q) replaces state once, triggering repairSearchProvider.
// ---------------------------------------------------------------------------

@riverpod
class RepairParams extends _$RepairParams {
  @override
  RepairQuery? build() => null; // null = no search submitted yet

  /// Submit a new repair search. Replaces state to trigger dependent providers.
  void submit(RepairQuery query) {
    state = query;
  }

  /// Clear repair search state.
  void clear() {
    state = null;
  }
}
