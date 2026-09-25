import 'package:web/web.dart' as web;

/// Namespaced so the key cannot collide with anything else served from the
/// same origin.
const _tokenKey = 'avto.auth_token';

/// Browser token storage.
///
/// localStorage rather than a cookie: the API is called cross-origin with a
/// bearer header, so a cookie would buy nothing and would add CSRF surface.
/// The token is readable by any script on this origin — which is why the app's
/// pages must never inline third-party script, and why the token is given a
/// bounded lifetime on the server side.
class TokenStore {
  const TokenStore();

  Future<String?> read() async => web.window.localStorage.getItem(_tokenKey);

  Future<void> write(String token) async =>
      web.window.localStorage.setItem(_tokenKey, token);

  Future<void> delete() async => web.window.localStorage.removeItem(_tokenKey);
}
