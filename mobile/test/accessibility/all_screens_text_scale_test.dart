import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:avto_app/app_theme.dart';
import 'package:avto_app/core/models/part_category.dart';
import 'package:avto_app/core/models/service_category.dart';
import 'package:avto_app/core/models/vendor_detail.dart';
import 'package:avto_app/core/models/vendor_result.dart';
import 'package:avto_app/features/car_selector/data/catalog_providers.dart';
import 'package:avto_app/features/car_selector/domain/selected_car.dart';
import 'package:avto_app/features/car_selector/state/selected_car_notifier.dart';
import 'package:avto_app/features/car_selector/ui/confirmation_page.dart';
import 'package:avto_app/features/car_selector/ui/generation_list_page.dart';
import 'package:avto_app/features/car_selector/ui/make_list_page.dart';
import 'package:avto_app/features/car_selector/ui/model_list_page.dart';
import 'package:avto_app/features/home/home_page.dart';
import 'package:avto_app/features/parts_results/parts_results_page.dart';
import 'package:avto_app/features/repair_search/repair_results_page.dart';
import 'package:avto_app/features/repair_search/service_categories_page.dart';
import 'package:avto_app/features/search/providers/categories_provider.dart';
import 'package:avto_app/features/search/providers/parts_search_provider.dart';
import 'package:avto_app/features/search/providers/repair_search_provider.dart';
import 'package:avto_app/features/search/providers/service_categories_provider.dart';
import 'package:avto_app/features/vendor_detail/vendor_detail_page.dart';
import 'package:avto_app/features/vendor_detail/vendor_detail_provider.dart';
import 'package:avto_app/l10n/l10n.dart';

const _car = SelectedCar(
  makeId: 1,
  makeName: 'Mercedes-Benz',
  modelId: 2,
  modelName: 'C-Class',
  generationId: 3,
  generationLabel: 'W205 (2014–2021)',
);

class _SelectedCarForTest extends SelectedCarNotifier {
  @override
  SelectedCar? build() => _car;

  @override
  void confirm() {}
}

const _vendorResult = VendorResult(
  vendorId: '1',
  name: 'АвтоДетали Центр — длинное название',
  type: 'parts_shop',
  phone: '+374 10 123456',
  address: 'Ереван, проспект Маштоца, 45',
  lat: 40.18,
  lng: 44.51,
  distanceM: 1450,
  itemCount: 12,
  minPrice: 12500,
  rating: 4.8,
);

const _vendorDetail = VendorDetail(
  id: '1',
  name: 'АвтоДетали Центр — длинное название',
  type: 'parts_shop',
  phone: '+374 10 123456',
  address: 'Ереван, проспект Маштоца, 45',
  lat: 40.18,
  lng: 44.51,
  rating: 4.8,
  isVerified: true,
  hours: {
    'Понедельник–пятница': '09:00–19:00',
    'Суббота и воскресенье': '10:00–17:00',
  },
);

Widget _testApp(Widget home, Locale locale) {
  return ProviderScope(
    overrides: [
      selectedCarProvider.overrideWith(_SelectedCarForTest.new),
      categoriesProvider.overrideWith(
        (_) async => const [
          PartCategory(id: 1, name: 'Тормозная система'),
          PartCategory(id: 2, name: 'Электрооборудование'),
        ],
      ),
      makesProvider.overrideWith(
        (_) async => const [
          {'id': 1, 'name': 'Mercedes-Benz'},
          {'id': 2, 'name': 'Toyota'},
        ],
      ),
      modelsProvider(1).overrideWith(
        (_) async => const [
          {'id': 2, 'name': 'C-Class'},
          {'id': 4, 'name': 'GLE Coupe'},
        ],
      ),
      generationsProvider(2).overrideWith(
        (_) async => const [
          {
            'id': 3,
            'name': 'W205',
            'year_from': 2014,
            'year_to': 2021,
          },
        ],
      ),
      serviceCategoriesProvider.overrideWith(
        (_) async => const [
          ServiceCategory(id: 1, name: 'Развал-схождение'),
          ServiceCategory(id: 2, name: 'Диагностика электрооборудования'),
        ],
      ),
      partsSearchProvider.overrideWith((_) async => const [_vendorResult]),
      repairSearchProvider.overrideWith((_) async => const [_vendorResult]),
      vendorDetailProvider('1').overrideWith((_) async => _vendorDetail),
    ],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: appTheme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(2),
        ),
        child: child!,
      ),
      home: home,
    ),
  );
}

void main() {
  testWidgets('all route screens support RU/HY/EN at 200% text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final screens = <(String, Widget Function())>[
      ('home', HomePage.new),
      ('make selector', MakeListPage.new),
      ('model selector', () => const ModelListPage(makeId: 1)),
      ('generation selector', () => const GenerationListPage(modelId: 2)),
      ('confirmation', ConfirmationPage.new),
      ('parts results', PartsResultsPage.new),
      ('service categories', ServiceCategoriesPage.new),
      ('repair results', RepairResultsPage.new),
      ('vendor detail', () => VendorDetailPage(vendorId: '1')),
    ];

    for (final locale in AppLocalizations.supportedLocales) {
      for (final (name, createScreen) in screens) {
        await tester.pumpWidget(_testApp(createScreen(), locale));
        await tester.pumpAndSettle();

        expect(
          tester.takeException(),
          isNull,
          reason: '$name overflowed for ${locale.languageCode}',
        );
      }
    }
  });
}
