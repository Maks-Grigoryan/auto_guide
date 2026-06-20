import 'package:flutter/material.dart';

/// Non-blocking notice shown below the list⇄map toggle when the Yandex
/// MapKit key is missing or map initialisation failed (D-04).
///
/// UI-SPEC Surface 1 / Map graceful degradation:
///   fill #2A2D36, min height 48 dp, Icons.map_outlined + text «Карта
///   недоступна» 16 sp #E0E0E0 — icon+text, never color-only (ACC-02).
class MapUnavailableNotice extends StatelessWidget {
  const MapUnavailableNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Container(
        color: const Color(0xFF2A2D36),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: const Row(
          children: [
            Icon(
              Icons.map_outlined,
              color: Color(0xFFE0E0E0),
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Карта недоступна',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFE0E0E0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
