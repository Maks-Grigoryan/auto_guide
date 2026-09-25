import 'package:flutter/material.dart';

const _card = Color(0xFF2A2D36);
const _accent = Color(0xFFF5A623);
const _outline = Color(0xFF3D4050);
const _surface = Color(0xFF1C1F26);
const _textSecondary = Color(0xFFE0E0E0);
const _textDisabled = Color(0xFF6B7280);

/// One choice in a [SegmentedToggle].
class SegmentedToggleItem {
  const SegmentedToggleItem({required this.label, this.enabled = true});

  final String label;

  /// A segment that exists but cannot be chosen — «Карта» with no map key.
  final bool enabled;
}

/// Two-or-more-way switch where the chosen segment is filled edge to edge.
///
/// Replaces Material's SegmentedButton, which took its selected fill from
/// `colorScheme.secondaryContainer` — in this app's palette that is #2A2D36,
/// all but identical to the track behind it, so the choice was nearly
/// invisible and its fill did not follow the rounded frame.
///
/// Selection is never signalled by colour alone (ACC-02): the chosen segment
/// also carries a check mark, is the only one in semibold, and is flagged
/// `selected` to screen readers.
class SegmentedToggle extends StatelessWidget {
  const SegmentedToggle({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onSelected,
    this.height = 48,
    this.enabled = true,
  });

  final List<SegmentedToggleItem> segments;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// 48 is the smallest comfortable tap target and the app's default; the
  /// sign-in screen uses 56 to sit with its taller fields.
  final double height;

  /// Turns the whole control inert without changing how it reads.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _outline),
      ),
      // The inset is what lets the selected fill be a rounded rectangle inside
      // a rounded frame, instead of a square block clipped by it.
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          for (var i = 0; i < segments.length; i++)
            Expanded(
              child: _Segment(
                item: segments[i],
                active: i == selectedIndex,
                enabled: enabled && segments[i].enabled,
                onTap: () => onSelected(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.item,
    required this.active,
    required this.enabled,
    required this.onTap,
  });

  final SegmentedToggleItem item;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color foreground;
    if (active) {
      foreground = _surface;
    } else if (enabled) {
      foreground = _textSecondary;
    } else {
      foreground = _textDisabled;
    }

    return Semantics(
      button: true,
      selected: active,
      enabled: enabled,
      child: Material(
        color: active ? _accent : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: enabled ? onTap : null,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (active) ...[
                  Icon(Icons.check, size: 18, color: foreground),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    item.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 17,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
