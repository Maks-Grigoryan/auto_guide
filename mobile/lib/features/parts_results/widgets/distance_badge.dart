import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';

/// Amber distance badge shown top-right on each VendorResultCard.
///
/// Spec (03-UI-SPEC VendorResultCard):
///   fill #F5A623, radius 8, xs padding (4 dp)
///   Icons.place 16 dp #1C1F26 + distance text 16 sp SemiBold #1C1F26
///   format: < 1000 m → "{N} м"; ≥ 1000 m → "{N.N} км" (one decimal)
///
/// Status is communicated by icon + text, never color alone (ACC-02).
class DistanceBadge extends StatelessWidget {
  const DistanceBadge({super.key, required this.distanceM});

  /// Distance in metres.
  final double distanceM;

  String _label(BuildContext context) {
    if (distanceM < 1000) {
      return context.l10n.distanceMeters(distanceM.round());
    }
    return context.l10n.distanceKilometers(
      (distanceM / 1000).toStringAsFixed(1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5A623),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.place, size: 16, color: Color(0xFF1C1F26)),
          const SizedBox(width: 2),
          Text(
            _label(context),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1F26),
            ),
          ),
        ],
      ),
    );
  }
}
