import 'package:dio/dio.dart';

import '../models/part_category.dart';
import '../models/vendor_result.dart';
import 'dio_client.dart';

/// Client for the search and catalog endpoints.
///
/// Pitfall-3 guard: lat is sent FIRST, lng second — matching the DTO
/// parameter order in SearchPartsDto (lat, lng, radius, ...).
/// Do NOT swap to (lng, lat); PostGIS will silently reverse the coordinate.
///
/// D-03 note: OEM space/dash normalisation lives ENTIRELY in the SQL function
/// (server-side). This client sends the raw query string as typed by the user.
class SearchApi {
  SearchApi({Dio? dio}) : _dio = dio ?? createDioClient();

  final Dio _dio;

  /// Fetches the flat list of part categories.
  ///
  /// GET /catalog/part-categories
  /// Returns: [{ id, name, parent_id }]
  Future<List<PartCategory>> fetchCategories() async {
    final response = await _dio.get<List<dynamic>>('/catalog/part-categories');
    final data = response.data ?? [];
    return data
        .cast<Map<String, dynamic>>()
        .map(PartCategory.fromJson)
        .toList(growable: false);
  }

  /// Searches for vendors stocking compatible parts near [lat]/[lng].
  ///
  /// GET /search/parts
  ///
  /// Parameters:
  ///   [lat]          – search origin latitude (sent first; Pitfall-3)
  ///   [lng]          – search origin longitude (sent second)
  ///   [radius]       – radius in metres (default 5000 recommended)
  ///   [makeId]       – optional car make filter
  ///   [modelId]      – optional car model filter
  ///   [generationId] – optional car generation filter
  ///   [categoryId]   – optional part-category filter
  ///   [query]        – optional text query (OEM / name); sent as-is (D-03)
  Future<List<VendorResult>> searchParts({
    required double lat,
    required double lng,
    required int radius,
    int? makeId,
    int? modelId,
    int? generationId,
    int? categoryId,
    String? query,
  }) async {
    final queryParams = <String, dynamic>{
      'lat': lat,
      'lng': lng,
      'radius': radius,
      if (makeId != null) 'makeId': makeId,
      if (modelId != null) 'modelId': modelId,
      if (generationId != null) 'generationId': generationId,
      if (categoryId != null) 'categoryId': categoryId,
      if (query != null && query.isNotEmpty) 'query': query,
    };

    final response = await _dio.get<List<dynamic>>(
      '/search/parts',
      queryParameters: queryParams,
    );
    final data = response.data ?? [];
    return data
        .cast<Map<String, dynamic>>()
        .map(VendorResult.fromJson)
        .toList(growable: false);
  }
}
