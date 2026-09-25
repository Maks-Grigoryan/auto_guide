import 'package:dio/dio.dart';

import '../models/part_category.dart';
import '../models/service_category.dart';
import '../models/vendor_detail.dart';
import '../models/vendor_result.dart';
import 'dio_client.dart';

/// Client for the search and catalog endpoints.
///
/// Pitfall-3 guard: lat is sent FIRST, lng second — matching the DTO
/// parameter order in SearchPartsDto / SearchRepairDto (lat, lng, radius, ...).
/// Do NOT swap to (lng, lat); PostGIS will silently reverse the coordinate.
/// This applies to BOTH searchParts and searchRepair.
///
/// D-03 note: OEM space/dash normalisation lives ENTIRELY in the SQL function
/// (server-side). This client sends the raw query string as typed by the user.
class SearchApi {
  SearchApi({Dio? dio}) : _dio = dio ?? createDioClient();

  final Dio _dio;

  /// Loads the canonical detail record used by deep-linked vendor pages.
  Future<VendorDetail> fetchVendor(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/vendors/$id');
    return VendorDetail.fromJson(response.data ?? const {});
  }

  /// Fetches the flat list of part categories, named in [lang].
  ///
  /// GET /catalog/part-categories?lang=…
  /// Returns: [{ id, name, parent_id }]
  ///
  /// The names live in the database, so the language has to travel with the
  /// request. Translating them client-side would mean hard-coding the Russian
  /// spellings here and losing a category's translation, silently, the moment
  /// anyone renamed it.
  Future<List<PartCategory>> fetchCategories({String? lang}) async {
    final response = await _dio.get<List<dynamic>>(
      '/catalog/part-categories',
      queryParameters: {if (lang != null) 'lang': lang},
    );
    final data = response.data ?? [];
    return data
        .cast<Map<String, dynamic>>()
        .map(PartCategory.fromJson)
        .toList(growable: false);
  }

  /// Fetches the flat list of service categories, named in [lang].
  ///
  /// GET /catalog/service-categories?lang=…
  /// Returns: [{ id, name }]
  Future<List<ServiceCategory>> fetchServiceCategories({String? lang}) async {
    final response = await _dio.get<List<dynamic>>(
      '/catalog/service-categories',
      queryParameters: {if (lang != null) 'lang': lang},
    );
    final data = response.data ?? [];
    return data
        .cast<Map<String, dynamic>>()
        .map(ServiceCategory.fromJson)
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
  ///   [year]         – optional year of manufacture; narrows by fitment range
  Future<List<VendorResult>> searchParts({
    required double lat,
    required double lng,
    required int radius,
    int? makeId,
    int? modelId,
    int? generationId,
    int? categoryId,
    String? query,
    int? year,
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
      // Omitted rather than sent as null when unset: the endpoint reads an
      // absent year as "no filter", and an explicit null would fail validation.
      if (year != null) 'year': year,
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

  /// Searches for repair shops offering the given service near [lat]/[lng].
  ///
  /// GET /search/repair
  ///
  /// Parameters:
  ///   [lat]               – search origin latitude (sent first; Pitfall-3)
  ///   [lng]               – search origin longitude (sent second)
  ///   [radius]            – radius in metres
  ///   [serviceCategoryId] – optional service-category filter
  Future<List<VendorResult>> searchRepair({
    required double lat,
    required double lng,
    required int radius,
    int? serviceCategoryId,
  }) async {
    final queryParams = <String, dynamic>{
      'lat': lat,
      'lng': lng,
      'radius': radius,
      if (serviceCategoryId != null) 'serviceCategoryId': serviceCategoryId,
    };

    final response = await _dio.get<List<dynamic>>(
      '/search/repair',
      queryParameters: queryParams,
    );
    final data = response.data ?? [];
    return data
        .cast<Map<String, dynamic>>()
        .map(VendorResult.fromJson)
        .toList(growable: false);
  }
}
