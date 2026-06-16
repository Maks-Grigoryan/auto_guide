import 'package:hive_ce/hive_ce.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/selected_car.dart';

part 'selected_car_notifier.g.dart';

// ---------------------------------------------------------------------------
// In-progress (transient) selection — mutated during the wizard flow.
// Re-initialised on each pickMake call to prevent stale state (Assumption A4).
// ---------------------------------------------------------------------------
class _InProgress {
  int? makeId;
  String? makeName;
  int? modelId;
  String? modelName;
  int? generationId;
  String? generationLabel;
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

@riverpod
class SelectedCarNotifier extends _$SelectedCarNotifier {
  static const _boxName = 'selectedCar';
  static const _key = 'current';

  _InProgress? _inProgress;

  @override
  SelectedCar? build() {
    return _readFromBox();
  }

  SelectedCar? _readFromBox() {
    final box = Hive.box(_boxName);
    final raw = box.get(_key);
    if (raw == null) return null;
    return SelectedCar.fromMap(raw as Map<dynamic, dynamic>);
  }

  /// Picks a make and cascade-resets model + generation (D-03).
  /// Re-initialises _inProgress so stale sub-selections cannot linger.
  void pickMake(int id, String name) {
    _inProgress = _InProgress()
      ..makeId = id
      ..makeName = name;
    // Clear confirmed state while the user is editing (UI reacts immediately).
    state = null;
  }

  /// Picks a model and clears generation (D-03 partial reset).
  void pickModel(int id, String name) {
    _inProgress ??= _InProgress();
    _inProgress!
      ..modelId = id
      ..modelName = name
      ..generationId = null
      ..generationLabel = null;
  }

  /// Picks a generation (no cascade reset needed — leaf node).
  void pickGeneration(int id, String label) {
    _inProgress ??= _InProgress();
    _inProgress!
      ..generationId = id
      ..generationLabel = label;
  }

  /// Builds a [SelectedCar] from the current in-progress selection,
  /// persists it to Hive, and updates [state].
  void confirm() {
    final p = _inProgress!;
    final car = SelectedCar(
      makeId: p.makeId!,
      makeName: p.makeName!,
      modelId: p.modelId!,
      modelName: p.modelName!,
      generationId: p.generationId,
      generationLabel: p.generationLabel,
    );
    Hive.box(_boxName).put(_key, car.toMap());
    state = car;
  }

  // ---------------------------------------------------------------------------
  // Test-only surface — not part of the public API.
  // These members exist so unit tests can drive the notifier without a full
  // ProviderScope / WidgetTester setup.
  // ---------------------------------------------------------------------------

  /// Direct state accessor for tests (Riverpod's [state] getter is protected).
  SelectedCar? get testableState => state;

  /// Re-reads the Hive box, simulating a fresh app launch in tests.
  void reloadFromBox() {
    state = _readFromBox();
  }
}
