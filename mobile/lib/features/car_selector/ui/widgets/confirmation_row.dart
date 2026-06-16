import 'package:flutter/material.dart';

/// Tappable 56 dp ListTile row for ConfirmationPage.
///
/// Shows a leading label (16 sp secondary), a value title (18 sp SemiBold),
/// and a trailing edit icon in accent (#F5A623).
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
      minVerticalPadding: 8,
      contentPadding: EdgeInsets.zero,
      leading: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFE0E0E0),
          fontSize: 16,
        ),
      ),
      title: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
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
