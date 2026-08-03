import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:avto_app/l10n/l10n.dart';
import 'package:avto_app/l10n/locale_provider.dart';

void main() {
  testWidgets('loads Russian, Armenian, and English resources', (tester) async {
    const cases = <(Locale, String, String)>[
      (Locale('ru'), 'Авто Армения', 'Запчасти'),
      (Locale('hy'), 'Ավտո Հայաստան', 'Պահեստամասեր'),
      (Locale('en'), 'Auto Armenia', 'Parts'),
    ];

    for (final (locale, title, parts) in cases) {
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Text(
              '${context.l10n.appTitle}|${context.l10n.parts}',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('$title|$parts'), findsOneWidget);
    }
  });

  test('locale notifier defaults to Russian and accepts supported locales',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(appLocaleProvider), const Locale('ru'));

    await container
        .read(appLocaleProvider.notifier)
        .setLocale(const Locale('hy'));
    expect(container.read(appLocaleProvider), const Locale('hy'));

    await container
        .read(appLocaleProvider.notifier)
        .setLocale(const Locale('de'));
    expect(container.read(appLocaleProvider), const Locale('hy'));
  });
}
