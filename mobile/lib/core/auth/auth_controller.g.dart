// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authRepository)
const authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  const AuthRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'b1845c21e89227820af003689c9437f06a070ee3';

/// The session recovered from storage during startup, or null when there was
/// none. Overridden in main() with the real value before the app is built.
///
/// It exists so the restored account can reach [AuthController] as its initial
/// state instead of being pushed in afterwards. Pushing it from a widget's
/// initState threw «Tried to modify a provider while the widget tree was
/// building» — a crash on the first launch after any successful sign-in, and
/// invisible until then, because a fresh install has no token to restore.

@ProviderFor(restoredSession)
const restoredSessionProvider = RestoredSessionProvider._();

/// The session recovered from storage during startup, or null when there was
/// none. Overridden in main() with the real value before the app is built.
///
/// It exists so the restored account can reach [AuthController] as its initial
/// state instead of being pushed in afterwards. Pushing it from a widget's
/// initState threw «Tried to modify a provider while the widget tree was
/// building» — a crash on the first launch after any successful sign-in, and
/// invisible until then, because a fresh install has no token to restore.

final class RestoredSessionProvider
    extends $FunctionalProvider<AuthUser?, AuthUser?, AuthUser?>
    with $Provider<AuthUser?> {
  /// The session recovered from storage during startup, or null when there was
  /// none. Overridden in main() with the real value before the app is built.
  ///
  /// It exists so the restored account can reach [AuthController] as its initial
  /// state instead of being pushed in afterwards. Pushing it from a widget's
  /// initState threw «Tried to modify a provider while the widget tree was
  /// building» — a crash on the first launch after any successful sign-in, and
  /// invisible until then, because a fresh install has no token to restore.
  const RestoredSessionProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'restoredSessionProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$restoredSessionHash();

  @$internal
  @override
  $ProviderElement<AuthUser?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthUser? create(Ref ref) {
    return restoredSession(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthUser? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthUser?>(value),
    );
  }
}

String _$restoredSessionHash() => r'a37b76f2aa5d60d8c5548d611229d886b3978f41';

/// The signed-in account, or null when signed out.
///
/// keepAlive because a session outlives any single screen: an autoDispose
/// provider would be torn down the moment the sign-in page is popped, throwing
/// away the account that had just been obtained.

@ProviderFor(AuthController)
const authControllerProvider = AuthControllerProvider._();

/// The signed-in account, or null when signed out.
///
/// keepAlive because a session outlives any single screen: an autoDispose
/// provider would be torn down the moment the sign-in page is popped, throwing
/// away the account that had just been obtained.
final class AuthControllerProvider
    extends $NotifierProvider<AuthController, AuthUser?> {
  /// The signed-in account, or null when signed out.
  ///
  /// keepAlive because a session outlives any single screen: an autoDispose
  /// provider would be torn down the moment the sign-in page is popped, throwing
  /// away the account that had just been obtained.
  const AuthControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthUser? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthUser?>(value),
    );
  }
}

String _$authControllerHash() => r'bcac9193600b5672641d5c3d1b3541c2e063a41e';

/// The signed-in account, or null when signed out.
///
/// keepAlive because a session outlives any single screen: an autoDispose
/// provider would be torn down the moment the sign-in page is popped, throwing
/// away the account that had just been obtained.

abstract class _$AuthController extends $Notifier<AuthUser?> {
  AuthUser? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AuthUser?, AuthUser?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AuthUser?, AuthUser?>, AuthUser?, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
