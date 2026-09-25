import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/service_category.dart';
import '../../../l10n/locale_provider.dart';
import 'categories_provider.dart'; // for searchApiProvider

part 'service_categories_provider.g.dart';

/// Fetches the flat list of service categories from GET /catalog/service-categories.
///
/// Does NOT redefine searchApiProvider — imports it from categories_provider.dart.
///
/// Watches the locale for the same reason as the part categories: these names
/// are server data, so a language switch has to re-fetch them rather than
/// leaving «Двигатель и КПП» sitting under an Armenian heading.
@riverpod
Future<List<ServiceCategory>> serviceCategories(Ref ref) async {
  final api = ref.watch(searchApiProvider);
  final locale = ref.watch(appLocaleProvider);
  return api.fetchServiceCategories(lang: locale.languageCode);
}
