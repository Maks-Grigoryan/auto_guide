import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:avto_app/core/models/service_category.dart';
import 'package:avto_app/features/search/providers/service_categories_provider.dart';
import 'package:avto_app/features/repair_search/service_categories_page.dart';
import 'package:avto_app/features/parts_results/widgets/error_view.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ServiceCategory _cat(int id, String name) => ServiceCategory(id: id, name: name);

Widget _buildPage({
  required AsyncValue<List<ServiceCategory>> catValue,
}) {
  return ProviderScope(
    overrides: [
      serviceCategoriesProvider.overrideWith((_) async {
        final v = catValue;
        if (v is AsyncData<List<ServiceCategory>>) return v.value;
        if (v is AsyncError<List<ServiceCategory>>) {
          return Future<List<ServiceCategory>>.error(v.error, v.stackTrace);
        }
        // Loading — never resolves
        await Future<void>.delayed(const Duration(days: 1));
        return [];
      }),
    ],
    child: const MaterialApp(
      home: ServiceCategoriesPage(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ServiceCategoriesPage', () {
    testWidgets('data — renders a tile per service category with chevron',
        (tester) async {
      await tester.pumpWidget(_buildPage(
        catValue: AsyncValue.data([
          _cat(1, 'Развал-схождение'),
          _cat(2, 'Замена масла'),
        ]),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Развал-схождение'), findsOneWidget);
      expect(find.text('Замена масла'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsAtLeastNWidgets(2));
    });

    testWidgets('data — AppBar title is «Категории услуг»', (tester) async {
      await tester.pumpWidget(_buildPage(
        catValue: const AsyncValue.data([]),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Категории услуг'), findsOneWidget);
    });

    testWidgets('loading — shows CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(_buildPage(
        catValue: const AsyncValue.loading(),
      ));
      await tester.pump(); // stay in loading state

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('error — shows ErrorView', (tester) async {
      await tester.pumpWidget(_buildPage(
        catValue: AsyncValue.error(Exception('network'), StackTrace.empty),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsOneWidget);
    });
  });
}
