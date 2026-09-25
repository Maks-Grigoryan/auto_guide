import 'package:flutter/material.dart';

/// Tappable 56 dp row for ConfirmationPage.
///
/// Label above the value, not beside it. Side by side, the label sat in the
/// tile's `leading` slot — a narrow fixed-width zone — and «Год выпуска» at a
/// 200% text scale (or «Year of manufacture» at any scale) could not fit it,
/// which failed layout outright rather than merely looking cramped. Stacked,
/// the row takes whatever height the text needs and survives every locale.
class ConfirmationRow extends StatelessWidget {
  const ConfirmationRow({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: 12,
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFE0E0E0),
          fontSize: 16,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      trailing: const Icon(
        Icons.edit,
        size: 20,
        color: Color(0xFFF5A623),
      ),
      onTap: onTap,
    );
  }
}
