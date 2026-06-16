import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:avto_app/core/models/vendor_result.dart';
import 'package:avto_app/features/parts_results/widgets/distance_badge.dart';
import 'package:avto_app/features/parts_results/widgets/vendor_result_card.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

VendorResult _vendor({
  double distanceM = 500,
  double? minPrice = 1500,
  int itemCount = 3,
}) =>
    VendorResult(
      vendorId: 'v1',
      name: 'АвтоМир',
      type: 'Магазин запчастей',
      lat: 40.18,
      lng: 44.51,
      distanceM: distanceM,
      itemCount: itemCount,
      minPrice: minPrice,
    );

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(body: child),
    );

// ---------------------------------------------------------------------------
// DistanceBadge — format tests
// ---------------------------------------------------------------------------

void main() {
  group('DistanceBadge', () {
    testWidgets('formats distance < 1000 m as "{N} м"', (tester) async {
      await tester.pumpWidget(_wrap(const DistanceBadge(distanceM: 250)));
      await tester.pumpAndSettle();

      expect(find.text('250 м'), findsOneWidget);
      expect(find.byIcon(Icons.place), findsOneWidget);
    });

    testWidgets('formats distance == 1000 m as "1.0 км"', (tester) async {
      await tester.pumpWidget(_wrap(const DistanceBadge(distanceM: 1000)));
      await tester.pumpAndSettle();

      expect(find.text('1.0 км'), findsOneWidget);
    });

    testWidgets('formats distance 2340 m as "2.3 км"', (tester) async {
      await tester.pumpWidget(_wrap(const DistanceBadge(distanceM: 2340)));
      await tester.pumpAndSettle();

      expect(find.text('2.3 км'), findsOneWidget);
    });

    testWidgets('badge has amber fill', (tester) async {
      await tester.pumpWidget(_wrap(const DistanceBadge(distanceM: 500)));
      await tester.pumpAndSettle();

      final containers = tester.widgetList<Container>(find.byType(Container));
      final hasAmber = containers.any((c) {
        final deco = c.decoration;
        if (deco is BoxDecoration) {
          return deco.color == const Color(0xFFF5A623);
        }
        return false;
      });
      expect(hasAmber, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // VendorResultCard
  // ---------------------------------------------------------------------------

  group('VendorResultCard', () {
    testWidgets('renders shop name and type', (tester) async {
      await tester.pumpWidget(_wrap(VendorResultCard(vendor: _vendor())));
      await tester.pumpAndSettle();

      expect(find.text('АвтоМир'), findsOneWidget);
      expect(find.text('Магазин запчастей'), findsOneWidget);
    });

    testWidgets('renders DistanceBadge', (tester) async {
      await tester.pumpWidget(_wrap(VendorResultCard(vendor: _vendor())));
      await tester.pumpAndSettle();

      expect(find.byType(DistanceBadge), findsOneWidget);
    });

    testWidgets('omits price row when minPrice is null', (tester) async {
      await tester.pumpWidget(
        _wrap(VendorResultCard(vendor: _vendor(minPrice: null))),
      );
      await tester.pumpAndSettle();

      // No "от" text when price is null
      expect(find.textContaining('от'), findsNothing);
      expect(find.byIcon(Icons.sell_outlined), findsNothing);
    });

    testWidgets('shows price row when minPrice is non-null', (tester) async {
      await tester.pumpWidget(
        _wrap(VendorResultCard(vendor: _vendor(minPrice: 1500))),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('от'), findsOneWidget);
      expect(find.byIcon(Icons.sell_outlined), findsOneWidget);
    });

    testWidgets('RU plural: 1 item → "1 позиция"', (tester) async {
      await tester.pumpWidget(
        _wrap(VendorResultCard(vendor: _vendor(itemCount: 1))),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 позиция'), findsOneWidget);
    });

    testWidgets('RU plural: 2 items → "2 позиции"', (tester) async {
      await tester.pumpWidget(
        _wrap(VendorResultCard(vendor: _vendor(itemCount: 2))),
      );
      await tester.pumpAndSettle();

      expect(find.text('2 позиции'), findsOneWidget);
    });

    testWidgets('RU plural: 5 items → "5 позиций"', (tester) async {
      await tester.pumpWidget(
        _wrap(VendorResultCard(vendor: _vendor(itemCount: 5))),
      );
      await tester.pumpAndSettle();

      expect(find.text('5 позиций'), findsOneWidget);
    });

    testWidgets('RU plural: 11 items → "11 позиций"', (tester) async {
      await tester.pumpWidget(
        _wrap(VendorResultCard(vendor: _vendor(itemCount: 11))),
      );
      await tester.pumpAndSettle();

      expect(find.text('11 позиций'), findsOneWidget);
    });

    testWidgets('RU plural: 21 items → "21 позиция"', (tester) async {
      await tester.pumpWidget(
        _wrap(VendorResultCard(vendor: _vendor(itemCount: 21))),
      );
      await tester.pumpAndSettle();

      expect(find.text('21 позиция'), findsOneWidget);
    });

    testWidgets('card min height is at least 88', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: VendorResultCard(vendor: _vendor()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final cardSize = tester.getSize(find.byType(VendorResultCard));
      expect(cardSize.height, greaterThanOrEqualTo(88));
    });

    testWidgets('whole card is tappable (InkWell present)', (tester) async {
      await tester.pumpWidget(_wrap(VendorResultCard(vendor: _vendor())));
      await tester.pumpAndSettle();

      expect(find.byType(InkWell), findsAtLeastNWidgets(1));
    });
  });
}
