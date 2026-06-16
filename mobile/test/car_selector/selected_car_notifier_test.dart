import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';

import 'package:avto_app/features/car_selector/domain/selected_car.dart';
import 'package:avto_app/features/car_selector/state/selected_car_notifier.dart';

// ---------------------------------------------------------------------------
// Test-only helper: build a SelectedCarNotifier in isolation (no ProviderScope).
// ---------------------------------------------------------------------------

/// A thin wrapper that lets tests call notifier methods and read state without
/// going through Riverpod's full provider graph.
class _NotifierUnderTest {
  _NotifierUnderTest() : _notifier = SelectedCarNotifier();

  final SelectedCarNotifier _notifier;

  SelectedCar? get state => _notifier.testableState;

  void pickMake(int id, String name) => _notifier.pickMake(id, name);
  void pickModel(int id, String name) => _notifier.pickModel(id, name);
  void pickGeneration(int id, String label) =>
      _notifier.pickGeneration(id, label);
  void confirm() => _notifier.confirm();
  void reload() => _notifier.reloadFromBox();
}

// ---------------------------------------------------------------------------
// Test suite
// ---------------------------------------------------------------------------

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);
    await Hive.openBox('selectedCar');
  });

  tearDown(() async {
    final box = Hive.box('selectedCar');
    await box.clear();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  // ── Test 1 ────────────────────────────────────────────────────────────────
  test(
    'pickMake clears model and generation after a full selection',
    () {
      final n = _NotifierUnderTest();

      // Set up a complete selection
      n.pickMake(1, 'Toyota');
      n.pickModel(3, 'Camry');
      n.pickGeneration(7, 'VI');
      n.confirm();
      expect(n.state, isNotNull);

      // Pick a new make — model and generation must be cleared
      n.pickMake(2, 'BMW');

      // After picking a new make, confirmed state resets to null until confirm()
      expect(n.state, isNull);

      // _inProgress should only have make fields set
      // Verify by picking model then confirming without generation — should work
      n.pickModel(5, 'X5');
      n.confirm();

      expect(n.state!.makeId, equals(2));
      expect(n.state!.makeName, equals('BMW'));
      expect(n.state!.modelId, equals(5));
      expect(n.state!.modelName, equals('X5'));
      expect(n.state!.generationId, isNull);
      expect(n.state!.generationLabel, isNull);
    },
  );

  // ── Test 2 ────────────────────────────────────────────────────────────────
  test(
    'pickModel clears generation but keeps make',
    () {
      final n = _NotifierUnderTest();

      n.pickMake(1, 'Toyota');
      n.pickModel(3, 'Camry');
      n.pickGeneration(7, 'VI');
      n.confirm();

      // Now pick a new model — generation should clear, make should remain
      n.pickModel(4, 'Corolla');
      n.confirm(); // confirm without picking generation

      expect(n.state!.makeId, equals(1));
      expect(n.state!.makeName, equals('Toyota'));
      expect(n.state!.modelId, equals(4));
      expect(n.state!.modelName, equals('Corolla'));
      expect(n.state!.generationId, isNull);
      expect(n.state!.generationLabel, isNull);
    },
  );

  // ── Test 3 ────────────────────────────────────────────────────────────────
  test(
    'pickGeneration sets generation without touching make or model',
    () {
      final n = _NotifierUnderTest();

      n.pickMake(1, 'Toyota');
      n.pickModel(3, 'Camry');
      n.pickGeneration(9, 'VII');
      n.confirm();

      expect(n.state!.makeId, equals(1));
      expect(n.state!.modelId, equals(3));
      expect(n.state!.generationId, equals(9));
      expect(n.state!.generationLabel, equals('VII'));
    },
  );

  // ── Test 4 ────────────────────────────────────────────────────────────────
  test(
    'confirm with no generation produces SelectedCar with generationId == null (SEL-03)',
    () {
      final n = _NotifierUnderTest();

      n.pickMake(1, 'Toyota');
      n.pickModel(3, 'Camry');
      // deliberately skip pickGeneration
      n.confirm();

      expect(n.state, isNotNull);
      expect(n.state!.makeId, equals(1));
      expect(n.state!.modelId, equals(3));
      expect(n.state!.generationId, isNull,
          reason: 'generationId must be nullable when generation is skipped');
      expect(n.state!.generationLabel, isNull);
    },
  );

  // ── Test 5 ────────────────────────────────────────────────────────────────
  test(
    'confirm() writes to Hive box and a fresh notifier re-reads the same SelectedCar (SEL-04)',
    () {
      final n = _NotifierUnderTest();

      n.pickMake(1, 'Toyota');
      n.pickModel(3, 'Camry');
      n.pickGeneration(9, 'VII');
      n.confirm();

      // Simulate app restart: build a fresh notifier that reads from the same box
      final n2 = _NotifierUnderTest();
      n2.reload(); // reads Hive box 'selectedCar' key 'current'

      expect(n2.state, isNotNull,
          reason: 'SelectedCar should be re-read from Hive after restart');
      expect(n2.state!.makeId, equals(1));
      expect(n2.state!.makeName, equals('Toyota'));
      expect(n2.state!.modelId, equals(3));
      expect(n2.state!.modelName, equals('Camry'));
      expect(n2.state!.generationId, equals(9));
      expect(n2.state!.generationLabel, equals('VII'));
    },
  );

  // ── Test 6 ────────────────────────────────────────────────────────────────
  test(
    'SelectedCar.toMap()/fromMap() round-trips all 6 fields including nullable generation',
    () {
      // With generation
      const car = SelectedCar(
        makeId: 1,
        makeName: 'Toyota',
        modelId: 3,
        modelName: 'Camry',
        generationId: 9,
        generationLabel: 'VII',
      );
      final map = car.toMap();
      final restored = SelectedCar.fromMap(map);

      expect(restored.makeId, equals(car.makeId));
      expect(restored.makeName, equals(car.makeName));
      expect(restored.modelId, equals(car.modelId));
      expect(restored.modelName, equals(car.modelName));
      expect(restored.generationId, equals(car.generationId));
      expect(restored.generationLabel, equals(car.generationLabel));

      // Without generation (nullable fields)
      const carNoGen = SelectedCar(
        makeId: 2,
        makeName: 'BMW',
        modelId: 5,
        modelName: 'X5',
      );
      final mapNoGen = carNoGen.toMap();
      final restoredNoGen = SelectedCar.fromMap(mapNoGen);

      expect(restoredNoGen.generationId, isNull);
      expect(restoredNoGen.generationLabel, isNull);
    },
  );
}
