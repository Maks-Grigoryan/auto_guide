import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:avto_app/features/car_selector/data/catalog_providers.dart';
import 'package:avto_app/features/car_selector/ui/make_list_page.dart';

// ---------------------------------------------------------------------------
// Stub makes data: mix of Latin and Cyrillic brands (SEL-01, SEL-04).
// ---------------------------------------------------------------------------
const _stubMakes = [
  // PostgreSQL bigint IDs arrive as strings through the Node `pg` driver.
  {'id': '1', 'name': 'Toyota'},
  {'id': '2', 'name': 'Tesla'},
  {'id': '3', 'name': 'Lada'},
  {'id': '4', 'name': 'BMW'},
];

/// Builds MakeListPage under a ProviderScope that overrides [makesProvider]
/// with an in-memory [_stubMakes] list — no network call.
Widget _buildTestApp() {
  return ProviderScope(
    overrides: [
      makesProvider.overrideWith(
        (ref) async => List<Map<String, dynamic>>.from(_stubMakes),
      ),
    ],
    child: const MaterialApp(
      home: MakeListPage(),
    ),
  );
}

void main() {
  // ── Test 1 ────────────────────────────────────────────────────────────────
  testWidgets(
    'typing "to" leaves only "Toyota" visible (instant client-side filter)',
    (tester) async {
      await tester.pumpWidget(_buildTestApp());
      // Wait for the async provider to resolve.
      await tester.pumpAndSettle();

      // All four makes should be visible initially.
      expect(find.text('Toyota'), findsOneWidget);
      expect(find.text('Tesla'), findsOneWidget);
      expect(find.text('Lada'), findsOneWidget);
      expect(find.text('BMW'), findsOneWidget);

      // Type "to" into the search field.
      await tester.enterText(find.byType(TextField), 'to');
      await tester.pump();

      // Only "Toyota" should match (contains "to", case-insensitive).
      expect(find.text('Toyota'), findsOneWidget);
      expect(find.text('Tesla'), findsNothing);
      expect(find.text('Lada'), findsNothing);
      expect(find.text('BMW'), findsNothing);
    },
  );

  // ── Test 2 ────────────────────────────────────────────────────────────────
  testWidgets(
    'filter is case-insensitive: typing "TOYOTA" still matches "Toyota"',
    (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'TOYOTA');
      await tester.pump();

      expect(find.text('Toyota'), findsOneWidget);
      expect(find.text('Tesla'), findsNothing);
      expect(find.text('Lada'), findsNothing);
      expect(find.text('BMW'), findsNothing);
    },
  );

  // ── Test 3 ────────────────────────────────────────────────────────────────
  testWidgets(
    'typing nonsense shows empty-search copy "Марка не найдена. Проверьте написание."',
    (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'xyzqwerty');
      await tester.pump();

      expect(
        find.text('Марка не найдена. Проверьте написание.'),
        findsOneWidget,
      );
      // No make tiles should be visible.
      expect(find.text('Toyota'), findsNothing);
      expect(find.text('Tesla'), findsNothing);
      expect(find.text('Lada'), findsNothing);
      expect(find.text('BMW'), findsNothing);
    },
  );
}
