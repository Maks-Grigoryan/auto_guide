import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/vendor_result.dart';
import 'categories_provider.dart'; // for searchApiProvider
import 'repair_params.dart';

part 'repair_search_provider.g.dart';

/// Returns repair search results for the current [RepairParams].
///
/// Returns [] immediately when params are null (no submit yet).
/// On submit, calls SearchApi.searchRepair with the submitted RepairQuery.
@riverpod
Future<List<VendorResult>> repairSearch(Ref ref) async {
  final params = ref.watch(repairParamsProvider);
  if (params == null) return [];

  final api = ref.watch(searchApiProvider);
  return api.searchRepair(
    lat: params.lat,
    lng: params.lng,
    radius: params.radius,
    serviceCategoryId: params.serviceCategoryId,
  );
}
