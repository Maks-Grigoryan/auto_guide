import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'app_theme.dart';
import 'core/auth/auth_controller.dart';
import 'core/auth/auth_models.dart';
import 'core/auth/auth_repository.dart';
import 'core/map/map_config.dart';
import 'core/map/map_init.dart';
import 'l10n/l10n.dart';
import 'l10n/locale_provider.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive CE must be initialised and box opened BEFORE runApp (Pitfall 2).
  await Hive.initFlutter();
  await Hive.openBox('selectedCar');
  await Hive.openBox('appSettings');

  // D-04: map init guard — must run after ensureInitialized, before runApp.
  // Platform-specific behind core/map/map_init.dart: native MapKit on mobile,
  // Yandex Maps JS API 3.0 on web. Both degrade to false rather than throwing,
  // so the list path remains fully usable without a key.
  final mapAvailable = await initMapSdk();

  // Resolve the stored session before the first frame: the router decides
  // between /auth and the app synchronously, so it must not run while the
  // answer is still in flight — that would flash the sign-in screen at someone
  // who is already signed in.
  //
  // A server that cannot be reached is not a signed-out state. The cached role
  // in Hive stands, the person keeps their session, and the next call that
  // actually needs the network is where they find out it is down.
  AuthUser? session;
  try {
    session = await AuthRepository().restore();
  } on Exception {
    session = null;
  }

  runApp(
    ProviderScope(
      overrides: [
        mapAvailableProvider.overrideWithValue(mapAvailable),
        // Handed in as AuthController's initial state. An earlier version
        // pushed it from a widget's initState instead and crashed with
        // «Tried to modify a provider while the widget tree was building» —
        // on every launch that followed a successful sign-in.
        restoredSessionProvider.overrideWithValue(session),
      ],
      child: const AvtoApp(),
    ),
  );
}

/// Widest the app content is allowed to grow before it stops stretching and
/// centres itself instead. Keeps the phone layout intact on desktop browsers
/// rather than stretching 56 dp buttons across a 2560 px monitor.
const double kMaxContentWidth = 480;

class AvtoApp extends ConsumerWidget {
  const AvtoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      locale: ref.watch(appLocaleProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: appRouter,
      builder: (context, child) => _CenteredContent(child: child),
    );
  }
}

/// Constrains the app to [kMaxContentWidth] and centres it on wide viewports.
///
/// Below that width — every phone, and the mobile builds — the child is handed
/// through untouched, so the mobile layout is bit-for-bit unchanged. The gutter
/// is painted with the scaffold background so the page reads as one surface.
class _CenteredContent extends StatelessWidget {
  const _CenteredContent({required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final content = child ?? const SizedBox.shrink();
    final width = MediaQuery.sizeOf(context).width;
    if (width <= kMaxContentWidth) return content;

    return ColoredBox(
      color: const Color(0xFF1C1F26),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
          child: content,
        ),
      ),
    );
  }
}
