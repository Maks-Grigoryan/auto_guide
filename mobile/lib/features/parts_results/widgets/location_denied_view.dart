import 'package:flutter/material.dart';

/// Non-blocking notice shown when location permission is denied (RES-06/RES-07).
///
/// Explains Yerevan fallback and provides recovery action.
/// Shows "Повторить" for re-requestable denial, "Открыть настройки" for deniedForever.
/// This widget is non-blocking — results still render below it.
class LocationDeniedView extends StatelessWidget {
  const LocationDeniedView({
    super.key,
    required this.isPermanent,
    required this.onRetry,
    required this.onOpenSettings,
  });

  /// True when permission is deniedForever (Android) — re-prompt impossible.
  final bool isPermanent;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2A2D36),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_off, size: 24, color: Color(0xFFE0E0E0)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Геолокация выключена',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Чтобы показать ближайшие магазины, разрешите доступ к местоположению. '
                  'Пока показываем результаты для центра Еревана.',
                  style: TextStyle(fontSize: 16, color: Color(0xFFE0E0E0)),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 56,
                  child: isPermanent
                      ? TextButton(
                          onPressed: onOpenSettings,
                          child: const Text(
                            'Открыть настройки',
                            style: TextStyle(
                              color: Color(0xFFF5A623),
                              fontSize: 16,
                            ),
                          ),
                        )
                      : TextButton(
                          onPressed: onRetry,
                          child: const Text(
                            'Повторить',
                            style: TextStyle(
                              color: Color(0xFFF5A623),
                              fontSize: 16,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
