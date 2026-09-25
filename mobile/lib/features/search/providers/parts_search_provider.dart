import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/vendor_result.dart';
import 'categories_provider.dart';
import 'search_params.dart';

part 'parts_search_provider.g.dart';

/// Returns search results for the current [SearchParams].
///
/// Returns [] immediately when params are null (no submit yet — D-03).
/// On submit, calls SearchApi.searchParts with the submitted PartsQuery.
@riverpod
Future<List<VendorResult>> partsSearch(Ref ref) async {
  final params = ref.watch(searchParamsProvider);
  if (params == null) return [];

  final api = ref.watch(searchApiProvider);
  return api.searchParts(
    lat: params.lat,
    lng: params.lng,
    radius: params.radius,
    makeId: params.makeId,
    modelId: params.modelId,
    generationId: params.generationId,
    categoryId: params.categoryId,
    query: params.query,
    year: params.year,
  );
}
