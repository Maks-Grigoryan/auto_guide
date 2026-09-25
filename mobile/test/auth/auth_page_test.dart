import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'package:avto_app/core/auth/auth_controller.dart';
import 'package:avto_app/core/auth/auth_models.dart';
import 'package:avto_app/core/auth/auth_repository.dart';
import 'package:avto_app/features/auth/ui/auth_page.dart';
import 'package:avto_app/l10n/l10n.dart';

/// Records what the page asked for and returns whatever the test set up.
///
/// Extends the real repository so the page is exercised through its actual
/// dependency; only the two network calls are replaced.
class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository();

  AuthFailure? failWith;

  /// Applied to the confirmation step only, so a test can let registration
  /// start and then reject the code.
  AuthFailure? verifyFailure;

  String? loginIdentifier;
  String? loginPassword;
  String? registerIdentifier;
  String? registerPassword;
  String? verifiedCode;

  static const _account = AuthUser(
    id: '1',
    role: UserRole.user,
    login: 'user@example.com',
  );

  @override
  Future<AuthUser> login({
    required String identifier,
    required String password,
  }) async {
    loginIdentifier = identifier;
    loginPassword = password;
    if (failWith != null) throw AuthException(failWith!);
    return _account;
  }

  @override
  Future<String> startRegistration({
    required String identifier,
    required String password,
  }) async {
    registerIdentifier = identifier;
    registerPassword = password;
    if (failWith != null) throw AuthException(failWith!);
    return identifier;
  }

  @override
  Future<AuthUser> verifyCode({
    required String identifier,
    required String code,
  }) async {
    verifiedCode = code;
    if (verifyFailure != null) throw AuthException(verifyFailure!);
    return _account;
  }
}

late Directory _tempDir;

