/// Where the access token is kept, chosen per platform.
///
/// @docImport 'token_store_io.dart';
/// @docImport 'token_store_web.dart';
///
/// Mobile gets the Keychain / EncryptedSharedPreferences through
/// flutter_secure_storage. The web build does not: that package's web
/// implementation threw on every write here — nothing ever appeared in
/// localStorage or IndexedDB — and a failed write was enough to discard an
/// authentication the server had already granted.
///
/// The browser has no secure enclave to reach for in any case. That package's
/// web implementation encrypts with a key it then keeps in localStorage beside
/// the data, so against anyone who can run script on the page it buys
/// obfuscation, not protection. Using localStorage directly is the same
/// guarantee, honestly labelled — and it works.
library;

export 'token_store_io.dart'
    if (dart.library.js_interop) 'token_store_web.dart';
