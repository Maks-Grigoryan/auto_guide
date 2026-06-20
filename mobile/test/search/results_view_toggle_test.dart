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
              onMapSelected: () { mapCalled = true; },
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
              onMapSelected: () { mapCalled = true; },
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

      // The SizedBox(height: 48) wrapping the SegmentedButton renders
      // a widget of height exactly 48.
      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(SegmentedButton<int>),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(sizedBox.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets(
        'when mapAvailable=false, the SegmentedButton has null onSelectionChanged',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResultsViewToggle(
              selectedIndex: 0,
              mapAvailable: false,
              onListSelected: () {},
              onMapSelected: () {},
            ),
          ),
        ),
      );

      final btn = tester.widget<SegmentedButton<int>>(
        find.byType(SegmentedButton<int>),
      );
      expect(btn.onSelectionChanged, isNull);
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
