import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'package:avto_app/core/auth/auth_controller.dart';
import 'package:avto_app/core/auth/auth_models.dart';
import 'package:avto_app/core/auth/auth_repository.dart';
import 'package:avto_app/features/hub/hub_page.dart';
import 'package:avto_app/l10n/l10n.dart';

late Directory _tempDir;

/// Records the sign-out instead of performing it.
///
/// The real one clears the token from secure storage, whose platform channel
/// has no handler under `flutter test`: the call never returns, so the screen
/// would sit forever on the await and never navigate.
class _FakeAuthRepository extends AuthRepository {
  bool signedOut = false;

  @override
  Future<void> signOut() async {
    signedOut = true;
  }
}

/// Builds the main screen behind a router, so tapping a section can be checked
/// by where it actually lands rather than by a callback the screen was handed.
Widget _buildHub({
  AuthUser? user,
  Locale locale = const Locale('ru'),
  AuthRepository? repository,
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HubPage()),
      GoRoute(
        path: '/search',
        builder: (_, __) => const Scaffold(body: Text('SEARCH SCREEN')),
      ),
      GoRoute(
        path: '/auth',
        builder: (_, __) => const Scaffold(body: Text('AUTH SCREEN')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      restoredSessionProvider.overrideWithValue(user),
      if (repository != null)
        authRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

void main() {
  // Signing out goes through the real repository, which caches the role in
  // Hive. Same setup as the auth page tests — change them together.
  setUpAll(() async {
    _tempDir = await Directory.systemTemp.createTemp('avto_hub_test');
    Hive.init(_tempDir.path);
    await Hive.openBox('appSettings');
  });

  tearDownAll(() async {
    await Hive.close();
    await _tempDir.delete(recursive: true);
  });

  setUp(() async {
    await Hive.box('appSettings').clear();
  });

  group('HubPage', () {
    testWidgets('shows separate parts and repair sections', (tester) async {
      await tester.pumpWidget(_buildHub());
      await tester.pumpAndSettle();

      expect(find.text('Запчасти'), findsOneWidget);
      expect(find.text('Магазины рядом с вами'), findsOneWidget);
      expect(find.text('Ремонт'), findsOneWidget);
      expect(find.text('Автосервисы рядом с вами'), findsOneWidget);
    });

    testWidgets('tapping parts opens the search', (tester) async {
      await tester.pumpWidget(_buildHub());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Запчасти'));
      await tester.pumpAndSettle();

      expect(find.text('SEARCH SCREEN'), findsOneWidget);
    });

    testWidgets('tapping repair opens the search', (tester) async {
      await tester.pumpWidget(_buildHub());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ремонт'));
      await tester.pumpAndSettle();

      expect(find.text('SEARCH SCREEN'), findsOneWidget);
    });

    testWidgets('sign out ends the session and returns to the auth screen',
        (tester) async {
      final repository = _FakeAuthRepository();
      await tester.pumpWidget(
        _buildHub(
          user: const AuthUser(id: '1', login: 'someone', role: UserRole.user),
          repository: repository,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      // Both halves matter: leaving the screen without dropping the session
      // would look like a sign-out and not be one.
      expect(repository.signedOut, isTrue);
      expect(find.text('AUTH SCREEN'), findsOneWidget);
    });

    // Two trees rather than two pumps: AuthController is keepAlive and reads
    // the restored session once, so re-pumping with a different override keeps
    // the first user and the test would pass for the wrong reason.
    testWidgets('an ordinary account shows no admin badge', (tester) async {
      await tester.pumpWidget(
        _buildHub(
          user: const AuthUser(id: '1', login: 'someone', role: UserRole.user),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Администратор'), findsNothing);
    });

    testWidgets('an admin account shows the admin badge', (tester) async {
      await tester.pumpWidget(
        _buildHub(
          user: const AuthUser(id: '2', login: 'admin', role: UserRole.admin),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Администратор'), findsOneWidget);
    });

    testWidgets('the section is translated with the app', (tester) async {
      await tester.pumpWidget(_buildHub(locale: const Locale('hy')));
      await tester.pumpAndSettle();

      expect(find.text('Պահեստամասեր'), findsOneWidget);
      expect(find.text('Վերանորոգում'), findsOneWidget);
      expect(find.text('Ճանապարհային օգնություն'), findsOneWidget);
      expect(find.text('Запчасти'), findsNothing);
      expect(find.text('Ремонт'), findsNothing);
    });

    testWidgets('roadside assistance sits under parts and repair',
        (tester) async {
      await tester.pumpWidget(_buildHub());
      await tester.pumpAndSettle();

      final parts = tester.getTopLeft(find.text('Запчасти')).dy;
      final repair = tester.getTopLeft(find.text('Ремонт')).dy;
      final roadside = tester.getTopLeft(find.text('Помощь на дороге')).dy;
      expect(repair, greaterThan(parts));
      expect(roadside, greaterThan(repair));
    });

    testWidgets('roadside assistance is marked as not built yet',
        (tester) async {
      await tester.pumpWidget(_buildHub());
      await tester.pumpAndSettle();

      expect(find.text('Скоро'), findsOneWidget);
    });

    testWidgets('tapping roadside assistance says so instead of doing nothing',
        (tester) async {
      await tester.pumpWidget(_buildHub());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Помощь на дороге'));
      await tester.pump();

      // Still on the main screen, and the tap was answered.
      expect(find.text('Раздел скоро появится'), findsOneWidget);
      expect(find.text('SEARCH SCREEN'), findsNothing);
    });

    testWidgets('the section stays usable at 200% text scale', (tester) async {
      tester.view.physicalSize = const Size(412, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: _buildHub(),
        ),
      );
      await tester.pumpAndSettle();

      // No overflow, and the sections are still reachable — the screen scrolls
      // instead of clipping the tiles when the text doubles.
      expect(tester.takeException(), isNull);
      expect(find.text('Запчасти'), findsOneWidget);
      expect(find.text('Ремонт'), findsOneWidget);
    });
  });
}
