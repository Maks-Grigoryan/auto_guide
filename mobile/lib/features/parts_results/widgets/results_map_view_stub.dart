import 'package:flutter/material.dart';

import '../../../core/models/vendor_result.dart';
import 'map_unavailable_notice.dart';

/// Fallback for platforms with neither dart:io nor dart:js_interop.
///
/// Never reached in practice: `mapAvailableProvider` is false on such a
/// platform, so the «Карта» segment is disabled and this widget is not built.
/// It exists to keep the conditional export resolvable.
class ResultsMapView extends StatelessWidget {
  const ResultsMapView({super.key, required this.vendors});

  final List<VendorResult> vendors;

  @override
  Widget build(BuildContext context) => const Center(
        child: MapUnavailableNotice(),
      );
}
