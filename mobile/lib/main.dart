import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'app_theme.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive CE must be initialised and box opened BEFORE runApp (Pitfall 2).
  await Hive.initFlutter();
  await Hive.openBox('selectedCar');

  runApp(
    const ProviderScope(
      child: AvtoApp(),
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
