import 'package:flutter/material.dart';

import '../../../core/models/part_category.dart';

/// Flat category list tile — 56dp min height, name 16sp, chevron trailing.
///
/// Tapping submits the [category] and navigates to /results/parts.
class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.category,
    required this.onTap,
  });

  final PartCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.category_outlined,
                    color: Color(0xFFE0E0E0),
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFFE0E0E0),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(
          color: Color(0xFF3D4050),
          thickness: 1,
          height: 1,
          indent: 16,
        ),
      ],
    );
  }
}
