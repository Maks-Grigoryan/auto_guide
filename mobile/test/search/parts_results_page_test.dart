import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:avto_app/core/models/vendor_result.dart';
import 'package:avto_app/core/location/location_service.dart';
import 'package:avto_app/features/search/providers/parts_search_provider.dart';
import 'package:avto_app/features/parts_results/parts_results_page.dart';
import 'package:avto_app/features/parts_results/widgets/vendor_result_card.dart';
import 'package:avto_app/features/parts_results/widgets/empty_results_view.dart';
import 'package:avto_app/features/parts_results/widgets/error_view.dart';
import 'package:avto_app/features/parts_results/widgets/location_denied_view.dart';

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

VendorResult _v(String name, double distM) => VendorResult(
      vendorId: name,
      name: name,
      type: 'Магазин',
      lat: 40.18,
      lng: 44.51,
      distanceM: distM,
      itemCount: 2,
      minPrice: 500,
    );

// ---------------------------------------------------------------------------
// Widget builder
// ---------------------------------------------------------------------------

Widget _buildPage({
  required AsyncValue<List<VendorResult>> searchValue,
  LocationResultStatus locationStatus = LocationResultStatus.granted,
  String? categoryName,
  String? query,
}) {
  // For loading state: use a Completer that never completes so no timer is left.
  final completer = Completer<List<VendorResult>>();

  return ProviderScope(
    overrides: [
      partsSearchProvider.overrideWith((_) {
        final v = searchValue;
        if (v is AsyncData<List<VendorResult>>) return Future.value(v.value);
        if (v is AsyncError<List<VendorResult>>) {
          return Future<List<VendorResult>>.error(v.error, v.stackTrace);
        }
        // Loading: return a future that never resolves (no timer involved).
        return completer.future;
      }),
    ],
    child: MaterialApp(
      home: PartsResultsPage(
        categoryName: categoryName,
        query: query,
        locationStatus: locationStatus,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('PartsResultsPage', () {
    testWidgets('non-empty results → list of VendorResultCards', (tester) async {
      await tester.pumpWidget(_buildPage(
        searchValue: AsyncValue.data([
          _v('МагазинА', 500),
          _v('МагазинБ', 1500),
        ]),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(VendorResultCard), findsNWidgets(2));
      expect(find.text('МагазинА'), findsOneWidget);
      expect(find.text('МагазинБ'), findsOneWidget);
    });

    testWidgets('empty list → EmptyResultsView (not ErrorView)', (tester) async {
      await tester.pumpWidget(_buildPage(
        searchValue: const AsyncValue.data([]),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyResultsView), findsOneWidget);
      expect(find.byType(ErrorView), findsNothing);
      expect(find.text('Ничего не найдено'), findsOneWidget);
    });

    testWidgets('loading → CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(_buildPage(
        searchValue: const AsyncValue.loading(),
      ));
      await tester.pump(); // don't settle — stay in loading

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('error → ErrorView with "Повторить" button', (tester) async {
      await tester.pumpWidget(_buildPage(
        searchValue: AsyncValue.error(Exception('net'), StackTrace.empty),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text('Не удалось загрузить результаты'), findsOneWidget);
      expect(find.text('Повторить'), findsOneWidget);
    });

    testWidgets('location denied → LocationDeniedView shown above results',
        (tester) async {
      await tester.pumpWidget(_buildPage(
        searchValue: AsyncValue.data([_v('МагазинВ', 300)]),
        locationStatus: LocationResultStatus.denied,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(LocationDeniedView), findsOneWidget);
      expect(find.text('Геолокация выключена'), findsOneWidget);
      // Results still render (non-blocking)
      expect(find.byType(VendorResultCard), findsOneWidget);
    });

    testWidgets('location deniedForever → shows "Открыть настройки"',
        (tester) async {
      await tester.pumpWidget(_buildPage(
        searchValue: AsyncValue.data([_v('МагазинГ', 200)]),
        locationStatus: LocationResultStatus.deniedForever,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Открыть настройки'), findsOneWidget);
    });

    testWidgets('AppBar shows categoryName when provided', (tester) async {
      await tester.pumpWidget(_buildPage(
        searchValue: const AsyncValue.data([]),
        categoryName: 'Тормоза',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Тормоза'), findsOneWidget);
    });

    testWidgets('AppBar shows "Поиск: {query}" when query provided',
        (tester) async {
      await tester.pumpWidget(_buildPage(
        searchValue: const AsyncValue.data([]),
        query: 'OEM-123',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Поиск: OEM-123'), findsOneWidget);
    });
  });
}
