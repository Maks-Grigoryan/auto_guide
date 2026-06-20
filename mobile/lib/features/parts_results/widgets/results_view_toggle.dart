import 'package:flutter/material.dart';

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
    return SizedBox(
      height: 48,
      child: SegmentedButton<int>(
        segments: [
          const ButtonSegment<int>(value: 0, label: Text('Список')),
          ButtonSegment<int>(
            value: 1,
            label: const Text('Карта'),
            enabled: mapAvailable,
          ),
        ],
        selected: {selectedIndex},
        // D-04: null onSelectionChanged makes the entire control inert when
        // the map is unavailable — prevents any segment from being tapped.
        onSelectionChanged: mapAvailable
            ? (Set<int> s) {
                if (s.first == 0) {
                  onListSelected();
                } else {
                  onMapSelected();
                }
              }
            : null,
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size(0, 48)),
        ),
      ),
    );
  }
}
