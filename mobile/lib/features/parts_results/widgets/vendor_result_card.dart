import 'package:flutter/material.dart';

import '../../../core/models/vendor_result.dart';
import 'distance_badge.dart';

/// Russian plural for "позиция" based on the count.
String _ruItemCount(int n) {
  final mod10 = n % 10;
  final mod100 = n % 100;
  if (mod100 >= 11 && mod100 <= 19) return '$n позиций';
  if (mod10 == 1) return '$n позиция';
  if (mod10 >= 2 && mod10 <= 4) return '$n позиции';
  return '$n позиций';
}

/// Card displaying a single vendor result in the parts-search results list.
///
/// Spec (03-UI-SPEC VendorResultCard):
///   Card/InkWell fill #2A2D36, radius 12, md (16 dp) padding, min height 88 dp
///   whole card tappable (detail Phase 5 — no-op this phase)
///   DistanceBadge top-right
///   shop name 18 sp #FFFFFF max 2 lines ellipsis
///   shop type 16 sp #E0E0E0
///   min price: Icons.sell_outlined + "от {amount} ₽" — omit row when null
///   item count: Icons.inventory_2_outlined + RU plural
class VendorResultCard extends StatelessWidget {
  const VendorResultCard({super.key, required this.vendor});

  final VendorResult vendor;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2A2D36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          // Detail screen is Phase 5 — no-op for now.
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
                // Row: shop name (flex) + distance badge (top-right)
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
                // Shop type
                Text(
                  vendor.type,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFFE0E0E0),
                  ),
                ),
                const SizedBox(height: 8),
                // Metrics row: min price (optional) + item count
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
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 16,
                      color: Color(0xFFE0E0E0),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _ruItemCount(vendor.itemCount),
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
    );
  }
}
