import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

const _settingsBox = 'appSettings';
const _localeKey = 'locale';

final appLocaleProvider = NotifierProvider<AppLocaleNotifier, Locale>(
  AppLocaleNotifier.new,
);

class AppLocaleNotifier extends Notifier<Locale> {
  static const supportedLanguageCodes = {'ru', 'hy', 'en'};

  @override
  Locale build() {
    if (!Hive.isBoxOpen(_settingsBox)) return const Locale('ru');
    final saved = Hive.box(_settingsBox).get(_localeKey) as String?;
    return Locale(
      supportedLanguageCodes.contains(saved) ? saved! : 'ru',
    );
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedLanguageCodes.contains(locale.languageCode)) return;
    state = Locale(locale.languageCode);
    if (Hive.isBoxOpen(_settingsBox)) {
      await Hive.box(_settingsBox).put(_localeKey, locale.languageCode);
    }
  }
}
