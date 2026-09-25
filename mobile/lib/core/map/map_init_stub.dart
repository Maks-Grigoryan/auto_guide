/// Fallback implementation for platforms with neither dart:io nor
/// dart:js_interop. Reports "no map available" so callers degrade to the
/// list-only path (D-04) instead of failing to compile.
Future<bool> initMapSdk() async => false;
