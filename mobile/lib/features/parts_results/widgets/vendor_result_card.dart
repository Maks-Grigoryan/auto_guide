import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/vendor_result.dart';
import '../../../l10n/l10n.dart';
import 'distance_badge.dart';

/// Card displaying a single vendor result in the search results list.
///
/// Spec (03-UI-SPEC VendorResultCard):
///   Card/InkWell fill #2A2D36, radius 12, md (16 dp) padding, min height 88 dp
///   whole card tappable (detail Phase 5 — no-op this phase)
///   DistanceBadge top-right
///   shop name 18 sp #FFFFFF max 2 lines ellipsis
///   shop type 16 sp #E0E0E0
///   min price: Icons.sell_outlined + "от {amount} ₽" — omit row when null
///
/// Repair parameterization (vendor.type == 'repair_shop'):
///   count icon: Icons.build_outlined (instead of Icons.inventory_2_outlined)
///   count plural: «{n} услуга/услуги/услуг» (instead of «{n} позиция/позиции/позиций»)
///   minPrice null-omit logic: identical — reused unchanged
class VendorResultCard extends StatelessWidget {
  const VendorResultCard({super.key, required this.vendor});

  final VendorResult vendor;

  bool get _isRepair => vendor.type == 'repair_shop';

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2A2D36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.push('/vendor/${vendor.vendorId}'),
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
                  _typeLabel(context),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFFE0E0E0),
                  ),
                ),
                const SizedBox(height: 8),
                // Metrics row: min price (optional) + count
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    if (vendor.minPrice != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.sell_outlined,
                            size: 16,
                            color: Color(0xFFE0E0E0),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              context.l10n.priceFromAmd(
                                vendor.minPrice!.round(),
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isRepair
                              ? Icons.build_outlined
                              : Icons.inventory_2_outlined,
                          size: 16,
                          color: const Color(0xFFE0E0E0),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _isRepair
                                ? context.l10n.serviceCount(vendor.itemCount)
                                : context.l10n.itemCount(vendor.itemCount),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFFE0E0E0),
                            ),
                          ),
                        ),
                      ],
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

  String _typeLabel(BuildContext context) => switch (vendor.type) {
        'repair_shop' => context.l10n.repairShop,
        'parts_shop' => context.l10n.partsShop,
        _ => vendor.type,
      };
}
