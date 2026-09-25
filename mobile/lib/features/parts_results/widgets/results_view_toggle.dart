import 'package:flutter/material.dart';

import '../../../core/widgets/segmented_toggle.dart';
import '../../../l10n/l10n.dart';

/// List⇄map segmented toggle for the results screen.
///
/// Renders «Список» (index 0) and «Карта» (index 1) at 48 dp height,
/// mirroring the SearchTypeToggle pattern.
///
/// D-04: when [mapAvailable] is false the «Карта» segment is disabled
/// (non-tappable) and [onSelectionChanged] is set to null so the control
/// is fully inert. Callers should render a [MapUnavailableNotice] below.
class ResultsViewToggle extends StatelessWidget {
  const ResultsViewToggle({
    super.key,
    required this.selectedIndex,
    required this.mapAvailable,
    required this.onListSelected,
    required this.onMapSelected,
  });

  /// 0 = Список (default), 1 = Карта.
  final int selectedIndex;

  /// When false the «Карта» segment is disabled and selection is locked
  /// on «Список» (D-04 graceful degradation).
  final bool mapAvailable;

  final VoidCallback onListSelected;
  final VoidCallback onMapSelected;

  @override
  Widget build(BuildContext context) {
    return SegmentedToggle(
      selectedIndex: selectedIndex,
      // D-04: with no map key the whole control is inert, and «Карта» reads as
      // disabled rather than merely doing nothing when tapped.
      enabled: mapAvailable,
      segments: [
        SegmentedToggleItem(label: context.l10n.list),
        SegmentedToggleItem(label: context.l10n.map, enabled: mapAvailable),
      ],
      onSelected: (index) {
        if (index == 0) {
          onListSelected();
        } else {
          onMapSelected();
        }
      },
    );
  }
}
