import 'package:flutter/material.dart';

/// Card-shaped grid cell for the two-column make grid.
///
/// Carries the same contract as [CatalogListTile] — 18 sp title, accent
/// (#F5A623) check when selected — but lays out as a tappable card instead of
/// a full-width row.
///
/// Height is not decided here: the grid delegate sizes every cell in a row
/// identically, so the caller owns the text-scale arithmetic and the card just
/// fills what it is given.
class CatalogGridTile extends StatelessWidget {
  const CatalogGridTile({
    super.key,
    required this.title,
    this.isSelected = false,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF2A2D36),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFF5A623)
                  : const Color(0xFF3D4050),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                if (isSelected) ...[
                  const Icon(Icons.check, color: Color(0xFFF5A623), size: 20),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    // Two lines cover every make in the catalogue at the
                    // default scale («Alfa Romeo», «Great Wall»); past that the
                    // grid drops to one column and width stops being tight.
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
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
