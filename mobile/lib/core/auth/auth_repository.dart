import 'package:dio/dio.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'auth_models.dart';
import 'token_store.dart';

const _baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000',
);

/// Hive key holding the role of the signed-in account, or absent when signed
/// out.
///
/// The token itself never comes here — Hive boxes are plain files on disk.
/// What this caches is only the *fact* of a session, so the router can answer
/// "is anyone signed in?" synchronously, the same way it already answers "is a
/// car chosen?". Secure storage is async; go_router's redirect is not.
const kAuthRoleKey = 'authRole';

/// Talks to /auth and owns where the access token is kept.
class AuthRepository {
  AuthRepository({Dio? client, TokenStore? storage, Box? settings})
      : _dio = client ??
            Dio(BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              headers: {'Content-Type': 'application/json'},
            )),
        _storage = storage ?? const TokenStore(),
        _settings = settings ?? Hive.box('appSettings');

  final Dio _dio;
  final TokenStore _storage;
  final Box _settings;

  /// Step one of registration: asks the server to send a confirmation code.
  ///
  /// Creates no account and returns no token — that happens only once the code
  /// comes back through [verifyCode]. Returns the identifier the code went to,
  /// so the screen can name it.
  ///
  /// Calling this again for the same identifier replaces the previous code,
  /// which is how «send it again» works.
  Future<String> startRegistration({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {'identifier': identifier, 'password': password},
      );
      final sentTo = response.data?['sentTo'] as Map<String, dynamic>?;
      return (sentTo?['login'] ?? sentTo?['phone'] ?? identifier) as String;
    } on DioException catch (error) {
      throw AuthException(_classify(error));
    }
  }

  /// Step two: sends the code back. On success the account exists and the
  /// session is stored, exactly as after a sign-in.
  Future<AuthUser> verifyCode({
    required String identifier,
    required String code,
  }) {
    return _authenticate(
      '/auth/verify',
      {'identifier': identifier, 'code': code},
      // Same status codes, different meanings here: 401 is a wrong code rather
      // than a wrong password, and 400 means the code expired or was guessed at
      // too often — not that the identifier was malformed.
      classify: (error) {
        switch (error.response?.statusCode) {
          case 400:
            return AuthFailure.codeExpired;
          case 401:
            return AuthFailure.invalidCode;
          case 409:
            return AuthFailure.accountExists;
          case 429:
            return AuthFailure.tooManyAttempts;
          case null:
            return AuthFailure.network;
          default:
            return AuthFailure.unknown;
        }
      },
    );
  }

  /// Signs in with a phone number or an email address — the server works out
  /// which one was given.
  Future<AuthUser> login({
    required String identifier,
    required String password,
  }) {
    return _authenticate('/auth/login', {
      'identifier': identifier,
      'password': password,
    });
  }

  /// Returns the account behind a stored token, or null when there is no
  /// usable session. Called once at startup.
  Future<AuthUser?> restore() async {
    final token = await _readToken();
    if (token == null) {
      // The cached role must not outlive the token. It did once: clearing
      // browser storage removed the token but left `authRole` in Hive, and the
      // router — which only reads Hive — went on admitting someone to an app
      // with no credentials to call the API with.
      await signOut();
      return null;
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/auth/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final user = AuthUser.fromJson(response.data!);
      _sessionActive = true;
      await _remember(user);
      return user;
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 401 || status == 404) {
        // Expired token, or an account since deleted. Either way this session
        // is over — drop it rather than leave the app believing it is signed
        // in while every call fails.
        await signOut();
        return null;
      }
      // An unreachable server is not proof the session ended. Keep the token
      // and let the person carry on rather than signing them out because their
      // train went into a tunnel.
      rethrow;
    }
  }

  Future<void> signOut() async {
    _sessionActive = false;
    await _storage.delete();
    await _settings.delete(kAuthRoleKey);
  }

  Future<String?> _readToken() => _storage.read();

  Future<AuthUser> _authenticate(
    String path,
    Map<String, dynamic> body, {
    AuthFailure Function(DioException)? classify,
  }) async {
    final AuthUser user;
    final String token;
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: body);
      final data = response.data!;
      user = AuthUser.fromJson(data['user'] as Map<String, dynamic>);
      token = data['accessToken'] as String;
    } on DioException catch (error) {
      throw AuthException((classify ?? _classify)(error));
    }

    // Persistence is deliberately outside the try above, and its failure is
    // deliberately not fatal. The server has already accepted the credentials;
    // turning a storage error into "sign-in failed" tells the person something
    // untrue and makes them retype a password that was right. The worst case
    // is that the session lasts until the app is closed.
    _sessionActive = true;
    try {
      await _storage.write(token);
      await _remember(user);
    } on Exception {
      // Nothing to recover, and nothing worth interrupting the person for.
    }
    return user;
  }

  Future<void> _remember(AuthUser user) =>
      _settings.put(kAuthRoleKey, user.role.name);

  AuthFailure _classify(DioException error) {
    switch (error.response?.statusCode) {
      // 400 is the server refusing the identifier's shape; 401 is a credential
      // that did not match. Collapsing them told someone signing up that their
      // password was wrong, when they had no account yet.
      case 400:
        return AuthFailure.invalidIdentifier;
      case 401:
        return AuthFailure.invalidCredentials;
      case 409:
        return AuthFailure.accountExists;
      case 429:
        return AuthFailure.tooManyAttempts;
      case null:
        return AuthFailure.network;
      default:
        return AuthFailure.unknown;
    }
  }
}

/// Set the moment the server accepts credentials, before anything is written
/// to disk.
///
/// Without it a failed write would strand the person: the sign-in succeeds,
/// the app navigates to the root, and the router — which can only see what is
/// on disk — sends them straight back to the sign-in screen with nothing on it
/// to explain why.
bool _sessionActive = false;

/// True when a session is active — readable synchronously, for the router.
///
/// Checks memory first so a session that could not be persisted still counts
/// for as long as the app is running.
bool hasStoredSession(Box settings) =>
    _sessionActive || settings.get(kAuthRoleKey) != null;
