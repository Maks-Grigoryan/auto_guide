import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:avto_app/core/models/vendor_result.dart';
import 'package:avto_app/features/search/providers/repair_search_provider.dart';
import 'package:avto_app/features/repair_search/repair_results_page.dart';
import 'package:avto_app/features/parts_results/widgets/vendor_result_card.dart';
import 'package:avto_app/features/parts_results/widgets/empty_results_view.dart';
import 'package:avto_app/features/parts_results/widgets/error_view.dart';

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

VendorResult _repairVendor(String name, double distM, {double? minPrice}) =>
    VendorResult(
      vendorId: name,
      name: name,
      type: 'repair_shop',
      lat: 40.18,
      lng: 44.51,
      distanceM: distM,
      itemCount: 3,
      minPrice: minPrice,
    );

// ---------------------------------------------------------------------------
// Widget builder
// ---------------------------------------------------------------------------

Widget _buildPage({
  required AsyncValue<List<VendorResult>> searchValue,
  String? categoryName,
}) {
  final completer = Completer<List<VendorResult>>();

  return ProviderScope(
    overrides: [
      repairSearchProvider.overrideWith((_) {
        final v = searchValue;
        if (v is AsyncData<List<VendorResult>>) return Future.value(v.value);
        if (v is AsyncError<List<VendorResult>>) {
          return Future<List<VendorResult>>.error(v.error, v.stackTrace);
        }
        return completer.future;
      }),
    ],
    child: MaterialApp(
      home: RepairResultsPage(categoryName: categoryName),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('RepairResultsPage', () {
    testWidgets('data — renders VendorResultCard per repair vendor',
        (tester) async {
      await tester.pumpWidget(_buildPage(
        searchValue: AsyncValue.data([
          _repairVendor('СТО Центр', 500),
          _repairVendor('Автосервис Плюс', 1200),
        ]),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(VendorResultCard), findsNWidgets(2));
      expect(find.text('СТО Центр'), findsOneWidget);
      expect(find.text('Автосервис Плюс'), findsOneWidget);
    });

    testWidgets(
        'repair card — shows service-count plural and NO price when minPrice is null',
        (tester) async {
      await tester.pumpWidget(_buildPage(
        searchValue: AsyncValue.data([
          _repairVendor('СТО Ремонт', 300, minPrice: null),
        ]),
      ));
      await tester.pumpAndSettle();

      // No «от» price row
      expect(find.textContaining('от'), findsNothing);
      // Service count plural shown (3 services → «3 услуги»)
      expect(find.text('3 услуги'), findsOneWidget);
      // Icons.build_outlined for repair
      expect(find.byIcon(Icons.build_outlined), findsOneWidget);
    });

    testWidgets('empty — renders EmptyResultsView', (tester) async {
      await tester.pumpWidget(_buildPage(
        searchValue: const AsyncValue.data([]),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyResultsView), findsOneWidget);
    });

    testWidgets('error — renders ErrorView', (tester) async {
      await tester.pumpWidget(_buildPage(
        searchValue: AsyncValue.error(Exception('net'), StackTrace.empty),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsOneWidget);
    });

    testWidgets('loading — shows CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(_buildPage(
        searchValue: const AsyncValue.loading(),
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AppBar title uses categoryName when provided', (tester) async {
      await tester.pumpWidget(_buildPage(
        searchValue: const AsyncValue.data([]),
        categoryName: 'Развал-схождение',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Развал-схождение'), findsOneWidget);
    });

    testWidgets('AppBar title falls back to «Ремонт» when categoryName is null',
        (tester) async {
      await tester.pumpWidget(_buildPage(
        searchValue: const AsyncValue.data([]),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Ремонт'), findsOneWidget);
    });
  });
}
