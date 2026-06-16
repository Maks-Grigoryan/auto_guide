import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../car_selector/state/selected_car_notifier.dart';

/// HomeStub — minimal home screen for Phase 2.
///
/// Shows a "Выбрать авто" button when no car is selected, or a tappable
/// chip showing the selected car when one has been confirmed (SEL-04).
/// Full home screen with search results is Phase 3.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCar = ref.watch(selectedCarNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1C1F26),
      appBar: AppBar(
        title: const Text('Авто-агрегатор'),
        backgroundColor: const Color(0xFF2A2D36),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (selectedCar == null) ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5A623),
                    foregroundColor: const Color(0xFF1C1F26),
                    minimumSize: const Size(double.infinity, 56),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => context.push('/selector/make'),
                  child: const Text('Выбрать авто'),
                ),
              ] else ...[
                _CarChip(
                  label: _buildChipLabel(selectedCar),
                  onTap: () => context.push('/selector/make'),
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                'Поиск запчастей и сервисов появится в следующей версии',
                style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildChipLabel(dynamic car) {
    // car is SelectedCar
    final base = '${car.makeName} ${car.modelName}';
    if (car.generationLabel != null) {
      return '$base · ${car.generationLabel}';
    }
    return '$base · Поколение не указано';
  }
}

class _CarChip extends StatelessWidget {
  const _CarChip({required this.label, required this.onTap});

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
