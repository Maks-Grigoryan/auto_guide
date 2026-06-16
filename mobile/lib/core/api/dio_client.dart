import 'package:dio/dio.dart';

/// Typed exception surfaced by [ApiException].
///
/// The interceptor normalises all Dio errors into this type so the UI layer
/// never receives raw DioException objects (T-03-06: no stack traces to UI).
class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.message,
  });

  final int? statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Creates and returns the shared [Dio] instance with:
///  - base URL sourced from the compile-time environment (--dart-define)
///  - default timeouts
///  - error-normalisation interceptor
Dio createDioClient() {
  const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(_ErrorNormalizerInterceptor());

  return dio;
}

/// Interceptor that converts [DioException] into [ApiException].
///
/// Raw stack traces and server-internal messages are intentionally discarded
/// here; the UI only receives a user-friendly message string (T-03-06).
class _ErrorNormalizerInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final message = _extractMessage(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: ApiException(
          statusCode: err.response?.statusCode,
          message: message,
        ),
        type: err.type,
        response: err.response,
      ),
    );
  }

  String _extractMessage(DioException err) {
    if (err.response != null) {
      final data = err.response!.data;
      if (data is Map<String, dynamic>) {
        final msg = data['message'];
        if (msg is String && msg.isNotEmpty) return msg;
        if (msg is List && msg.isNotEmpty) return msg.first.toString();
      }
      return 'Server error (${err.response!.statusCode})';
    }
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Connection timed out. Check your internet connection.';
      case DioExceptionType.connectionError:
        return 'Could not reach the server. Check your internet connection.';
      default:
        return 'Unexpected network error.';
    }
  }
}
