import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../l10n/locale_provider.dart';

part 'catalog_providers.g.dart';

// ---------------------------------------------------------------------------
// Base URL is injected at build time via --dart-define=API_BASE_URL.
// Default: Android emulator host (10.0.2.2 maps to the host's localhost).
// For iOS Simulator use 127.0.0.1; for physical device use the host LAN IP.
// (Pitfall 6 from RESEARCH.md)
// ---------------------------------------------------------------------------
const _defaultBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000',
);

@riverpod
Dio dio(Ref ref) {
  return Dio(BaseOptions(baseUrl: _defaultBaseUrl));
}

/// Fetches all car makes from GET /catalog/makes.
@riverpod
Future<List<Map<String, dynamic>>> makes(Ref ref) async {
  final client = ref.watch(dioProvider);
  final response = await client.get<List<dynamic>>('/catalog/makes');
  return (response.data as List).cast<Map<String, dynamic>>();
}

/// Fetches models for a given [makeId] from GET /catalog/models?makeId=...
@riverpod
Future<List<Map<String, dynamic>>> models(Ref ref, int makeId) async {
  final client = ref.watch(dioProvider);
  final response = await client.get<List<dynamic>>(
    '/catalog/models',
    queryParameters: {'makeId': makeId},
  );
  return (response.data as List).cast<Map<String, dynamic>>();
}

/// Fetches generations for a given [modelId] from GET /catalog/generations?modelId=...
@riverpod
Future<List<Map<String, dynamic>>> generations(Ref ref, int modelId) async {
  final client = ref.watch(dioProvider);
  // Generation labels are server data too — the seed named them «I поколение»
  // rather than with factory codes, so they need translating like the
  // categories do. Makes and models are left alone on purpose: «Toyota» and
  // «Camry» are proper nouns and read the same in every locale.
  final locale = ref.watch(appLocaleProvider);
  final response = await client.get<List<dynamic>>(
    '/catalog/generations',
    queryParameters: {'modelId': modelId, 'lang': locale.languageCode},
  );
  return (response.data as List).cast<Map<String, dynamic>>();
}
