import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/vendor_result.dart';
import '../../../l10n/l10n.dart';
import 'distance_badge.dart';

/// Bottom-sheet summary card shown when a map marker is tapped (D-03).
///
/// UI-SPEC Surface 3:
///   Container bg #2A2D36, top radius 16, drag handle 4 dp #3D4050, SafeArea.
///   Reuses VendorResultCard content: name 18 sp #FFFFFF (2-line), type 16 sp
///   #E0E0E0, DistanceBadge, min price (omit when null), item/service count.
///   Whole-card InkWell routes to the full /vendor/:id detail screen (D-03).
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

          // Card content — tappable, routes to the vendor detail screen.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: InkWell(
              onTap: () {
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
                        _typeLabel(context),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFFE0E0E0),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Metrics row: min price (optional) + count.
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
                                Text(
                                  context.l10n.priceFromAmd(
                                    vendor.minPrice!.round(),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFE0E0E0),
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
                              Text(
                                _isRepair
                                    ? context.l10n.serviceCount(
                                        vendor.itemCount,
                                      )
                                    : context.l10n.itemCount(vendor.itemCount),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFFE0E0E0),
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
          ),
        ],
      ),
    );
  }

  String _typeLabel(BuildContext context) => switch (vendor.type) {
        'repair_shop' => context.l10n.repairShop,
        'parts_shop' => context.l10n.partsShop,
        _ => vendor.type,
      };
}

/// Shows a partial-height modal bottom sheet with [VendorSummarySheet] for the
/// given [vendor]. The map stays visible behind the sheet (D-03).
///
/// Lives here rather than next to a map implementation so that both the native
/// MapKit view and the web JS API view raise the identical sheet.
void showVendorSheet(BuildContext context, VendorResult vendor) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF2A2D36),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => VendorSummarySheet(vendor: vendor),
  );
}
