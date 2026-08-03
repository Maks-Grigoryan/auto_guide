import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';

/// Segmented toggle: Запчасти (default) / Ремонт.
///
/// [onPartsSelected] is called when Запчасти is tapped.
/// [onRepairSelected] is called when Ремонт is tapped — callers open the
/// service-category search flow.
/// Height is 48dp (meets ≥48dp tap target requirement).
class SearchTypeToggle extends StatelessWidget {
  const SearchTypeToggle({
    super.key,
    required this.selectedIndex,
    required this.onPartsSelected,
    required this.onRepairSelected,
  });

  /// 0 = Запчасти, 1 = Ремонт.
  final int selectedIndex;
  final VoidCallback onPartsSelected;
  final VoidCallback onRepairSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: SegmentedButton<int>(
        segments: [
          ButtonSegment<int>(value: 0, label: Text(context.l10n.parts)),
          ButtonSegment<int>(value: 1, label: Text(context.l10n.repair)),
        ],
        selected: {selectedIndex},
        onSelectionChanged: (Set<int> newSelection) {
          final idx = newSelection.first;
          if (idx == 0) {
            onPartsSelected();
          } else {
            onRepairSelected();
          }
        },
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size(0, 48)),
        ),
      ),
    );
  }
}
