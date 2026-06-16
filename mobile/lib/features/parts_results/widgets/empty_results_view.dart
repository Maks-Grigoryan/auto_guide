import 'package:flutter/material.dart';

/// Shown when the search returns an empty list (RES-07 empty state).
///
/// Uses icon + heading + body — never color alone (ACC-02).
class EmptyResultsView extends StatelessWidget {
  const EmptyResultsView({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 48, color: Color(0xFFE0E0E0)),
            const SizedBox(height: 16),
            const Text(
              'Ничего не найдено',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Поблизости нет магазинов с этой деталью. Попробуйте другую категорию.',
              style: TextStyle(fontSize: 16, color: Color(0xFFE0E0E0)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: onBack,
              child: const Text(
                'Назад к категориям',
                style: TextStyle(color: Color(0xFFF5A623), fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
