import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:yandex_maps_mapkit/init.dart' as mapkitInit;

import 'app_theme.dart';
import 'core/map/map_config.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive CE must be initialised and box opened BEFORE runApp (Pitfall 2).
  await Hive.initFlutter();
  await Hive.openBox('selectedCar');

  // D-04: MapKit init guard — must run after ensureInitialized, before runApp.
  // A missing or empty key skips init entirely (no crash). An init failure is
  // caught and degrades gracefully — list path remains fully usable.
  bool mapAvailable = false;
  if (mapkitKeyPresent) {
    try {
      await mapkitInit.initMapkit(apiKey: kMapkitApiKey);
      mapAvailable = true;
    } catch (_) {
      // Graceful degradation — «Карта» segment will be disabled (D-04).
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        mapAvailableProvider.overrideWithValue(mapAvailable),
      ],
      child: const AvtoApp(),
    ),
  );
}

class AvtoApp extends StatelessWidget {
  const AvtoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Авто-агрегатор',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      routerConfig: appRouter,
    );
  }
}
