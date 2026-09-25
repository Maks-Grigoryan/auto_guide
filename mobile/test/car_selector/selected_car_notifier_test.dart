import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';

import 'package:avto_app/features/car_selector/domain/selected_car.dart';
import 'package:avto_app/features/car_selector/state/selected_car_notifier.dart';

// ---------------------------------------------------------------------------
// These tests drive the real Riverpod provider through a ProviderContainer.
// In Riverpod 3 a Notifier cannot be constructed directly — it must be reached
// via `container.read(selectedCarProvider.notifier)` so its lifecycle (build,
// ref, state) is initialised by the framework.
// ---------------------------------------------------------------------------

void main() {
  late Directory tempDir;
  late ProviderContainer container;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);
    await Hive.openBox('selectedCar');
  });

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() async {
    container.dispose();
    final box = Hive.box('selectedCar');
    await box.clear();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  SelectedCarNotifier notifier() =>
      container.read(selectedCarProvider.notifier);
  SelectedCar? state() => container.read(selectedCarProvider);

  // ── Regression ────────────────────────────────────────────────────────────
  test('an abandoned selection leaves the confirmed car untouched', () async {
    final n = notifier();

    n.pickMake(1, 'Toyota');
    n.pickModel(3, 'Camry');
    n.confirm();

    // Walk into the wizard again and leave without confirming — which is what
    // happens every time someone taps the car chip, changes their mind, and
    // presses back. The reported symptom was the chip disappearing here and
    // never returning.
    n.pickMake(2, 'BMW');
    n.pickModel(5, 'X5');

    expect(state()!.makeName, 'Toyota');
    expect(state()!.modelName, 'Camry');

    // And the two sources of truth must still agree. They did not before: the
    // provider went null while Hive kept the car, so the screen showed no chip
    // while the router saw a car and refused to reopen the selector.
    final stored = Hive.box('selectedCar').get('current') as Map;
    expect(stored['makeName'], 'Toyota');
    expect(stored['makeName'], state()!.makeName);
  });

  // ── Test 1 ────────────────────────────────────────────────────────────────
  test('pickMake starts a fresh draft and keeps the confirmed car', () {
    final n = notifier();

    n.pickMake(1, 'Toyota');
    n.pickModel(3, 'Camry');
    n.pickGeneration(7, 'VI');
    n.confirm();
    expect(state(), isNotNull);

    // Starting a new selection must not disturb the confirmed one. This used
    // to null it, which made the home screen's car chip disappear the moment a
    // make was tapped — and stay gone if the wizard was then abandoned.
    n.pickMake(2, 'BMW');
    expect(state()!.makeName, 'Toyota');
    expect(state()!.modelName, 'Camry');

    // …while the draft has moved on, with model and generation cascade-reset.
    expect(n.draftMakeId, 2);
    expect(n.draftMakeName, 'BMW');
    expect(n.draftModelId, isNull);
    expect(n.draftGenerationId, isNull);

    // _inProgress should only have make fields — confirm without generation works
    n.pickModel(5, 'X5');
    expect(n.draftModelId, 5);
    expect(n.draftModelName, 'X5');
    n.confirm();

    final s = state()!;
    expect(s.makeId, equals(2));
    expect(s.makeName, equals('BMW'));
    expect(s.modelId, equals(5));
    expect(s.modelName, equals('X5'));
    expect(s.generationId, isNull);
    expect(s.generationLabel, isNull);
  });

  // ── Test 2 ────────────────────────────────────────────────────────────────
  test('pickModel clears generation but keeps make', () {
    final n = notifier();

    n.pickMake(1, 'Toyota');
    n.pickModel(3, 'Camry');
    n.pickGeneration(7, 'VI');
    n.confirm();

    // Pick a new model — generation clears, make remains
    n.pickModel(4, 'Corolla');
    n.confirm();

    final s = state()!;
    expect(s.makeId, equals(1));
    expect(s.makeName, equals('Toyota'));
    expect(s.modelId, equals(4));
    expect(s.modelName, equals('Corolla'));
    expect(s.generationId, isNull);
    expect(s.generationLabel, isNull);
  });

  // ── Test 3 ────────────────────────────────────────────────────────────────
  test('pickGeneration sets generation without touching make or model', () {
    final n = notifier();

    n.pickMake(1, 'Toyota');
    n.pickModel(3, 'Camry');
    n.pickGeneration(9, 'VII');
    n.confirm();

    final s = state()!;
    expect(s.makeId, equals(1));
    expect(s.modelId, equals(3));
    expect(s.generationId, equals(9));
    expect(s.generationLabel, equals('VII'));
  });

  // ── Test 4 ────────────────────────────────────────────────────────────────
  test(
      'confirm with no generation produces SelectedCar with generationId == null (SEL-03)',
      () {
    final n = notifier();

    n.pickMake(1, 'Toyota');
    n.pickModel(3, 'Camry');
    // deliberately skip pickGeneration
    n.confirm();

    final s = state()!;
    expect(s.makeId, equals(1));
    expect(s.modelId, equals(3));
    expect(s.generationId, isNull,
        reason: 'generationId must be nullable when generation is skipped');
    expect(s.generationLabel, isNull);
  });

  // ── Test 5 ────────────────────────────────────────────────────────────────
  test(
      'confirm() writes to Hive box and a fresh notifier re-reads the same SelectedCar (SEL-04)',
      () {
    final n = notifier();

    n.pickMake(1, 'Toyota');
    n.pickModel(3, 'Camry');
    n.pickGeneration(9, 'VII');
    n.confirm();

    // Simulate app restart: a fresh container rebuilds the notifier, whose
    // build() re-reads the same Hive box.
    final container2 = ProviderContainer();
    addTearDown(container2.dispose);
    final restored = container2.read(selectedCarProvider);

    expect(restored, isNotNull,
        reason: 'SelectedCar should be re-read from Hive after restart');
    expect(restored!.makeId, equals(1));
    expect(restored.makeName, equals('Toyota'));
    expect(restored.modelId, equals(3));
    expect(restored.modelName, equals('Camry'));
    expect(restored.generationId, equals(9));
    expect(restored.generationLabel, equals('VII'));
  });

  // ── Test 6 ────────────────────────────────────────────────────────────────
  test(
      'SelectedCar.toMap()/fromMap() round-trips all 6 fields including nullable generation',
      () {
    const car = SelectedCar(
      makeId: 1,
      makeName: 'Toyota',
      modelId: 3,
      modelName: 'Camry',
      generationId: 9,
      generationLabel: 'VII',
    );
    final restored = SelectedCar.fromMap(car.toMap());

    expect(restored.makeId, equals(car.makeId));
    expect(restored.makeName, equals(car.makeName));
    expect(restored.modelId, equals(car.modelId));
    expect(restored.modelName, equals(car.modelName));
    expect(restored.generationId, equals(car.generationId));
    expect(restored.generationLabel, equals(car.generationLabel));

    const carNoGen = SelectedCar(
      makeId: 2,
      makeName: 'BMW',
      modelId: 5,
      modelName: 'X5',
    );
    final restoredNoGen = SelectedCar.fromMap(carNoGen.toMap());

    expect(restoredNoGen.generationId, isNull);
    expect(restoredNoGen.generationLabel, isNull);
  });
}
