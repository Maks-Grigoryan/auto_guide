import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:avto_app/core/models/vendor_detail.dart';
import 'package:avto_app/features/vendor_detail/contact_launcher.dart';
import 'package:avto_app/features/vendor_detail/vendor_detail_page.dart';

const _vendor = VendorDetail(
  id: '1',
  name: 'АвтоДетали Центр',
  type: 'parts_shop',
  phone: '+37410123456',
  address: 'ул. Абовяна 1, Ереван',
  lat: 40.18,
  lng: 44.51,
  rating: 4.75,
  isVerified: true,
  hours: {'mon-fri': '09:00-19:00', 'sat': '10:00-17:00'},
);

Widget _app(
  VendorDetail vendor,
  ContactLauncher launcher, {
  double textScale = 1,
}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(
        body: VendorDetailView(
          vendor: vendor,
          contactLauncher: launcher,
        ),
      ),
    ),
  );
}

void main() {
  group('VendorDetail', () {
    test('parses Postgres strings and JSON hours', () {
      final vendor = VendorDetail.fromJson({
        'id': '7',
        'name': 'СТО',
        'type': 'repair_shop',
        'phone': null,
        'address': null,
        'lat': 40.1,
        'lng': 44.5,
        'rating': '4.25',
        'is_verified': true,
        'hours': {'mon-fri': '09:00-18:00'},
      });

      expect(vendor.id, '7');
      expect(vendor.rating, 4.25);
      expect(vendor.hours, {'mon-fri': '09:00-18:00'});
    });
  });

  group('ContactLauncher', () {
    test('opens a tel URI in an external application', () async {
      Uri? launched;
      final launcher = ContactLauncher(
        canLaunch: (_) async => true,
        launch: (uri, {mode = LaunchMode.platformDefault}) async {
          launched = uri;
          expect(mode, LaunchMode.externalApplication);
          return true;
        },
      );

      await launcher.call('+37410123456');
      expect(launched, Uri(scheme: 'tel', path: '+37410123456'));
    });

    test('opens Yandex Navigator when installed', () async {
      final launched = <Uri>[];
      final launcher = ContactLauncher(
        canLaunch: (uri) async => uri.scheme == 'yandexnavi',
        launch: (uri, {mode = LaunchMode.platformDefault}) async {
          launched.add(uri);
          return true;
        },
      );

      await launcher.route(lat: 40.18, lng: 44.51);
      expect(launched.single.scheme, 'yandexnavi');
      expect(launched.single.queryParameters['lat_to'], '40.18');
      expect(launched.single.queryParameters['lon_to'], '44.51');
    });

    test('falls back to Yandex Maps web', () async {
      Uri? launched;
      final launcher = ContactLauncher(
        canLaunch: (_) async => false,
        launch: (uri, {mode = LaunchMode.platformDefault}) async {
          launched = uri;
          return true;
        },
      );

      await launcher.route(lat: 40.18, lng: 44.51);
      expect(launched!.scheme, 'https');
      expect(launched!.host, 'yandex.ru');
      expect(launched!.queryParameters['rtext'], '~40.18,44.51');
    });
  });

  group('VendorDetailView', () {
    testWidgets('shows full vendor information and actions', (tester) async {
      final launcher = ContactLauncher(
        canLaunch: (_) async => false,
        launch: (_, {mode = LaunchMode.platformDefault}) async => true,
      );
      await tester.pumpWidget(_app(_vendor, launcher));

      expect(find.text('АвтоДетали Центр'), findsOneWidget);
      expect(find.text('Проверенный продавец'), findsOneWidget);
      expect(find.text('4.8 из 5'), findsOneWidget);
      expect(find.text('Пн–Пт'), findsOneWidget);
      expect(find.text('Позвонить'), findsOneWidget);
      expect(find.text('Маршрут'), findsOneWidget);
    });

    testWidgets('hides missing phone and hours', (tester) async {
      final launcher = ContactLauncher(
        canLaunch: (_) async => false,
        launch: (_, {mode = LaunchMode.platformDefault}) async => true,
      );
      const minimal = VendorDetail(
        id: '2',
        name: 'СТО',
        type: 'repair_shop',
        lat: 40,
        lng: 44,
        isVerified: false,
      );
      await tester.pumpWidget(_app(minimal, launcher));

      expect(find.text('Позвонить'), findsNothing);
      expect(find.text('Часы работы'), findsNothing);
      expect(find.text('Маршрут'), findsOneWidget);
    });

    testWidgets('remains usable at 200% text scale', (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final launcher = ContactLauncher(
        canLaunch: (_) async => false,
        launch: (_, {mode = LaunchMode.platformDefault}) async => true,
      );
      await tester.pumpWidget(_app(_vendor, launcher, textScale: 2));

      expect(tester.takeException(), isNull);
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
