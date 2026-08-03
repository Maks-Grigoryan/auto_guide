import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';
import 'generated/app_localizations_ru.dart';

export 'generated/app_localizations.dart';

extension AppLocalizationsContext on BuildContext {
  /// Russian is the deterministic fallback for isolated widget tests and
  /// embedders that have not installed the localization delegate.
  AppLocalizations get l10n =>
      AppLocalizations.of(this) ?? AppLocalizationsRu();
}
