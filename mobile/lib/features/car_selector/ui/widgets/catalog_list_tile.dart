import 'package:flutter/material.dart';

/// 56 dp [ListTile] for make / model / generation list rows.
///
/// When [isSelected] is true, shows an accent (#F5A623) leading check icon.
/// Title is 18 sp Regular. Optional [subtitle] is 16 sp Regular.
class CatalogListTile extends StatelessWidget {
  const CatalogListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.isSelected = false,
    required this.onTap,
    this.titleColor = Colors.white,
    this.titleStyle,
  });

  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  /// Override title color for special rows (e.g. "Пропустить" in accent).
  final Color titleColor;

  /// Full override of title TextStyle (titleColor is ignored when this is set).
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final resolvedTitleStyle = titleStyle ??
        TextStyle(
          color: titleColor,
          fontSize: 18,
          fontWeight: FontWeight.w400,
        );

    return ListTile(
      // Ensures ≥56 dp row height (UI-SPEC §Accessibility Contract).
      minVerticalPadding: 8,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: isSelected
          ? const Icon(Icons.check, color: Color(0xFFF5A623), size: 20)
          : null,
      title: Text(title, style: resolvedTitleStyle),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(
                color: Color(0xFFE0E0E0),
                fontSize: 16,
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