Future<void> _pumpAuthPage(
  WidgetTester tester,
  _FakeAuthRepository repository,
) async {
  final router = GoRouter(
    initialLocation: '/auth',
    routes: [
      GoRoute(path: '/auth', builder: (_, __) => const AuthPage()),
      GoRoute(
        path: '/',
        builder: (_, __) => const Scaffold(body: Text('signed in')),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ru'),
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Fills the registration form with valid details and submits it, leaving the
/// page on the confirmation step.
Future<void> _startRegistration(WidgetTester tester) async {
  await tester.tap(find.text('Регистрация'));
  await tester.pumpAndSettle();

  await tester.enterText(
    find.widgetWithText(TextField, 'Телефон или e-mail'),
    'user@example.com',
  );
  await tester.enterText(
    find.widgetWithText(TextField, 'Пароль'),
    'testpass123',
  );
  await tester.enterText(
    find.widgetWithText(TextField, 'Повторите пароль'),
    'testpass123',
  );
  await tester.tap(find.text('Зарегистрироваться'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    _tempDir = await Directory.systemTemp.createTemp('avto_auth_test');
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

  testWidgets('sign-in tab asks for one identifier covering phone and email',
      (tester) async {
    await _pumpAuthPage(tester, _FakeAuthRepository());

    expect(find.text('Телефон или e-mail'), findsOneWidget);
    expect(find.text('Пароль'), findsOneWidget);
    // Registration-only fields must not appear on the sign-in form.
    expect(find.text('Повторите пароль'), findsNothing);
  });

  testWidgets('registration asks for one identifier, not an email and a phone',
      (tester) async {
    await _pumpAuthPage(tester, _FakeAuthRepository());

    await tester.tap(find.text('Регистрация'));
    await tester.pumpAndSettle();

    // Exactly one contact field. Separate «E-mail» and «Телефон» boxes read as
    // a request for both.
    expect(find.text('Телефон или e-mail'), findsOneWidget);
    expect(find.text('E-mail'), findsNothing);
    expect(find.text('Телефон'), findsNothing);
    expect(find.text('Повторите пароль'), findsOneWidget);
    expect(find.text('Зарегистрироваться'), findsOneWidget);
  });

  testWidgets('empty sign-in is refused before any request is made',
      (tester) async {
    final repository = _FakeAuthRepository();
    await _pumpAuthPage(tester, repository);

    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();

    expect(find.text('Введите телефон или e-mail'), findsOneWidget);
    expect(repository.loginIdentifier, isNull);
  });

  testWidgets('registration with an empty identifier is refused',
      (tester) async {
    final repository = _FakeAuthRepository();
    await _pumpAuthPage(tester, repository);

    await tester.tap(find.text('Регистрация'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Зарегистрироваться'));
    await tester.pumpAndSettle();

    expect(find.text('Введите телефон или e-mail'), findsOneWidget);
    expect(repository.registerIdentifier, isNull);
  });

  testWidgets('registration refuses something that is neither contact',
      (tester) async {
    final repository = _FakeAuthRepository();
    await _pumpAuthPage(tester, repository);

    await tester.tap(find.text('Регистрация'));
    await tester.pumpAndSettle();

    // No «@» and not enough digits to be a number. This is also what keeps
    // «admin» from being claimed through sign-up.
    await tester.enterText(
      find.widgetWithText(TextField, 'Телефон или e-mail'),
      'admin',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Пароль'),
      'testpass123',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Повторите пароль'),
      'testpass123',
    );
    await tester.tap(find.text('Зарегистрироваться'));
    await tester.pumpAndSettle();

    expect(find.text('Это не похоже на телефон или e-mail'), findsOneWidget);
    expect(repository.registerIdentifier, isNull);
  });

  testWidgets('registration accepts a phone number as the identifier',
      (tester) async {
    final repository = _FakeAuthRepository();
    await _pumpAuthPage(tester, repository);

    await tester.tap(find.text('Регистрация'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Телефон или e-mail'),
      '+374 11 000000',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Пароль'),
      'testpass123',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Повторите пароль'),
      'testpass123',
    );
    await tester.tap(find.text('Зарегистрироваться'));
    await tester.pumpAndSettle();

    // Passed through as typed — normalising it is the server's job, and doing
    // it in two places is how the two ends drift apart.
    expect(repository.registerIdentifier, '+374 11 000000');

    // And crucially: no account and no session yet. The page has moved to the
    // confirmation step instead of letting the person in.
    expect(find.text('signed in'), findsNothing);
    expect(find.text('Код из 6 цифр'), findsOneWidget);
    expect(find.text('Подтвердить'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Код из 6 цифр'),
      '123456',
    );
    await tester.tap(find.text('Подтвердить'));
    await tester.pumpAndSettle();

    expect(repository.verifiedCode, '123456');
    expect(find.text('signed in'), findsOneWidget);
  });

  testWidgets('the confirmation step hides the sign-in / register tabs',
      (tester) async {
    await _pumpAuthPage(tester, _FakeAuthRepository());
    await _startRegistration(tester);

    // Switching to «Вход» mid-confirmation would silently abandon a
    // registration that has already sent someone a message.
    expect(find.text('Вход'), findsNothing);
    expect(find.text('Изменить контакт'), findsOneWidget);
  });

  testWidgets('a malformed code never reaches the server', (tester) async {
    final repository = _FakeAuthRepository();
    await _pumpAuthPage(tester, repository);
    await _startRegistration(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Код из 6 цифр'),
      '12ab',
    );
    await tester.tap(find.text('Подтвердить'));
    await tester.pumpAndSettle();

    expect(find.text('Введите код из 6 цифр'), findsOneWidget);
    expect(repository.verifiedCode, isNull);
  });

  testWidgets('a wrong code is reported without leaving the step',
      (tester) async {
    final repository = _FakeAuthRepository()
      ..verifyFailure = AuthFailure.invalidCode;
    await _pumpAuthPage(tester, repository);
    await _startRegistration(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Код из 6 цифр'),
      '000000',
    );
    await tester.tap(find.text('Подтвердить'));
    await tester.pumpAndSettle();

    expect(find.text('Неверный код'), findsOneWidget);
    expect(find.text('signed in'), findsNothing);
    // Still on the step, so another try does not mean starting over.
    expect(find.text('Код из 6 цифр'), findsOneWidget);
  });

  testWidgets('«Изменить контакт» returns to the registration form',
      (tester) async {
    await _pumpAuthPage(tester, _FakeAuthRepository());
    await _startRegistration(tester);

    await tester.tap(find.text('Изменить контакт'));
    await tester.pumpAndSettle();

    expect(find.text('Код из 6 цифр'), findsNothing);
    expect(find.text('Зарегистрироваться'), findsOneWidget);
    expect(find.text('Вход'), findsOneWidget);
  });

  testWidgets('mismatched passwords are caught before the request',
      (tester) async {
    final repository = _FakeAuthRepository();
    await _pumpAuthPage(tester, repository);

    await tester.tap(find.text('Регистрация'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Телефон или e-mail'),
      'user@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Пароль'),
      'testpass123',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Повторите пароль'),
      'testpass124',
    );
    await tester.tap(find.text('Зарегистрироваться'));
    await tester.pumpAndSettle();

    expect(find.text('Пароли не совпадают'), findsOneWidget);
    expect(repository.registerIdentifier, isNull);
  });

  testWidgets('a short password is refused with the length rule',
      (tester) async {
    final repository = _FakeAuthRepository();
    await _pumpAuthPage(tester, repository);

    await tester.tap(find.text('Регистрация'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Телефон или e-mail'),
      '+37411000000',
    );
    await tester.enterText(find.widgetWithText(TextField, 'Пароль'), 'abc123');
    await tester.tap(find.text('Зарегистрироваться'));
    await tester.pumpAndSettle();

    expect(
      find.text('Пароль должен быть не короче 8 символов'),
      findsOneWidget,
    );
    expect(repository.registerIdentifier, isNull);
  });

  testWidgets('a rejected sign-in shows the translated reason, not server text',
      (tester) async {
    final repository = _FakeAuthRepository()
      ..failWith = AuthFailure.invalidCredentials;
    await _pumpAuthPage(tester, repository);

    await tester.enterText(
      find.widgetWithText(TextField, 'Телефон или e-mail'),
      'user@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Пароль'),
      'wrong-password',
    );
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();

    expect(find.text('Неверный телефон, e-mail или пароль'), findsOneWidget);
    expect(find.text('Invalid credentials'), findsNothing);
  });

  testWidgets('rate limiting is reported as its own message', (tester) async {
    final repository = _FakeAuthRepository()
      ..failWith = AuthFailure.tooManyAttempts;
    await _pumpAuthPage(tester, repository);

    await tester.enterText(
      find.widgetWithText(TextField, 'Телефон или e-mail'),
      'user@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Пароль'),
      'testpass123',
    );
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();

    expect(
      find.text('Слишком много попыток. Подождите минуту'),
      findsOneWidget,
    );
  });

  testWidgets('a successful sign-in trims the identifier and leaves the page',
      (tester) async {
    final repository = _FakeAuthRepository();
    await _pumpAuthPage(tester, repository);

    await tester.enterText(
      find.widgetWithText(TextField, 'Телефон или e-mail'),
      '  user@example.com  ',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Пароль'),
      'testpass123',
    );
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();

    // Trailing spaces are easy to pick up from a paste and would otherwise
    // turn a correct address into "no such account".
    expect(repository.loginIdentifier, 'user@example.com');
    expect(repository.loginPassword, 'testpass123');
    expect(find.text('signed in'), findsOneWidget);
  });

  testWidgets('switching tabs clears an error about the other form',
      (tester) async {
    final repository = _FakeAuthRepository();
    await _pumpAuthPage(tester, repository);

    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();
    expect(find.text('Введите телефон или e-mail'), findsOneWidget);

    await tester.tap(find.text('Регистрация'));
    await tester.pumpAndSettle();

    expect(find.text('Введите телефон или e-mail'), findsNothing);
  });
}
