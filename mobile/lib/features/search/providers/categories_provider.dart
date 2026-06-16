import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/search_api.dart';
import '../../../core/models/part_category.dart';

part 'categories_provider.g.dart';

@riverpod
SearchApi searchApi(Ref ref) => SearchApi();

/// Fetches the flat list of part categories from GET /catalog/part-categories.
@riverpod
Future<List<PartCategory>> categories(Ref ref) async {
  final api = ref.watch(searchApiProvider);
  return api.fetchCategories();
}
