import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/search_api.dart';
import '../../../core/models/part_category.dart';
import '../../../l10n/locale_provider.dart';

part 'categories_provider.g.dart';

@riverpod
SearchApi searchApi(Ref ref) => SearchApi();

/// Fetches the flat list of part categories from GET /catalog/part-categories.
///
/// Watches the locale rather than reading it once: category names come from
/// the server, so switching language has to re-fetch them. Without the watch,
/// the chrome changed language and the list underneath stayed in Russian.
@riverpod
Future<List<PartCategory>> categories(Ref ref) async {
  final api = ref.watch(searchApiProvider);
  final locale = ref.watch(appLocaleProvider);
  return api.fetchCategories(lang: locale.languageCode);
}
