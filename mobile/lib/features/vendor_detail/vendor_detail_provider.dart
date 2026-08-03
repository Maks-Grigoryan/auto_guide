import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/vendor_detail.dart';
import '../search/providers/categories_provider.dart';

final vendorDetailProvider =
    FutureProvider.autoDispose.family<VendorDetail, String>((ref, id) {
  final api = ref.watch(searchApiProvider);
  return api.fetchVendor(id);
});
