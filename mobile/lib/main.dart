import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          surface: const Color(0xFF1C1F26),
          primary: const Color(0xFFF5A623),
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF1C1F26),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2A2D36),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF5A623),
            foregroundColor: const Color(0xFF1C1F26),
            minimumSize: const Size(double.infinity, 56),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
