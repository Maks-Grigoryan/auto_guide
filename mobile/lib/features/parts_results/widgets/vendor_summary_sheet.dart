import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/vendor_result.dart';
import 'distance_badge.dart';

/// Russian plural for "позиция" based on the count (parts path).
String _ruItemCount(int n) {
  final mod10 = n % 10;
  final mod100 = n % 100;
  if (mod100 >= 11 && mod100 <= 19) return '$n позиций';
  if (mod10 == 1) return '$n позиция';
  if (mod10 >= 2 && mod10 <= 4) return '$n позиции';
  return '$n позиций';
}

/// Russian plural for "услуга" based on the count (repair path).
String _ruServiceCount(int n) {
  final mod10 = n % 10;
  final mod100 = n % 100;
  if (mod100 >= 11 && mod100 <= 19) return '$n услуг';
  if (mod10 == 1) return '$n услуга';
  if (mod10 >= 2 && mod10 <= 4) return '$n услуги';
  return '$n услуг';
}

/// Bottom-sheet summary card shown when a map marker is tapped (D-03).
///
/// UI-SPEC Surface 3:
///   Container bg #2A2D36, top radius 16, drag handle 4 dp #3D4050, SafeArea.
///   Reuses VendorResultCard content: name 18 sp #FFFFFF (2-line), type 16 sp
///   #E0E0E0, DistanceBadge, min price (omit when null), item/service count.
///   Whole-card InkWell routes toward Phase 5 /vendor/:id stub (D-03).
///
/// Repair parameterization: vendor.type == 'repair_shop' → service count icon
/// Icons.build_outlined and plural «{n} услуга/услуги/услуг»; min price row
/// omitted when null (identical logic to VendorResultCard).
class VendorSummarySheet extends StatelessWidget {
  const VendorSummarySheet({super.key, required this.vendor});

  final VendorResult vendor;

  bool get _isRepair => vendor.type == 'repair_shop';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle (4 dp, #3D4050, centered, sm top margin).
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF3D4050),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Card content — tappable, routes to /vendor/:id (Phase 5 hook).
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: InkWell(
              onTap: () {
                // Phase 5 boundary: route to reserved /vendor/:id stub.
                context.push('/vendor/${vendor.vendorId}');
              },
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 88),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Row: shop name (flex) + distance badge (top-right).
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              vendor.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFFFFFFFF),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          DistanceBadge(distanceM: vendor.distanceM),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Shop type.
                      Text(
                        vendor.type,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFFE0E0E0),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Metrics row: min price (optional) + count.
                      Row(
                        children: [
                          if (vendor.minPrice != null) ...[
                            const Icon(
                              Icons.sell_outlined,
                              size: 16,
                              color: Color(0xFFE0E0E0),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'от ${vendor.minPrice!.round()} ₽',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Icon(
                            _isRepair
                                ? Icons.build_outlined
                                : Icons.inventory_2_outlined,
                            size: 16,
                            color: const Color(0xFFE0E0E0),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isRepair
                                ? _ruServiceCount(vendor.itemCount)
                                : _ruItemCount(vendor.itemCount),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFFE0E0E0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
