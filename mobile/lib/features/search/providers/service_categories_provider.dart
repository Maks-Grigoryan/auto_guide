import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/service_category.dart';
import 'categories_provider.dart'; // for searchApiProvider

part 'service_categories_provider.g.dart';

/// Fetches the flat list of service categories from GET /catalog/service-categories.
///
/// Does NOT redefine searchApiProvider — imports it from categories_provider.dart.
@riverpod
Future<List<ServiceCategory>> serviceCategories(Ref ref) async {
  final api = ref.watch(searchApiProvider);
  return api.fetchServiceCategories();
}
