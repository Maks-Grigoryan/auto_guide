import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../l10n/locale_provider.dart';

/// Opens the language sheet.
///
/// Shared rather than written per screen: the sign-in page needs it as much as
/// the home screen does — someone who cannot read the interface cannot reach
/// the home screen to change it.
Future<void> showLanguagePicker(BuildContext context, WidgetRef ref) async {
  final current = ref.read(appLocaleProvider).languageCode;
  final l10n = context.l10n;

  await showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: Text(l10n.language)),
          for (final option in [
            ('ru', l10n.russian),
            ('hy', l10n.armenian),
            ('en', l10n.english),
          ])
            ListTile(
              minTileHeight: 56,
              // A filled radio, not merely bold text: the current language has
              // to be recognisable to someone who cannot read the other two.
              leading: Icon(
                option.$1 == current
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
              ),
              title: Text(option.$2),
              onTap: () {
                ref
                    .read(appLocaleProvider.notifier)
                    .setLocale(Locale(option.$1));
                Navigator.of(sheetContext).pop();
              },
            ),
        ],
      ),
    ),
  );
}

/// Globe button that opens [showLanguagePicker].
class LanguageButton extends ConsumerWidget {
  const LanguageButton({super.key, this.color});

  /// Overridden on the sign-in screen, which has no app bar to inherit from.
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: context.l10n.language,
      onPressed: () => showLanguagePicker(context, ref),
      // IconButton's own default lands at 40 dp outside an app bar, which is
      // under the 48 dp this app holds every tap target to (ACC-01).
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      icon: Icon(Icons.language, color: color),
    );
  }
}
