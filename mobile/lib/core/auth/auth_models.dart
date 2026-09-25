/// Account roles. Mirrors the `users.role` CHECK constraint in migration 011.
///
/// The app never sends a role anywhere — it only reads the one the server
/// reports. An admin account exists solely because someone ran
/// `npm run admin:create` against the deployment.
enum UserRole { user, admin }

/// The signed-in account, as returned by /auth/login and /auth/me.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.role,
    this.login,
    this.phone,
  });

  final String id;
  final UserRole role;

  /// The non-phone identifier: an email address for anyone who registered, or a
  /// short name for an administrator created by `admin:create`. Called `login`
  /// rather than `email` because it is not always one — see migration 012.
  final String? login;

  final String? phone;

  bool get isAdmin => role == UserRole.admin;

  /// What to show as the account's name: whichever identifier was registered.
  String get displayName => login ?? phone ?? id;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'].toString(),
      // Anything unrecognised is treated as an ordinary user. Guessing "admin"
      // from an unexpected string is the one wrong way to be wrong here.
      role: json['role'] == 'admin' ? UserRole.admin : UserRole.user,
      login: json['login'] as String?,
      phone: json['phone'] as String?,
    );
  }
}

/// Why a sign-in or sign-up attempt failed, in terms the UI can translate.
///
/// The server's English message is never shown as-is: the app runs in three
/// languages and «Invalid credentials» is not one of them.
enum AuthFailure {
  invalidCredentials,

  /// Registration was sent something that is neither an email address nor a
  /// phone number. Kept apart from [invalidCredentials] because on the sign-up
  /// form "wrong password" would be nonsense — there is no account yet.
  invalidIdentifier,

  /// The confirmation code did not match.
  invalidCode,

  /// The code has expired, or too many wrong ones were tried and the attempt
  /// was discarded. Either way the answer is the same: ask for a new one.
  codeExpired,

  accountExists,
  tooManyAttempts,
  network,
  unknown,
}

/// Thrown by AuthRepository; carries an [AuthFailure] the UI maps to a string.
class AuthException implements Exception {
  const AuthException(this.failure);

  final AuthFailure failure;

  @override
  String toString() => 'AuthException($failure)';
}
