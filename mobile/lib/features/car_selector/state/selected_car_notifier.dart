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
  int? year;
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Must outlive any single screen.
///
/// As an autoDispose provider this was torn down whenever no widget happened to
/// be watching it between selector steps, taking the in-progress draft with it.
/// pickModel then rebuilt an empty draft via `??=`, so the model and generation
/// were recorded while the make was silently lost — and confirm() blew up on
/// `makeId!`, leaving the button looking dead.
@Riverpod(keepAlive: true)
class SelectedCarNotifier extends _$SelectedCarNotifier {
  static const _boxName = 'selectedCar';
  static const _key = 'current';

  _InProgress? _inProgress;

  int? get draftMakeId => _inProgress?.makeId;
  String? get draftMakeName => _inProgress?.makeName;
  int? get draftModelId => _inProgress?.modelId;
  String? get draftModelName => _inProgress?.modelName;
  int? get draftGenerationId => _inProgress?.generationId;
  String? get draftGenerationLabel => _inProgress?.generationLabel;
  int? get draftYear => _inProgress?.year;

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
  ///
  /// The confirmed car is deliberately left alone. Clearing it here made the
  /// home screen's car chip vanish the moment a make was tapped: if the wizard
  /// was then abandoned nothing was confirmed, so the chip never came back —
  /// while the router, which reads Hive rather than this state, still saw a car
  /// and would not send the person back to the selector either. An edit that is
  /// never finished must change nothing.
  void pickMake(int id, String name) {
    _inProgress = _InProgress()
      ..makeId = id
      ..makeName = name;
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

  /// Sets the year of manufacture, or clears it when [year] is null.
  ///
  /// Independent of the generation: picking one does not change the other, and
  /// skipping the year is a choice the flow has to carry rather than a gap to
  /// fill in later.
  void pickYear(int? year) {
    _inProgress ??= _InProgress();
    _inProgress!.year = year;
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
      year: p.year,
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
