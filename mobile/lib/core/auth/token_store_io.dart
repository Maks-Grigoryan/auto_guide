import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _tokenKey = 'auth_token';

/// Mobile and desktop token storage: Keychain on iOS,
/// EncryptedSharedPreferences on Android, the platform keyring elsewhere.
class TokenStore {
  const TokenStore();

  // Defaults are what this version wants: v11 removed the
  // encryptedSharedPreferences flag because Android storage is always
  // encrypted now, so passing it is a compile error rather than a no-op.
  static const _storage = FlutterSecureStorage();

  Future<String?> read() => _storage.read(key: _tokenKey);

  Future<void> write(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> delete() => _storage.delete(key: _tokenKey);
}
