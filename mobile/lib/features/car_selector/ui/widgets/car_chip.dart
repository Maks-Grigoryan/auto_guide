import 'package:flutter/material.dart';

/// Tappable car chip shown on HomeStub once a car is selected.
///
/// Displays [Icons.directions_car] + label text — status is conveyed by
/// BOTH icon AND text, never color alone (UI-SPEC §Accessibility Contract,
/// REQUIREMENTS.md ACC-02).
/// Background: accent #F5A623; label color: #1C1F26 (contrast 4.7:1).
/// Height: 56 dp (primary-entry-point tap target).
class CarChip extends StatelessWidget {
  const CarChip({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5A623),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.directions_car,
              color: Color(0xFF1C1F26),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1C1F26),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.edit,
              color: Color(0xFF1C1F26),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
