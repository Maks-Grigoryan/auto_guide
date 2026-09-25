import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:avto_app/features/parts_results/widgets/results_view_toggle.dart';
import 'package:avto_app/features/parts_results/widgets/map_unavailable_notice.dart';

void main() {
  // ---------------------------------------------------------------------------
  // ResultsViewToggle
  // ---------------------------------------------------------------------------

  group('ResultsViewToggle', () {
    testWidgets('renders both «Список» and «Карта» segments', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResultsViewToggle(
              selectedIndex: 0,
              mapAvailable: true,
              onListSelected: () {},
              onMapSelected: () {},
            ),
          ),
        ),
      );
      expect(find.text('Список'), findsOneWidget);
      expect(find.text('Карта'), findsOneWidget);
    });

    testWidgets('tapping «Карта» calls onMapSelected when mapAvailable=true',
        (tester) async {
      bool mapCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResultsViewToggle(
              selectedIndex: 0,
              mapAvailable: true,
              onListSelected: () {},
              onMapSelected: () {
                mapCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Карта'));
      await tester.pump();

      expect(mapCalled, isTrue);
    });

    testWidgets(
        'when mapAvailable=false, tapping «Карта» does NOT call onMapSelected',
        (tester) async {
      bool mapCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResultsViewToggle(
              selectedIndex: 0,
              mapAvailable: false,
              onListSelected: () {},
              onMapSelected: () {
                mapCalled = true;
              },
            ),
          ),
        ),
      );

      // Try tapping the disabled segment — should be a no-op.
      await tester.tap(find.text('Карта'), warnIfMissed: false);
      await tester.pump();

      expect(mapCalled, isFalse);
    });

    testWidgets('toggle height is at least 48 dp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResultsViewToggle(
              selectedIndex: 0,
              mapAvailable: true,
              onListSelected: () {},
              onMapSelected: () {},
            ),
          ),
        ),
      );

      // Measured, not read off a SizedBox: what matters is the tap target the
      // person actually gets, whichever widget happens to produce it.
      final size = tester.getSize(find.byType(ResultsViewToggle));
      expect(size.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('with no map, neither segment does anything', (tester) async {
      var listCalled = false;
      var mapCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResultsViewToggle(
              selectedIndex: 0,
              mapAvailable: false,
              onListSelected: () => listCalled = true,
              onMapSelected: () => mapCalled = true,
            ),
          ),
        ),
      );

      // D-04 says the whole control goes inert, not just «Карта». Stated as
      // behaviour rather than «the button's callback is null», it keeps holding
      // now that the control is no longer built from SegmentedButton.
      await tester.tap(find.text('Карта'), warnIfMissed: false);
      await tester.tap(find.text('Список'), warnIfMissed: false);
      await tester.pump();

      expect(mapCalled, isFalse);
      expect(listCalled, isFalse);
    });

    testWidgets('the chosen segment is marked without relying on colour',
        (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResultsViewToggle(
              selectedIndex: 1,
              mapAvailable: true,
              onListSelected: () {},
              onMapSelected: () {},
            ),
          ),
        ),
      );

      // A check mark and a semantics flag, so the selection survives both a
      // greyscale screen and a screen reader (ACC-02).
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Only the flags this test is about: matchesSemantics would demand every
      // other flag and action be listed too, which turns an accessibility
      // check into a transcript of Flutter's internals.
      // isSelected is three-valued — «not selected» and «selection does not
      // apply here» are different things — so it is compared by name rather
      // than truth-tested. Its type is not exported from flutter/semantics.dart,
      // and naming it would mean importing dart:ui into a widget test.
      final flags = tester.getSemantics(find.text('Карта')).flagsCollection;
      expect(flags.isSelected.name, 'isTrue');
      expect(flags.isButton, isTrue);

      handle.dispose();
    });
  });

  // ---------------------------------------------------------------------------
  // MapUnavailableNotice
  // ---------------------------------------------------------------------------

  group('MapUnavailableNotice', () {
    testWidgets('renders «Карта недоступна» text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MapUnavailableNotice(),
          ),
        ),
      );
      expect(find.text('Карта недоступна'), findsOneWidget);
    });

    testWidgets('renders Icons.map_outlined icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MapUnavailableNotice(),
          ),
        ),
      );
      expect(find.byIcon(Icons.map_outlined), findsOneWidget);
    });

    testWidgets('notice strip is at least 48 dp tall', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MapUnavailableNotice(),
          ),
        ),
      );

      final box = tester.getSize(find.byType(MapUnavailableNotice));
      expect(box.height, greaterThanOrEqualTo(48.0));
    });
  });
}
