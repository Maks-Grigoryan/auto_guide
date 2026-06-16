import 'package:flutter/material.dart';

/// Reusable error state widget for async list screens.
///
/// Displays icon + screen-specific heading + generic body + retry TextButton.
/// Never exposes raw exceptions or stack traces to the user (T-02-08 mitigation).
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.heading,
    required this.onRetry,
    this.icon = Icons.wifi_off,
  });

  /// Screen-specific error heading, e.g. "Не удалось загрузить марки".
  final String heading;

  /// Called when the user taps "Повторить" — should trigger ref.refresh().
  final VoidCallback onRetry;

  /// Icon to display (48 dp). Defaults to [Icons.wifi_off].
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 48 dp icon — accessibility tap target not needed here (icon is
            // decorative; only the TextButton is interactive).
            Icon(icon, size: 48, color: const Color(0xFFE0E0E0)),
            const SizedBox(height: 16),
            Text(
              heading,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Проверьте подключение и попробуйте снова',
              style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // ≥48 dp tap target via TextButton default padding
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'Повторить',
                style: TextStyle(
                  color: Color(0xFFF5A623),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
