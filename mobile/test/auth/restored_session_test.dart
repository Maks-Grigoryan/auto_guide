import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:avto_app/core/auth/auth_controller.dart';
import 'package:avto_app/core/auth/auth_models.dart';

/// Regression cover for the startup path that had none.
///
/// A session restored from storage used to be pushed into AuthController from
/// a widget's initState, which Riverpod rejects: the app died on the red
/// «Tried to modify a provider while the widget tree was building» screen.
///
/// Nothing caught it because it only fires when a token already exists — a
/// fresh install restores nothing, so the first run on any new device looked
/// fine. It broke on the second launch, for everyone who had signed in.
void main() {
  const account = AuthUser(
    id: '7',
    role: UserRole.admin,
    login: 'admin',
  );

  test('signed-out startup leaves the controller empty', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(authControllerProvider), isNull);
  });

  test('a restored session is the controller initial state', () {
    final container = ProviderContainer(
      overrides: [restoredSessionProvider.overrideWithValue(account)],
    );
    addTearDown(container.dispose);

    // Read, never written after the fact: reading it is what proves the value
    // arrives through build() rather than through a later mutation.
    final user = container.read(authControllerProvider);
    expect(user?.login, 'admin');
    expect(user?.isAdmin, isTrue);
  });

  test('the restored role is whatever the server reported', () {
    final container = ProviderContainer(
      overrides: [
        restoredSessionProvider.overrideWithValue(
          const AuthUser(id: '8', role: UserRole.user, phone: '+37411000000'),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(authControllerProvider)?.isAdmin, isFalse);
  });
}
