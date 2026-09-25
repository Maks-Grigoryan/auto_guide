import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:avto_app/core/models/part_category.dart';
import 'package:avto_app/core/location/location_service.dart';
import 'package:avto_app/core/models/service_category.dart';
import 'package:avto_app/features/search/providers/categories_provider.dart';
import 'package:avto_app/features/search/providers/service_categories_provider.dart';
import 'package:avto_app/features/home/home_page.dart';
import 'package:avto_app/features/car_selector/state/selected_car_notifier.dart';

// ---------------------------------------------------------------------------
// Helper: build a testable home page with provider overrides.
// ---------------------------------------------------------------------------

/// Fake location service that always returns Yerevan instantly (no geolocator).
class _FakeLocationService extends LocationService {
  _FakeLocationService()
      : super(
          delegate: _FakeDelegate(),
        );
}

class _FakeDelegate implements LocationServiceDelegate {
  @override
  Future<bool> isLocationServiceEnabled() async => true;
  @override
  Future<LocationPermissionStatus> checkPermission() async =>
      LocationPermissionStatus.granted;
  @override
  Future<LocationPermissionStatus> requestPermission() async =>
      LocationPermissionStatus.granted;
  @override
  Future<LatLng> getCurrentPosition() async =>
      const LatLng(kYerevanLat, kYerevanLng);
}

Widget _buildHome({
  List<PartCategory> categories = const [],
  AsyncValue<List<PartCategory>>? categoriesAsyncOverride,
  int initialIndex = 0,
}) {
  final catAsyncValue = categoriesAsyncOverride ?? AsyncValue.data(categories);

  return ProviderScope(
    overrides: [
      locationServiceProvider.overrideWithValue(_FakeLocationService()),
      categoriesProvider.overrideWith((_) async {
        final v = catAsyncValue;
        if (v is AsyncData<List<PartCategory>>) return v.value;
        if (v is AsyncError<List<PartCategory>>) throw v.error;
        // loading — block forever (test with loading state)
        await Future<void>.delayed(const Duration(days: 1));
        return [];
      }),
      selectedCarProvider.overrideWithValue(null),
      // Repair now renders inside HomePage, so its categories must be stubbed
      // here too rather than only in the repair screen's own test.
      serviceCategoriesProvider.overrideWith((_) async => const [
            ServiceCategory(id: 1, name: 'Диагностика'),
            ServiceCategory(id: 2, name: 'Замена масла'),
          ]),
    ],
    child: MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => HomePage(initialIndex: initialIndex),
          ),
          GoRoute(
            path: '/results/parts',
            builder: (_, __) => const Scaffold(body: Text('Results')),
          ),
          GoRoute(
            path: '/selector/make',
            builder: (_, __) => const Scaffold(body: Text('Selector')),
          ),
          // REP-01: repair category browse (Plan 04-03)
          GoRoute(
            path: '/repair/categories',
            builder: (_, __) => const Scaffold(body: Text('RepairCategories')),
          ),
        ],
      ),
    ),
  );
}

void main() {
  // ── Test 1: RES-01 – core widgets present ─────────────────────────────────
  testWidgets('home renders search field, section label, and no car button',
      (tester) async {
    await tester.pumpWidget(_buildHome(categories: [
      const PartCategory(id: 1, name: 'Тормоза'),
      const PartCategory(id: 2, name: 'Двигатель'),
    ]));
    await tester.pumpAndSettle();

    // Parts section, no section switcher: the hub owns the parts/repair
    // choice, so this screen never shows both words at once.
    expect(find.text('Категории запчастей'), findsOneWidget);
    expect(find.text('Ремонт'), findsNothing);

    // Search field (hint text)
    expect(find.byType(TextField), findsAtLeastNWidgets(1));

    // No «Выбрать авто» button: choosing a car is the app's first step, so the
    // home screen never offers it — the car is shown as a CarChip instead.
    expect(find.text('Выбрать авто'), findsNothing);

    // Category tiles
    expect(find.text('Тормоза'), findsOneWidget);
    expect(find.text('Двигатель'), findsOneWidget);
  });

  // ── Test 2: Category tap → /results/parts ─────────────────────────────────
  testWidgets('tapping a category navigates to /results/parts', (tester) async {
    await tester.pumpWidget(_buildHome(categories: [
      const PartCategory(id: 5, name: 'Фильтры'),
    ]));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Фильтры'));
    await tester.pumpAndSettle();

    expect(find.text('Results'), findsOneWidget);
  });

  // ── Test 3: Empty query submit → no navigation ─────────────────────────────
  testWidgets('submitting empty search does not navigate', (tester) async {
    await tester.pumpWidget(_buildHome());
    await tester.pumpAndSettle();

    // Find the search field and submit it empty
    await tester.tap(find.byType(TextField).first);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    // Still on home
    expect(find.text('Категории запчастей'), findsOneWidget);
    expect(find.text('Results'), findsNothing);
  });

  // ── Test 4: Non-empty query submit → /results/parts ───────────────────────
  testWidgets('submitting non-empty query navigates to /results/parts',
      (tester) async {
    await tester.pumpWidget(_buildHome());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '1234567890');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('Results'), findsOneWidget);
  });

  // ── Test 5: Error state → retry button visible ────────────────────────────
  testWidgets('category load error shows Не удалось загрузить категории',
      (tester) async {
    await tester.pumpWidget(_buildHome(
      categoriesAsyncOverride: AsyncValue.error(
        Exception('network error'),
        StackTrace.empty,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Не удалось загрузить категории'), findsOneWidget);
    expect(find.text('Повторить'), findsOneWidget);
  });

  // ── Test 6: no in-screen section switcher ─────────────────────────────────
  testWidgets('parts section shows no repair switcher', (tester) async {
    await tester.pumpWidget(_buildHome(categories: [
      const PartCategory(id: 1, name: 'Тормоза'),
    ]));
    await tester.pumpAndSettle();

    // The section is fixed by initialIndex: switching happens on the hub, so
    // the repair word and the service list never appear on the parts screen.
    expect(find.text('Ремонт'), findsNothing);
    expect(find.text('Категории услуг'), findsNothing);
    expect(find.text('Категории запчастей'), findsOneWidget);
    expect(find.text('Тормоза'), findsOneWidget);
  });

  // ── Test 7: initialIndex selects the opening section ──────────────────────
  testWidgets('HomePage with initialIndex 1 opens on the repair list',
      (tester) async {
    await tester.pumpWidget(_buildHome(initialIndex: 1));
    await tester.pumpAndSettle();

    expect(find.text('Категории услуг'), findsOneWidget);
    expect(find.text('Диагностика'), findsOneWidget);
    expect(find.text('Категории запчастей'), findsNothing);
    // And the repair screen has no switcher back either.
    expect(find.text('Ремонт'), findsNothing);
  });
}
