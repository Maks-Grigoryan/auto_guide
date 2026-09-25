import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'auth_models.dart';
import 'auth_repository.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepository();

/// The session recovered from storage during startup, or null when there was
/// none. Overridden in main() with the real value before the app is built.
///
/// It exists so the restored account can reach [AuthController] as its initial
/// state instead of being pushed in afterwards. Pushing it from a widget's
/// initState threw «Tried to modify a provider while the widget tree was
/// building» — a crash on the first launch after any successful sign-in, and
/// invisible until then, because a fresh install has no token to restore.
@Riverpod(keepAlive: true)
AuthUser? restoredSession(Ref ref) => null;

/// The signed-in account, or null when signed out.
///
/// keepAlive because a session outlives any single screen: an autoDispose
/// provider would be torn down the moment the sign-in page is popped, throwing
/// away the account that had just been obtained.
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  AuthUser? build() => ref.read(restoredSessionProvider);

  Future<void> signIn({
    required String identifier,
    required String password,
  }) async {
    state = await ref
        .read(authRepositoryProvider)
        .login(identifier: identifier, password: password);
  }

  /// Asks the server to send a confirmation code. No account exists yet, so
  /// [state] is untouched — returns the identifier the code went to.
  Future<String> startRegistration({
    required String identifier,
    required String password,
  }) {
    return ref
        .read(authRepositoryProvider)
        .startRegistration(identifier: identifier, password: password);
  }

  /// Confirms the code, which is what actually creates the account. Whatever
  /// role ends up in [state] came from the server, the only place that decides
  /// it.
  Future<void> confirmCode({
    required String identifier,
    required String code,
  }) async {
    state = await ref
        .read(authRepositoryProvider)
        .verifyCode(identifier: identifier, code: code);
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = null;
  }
}
