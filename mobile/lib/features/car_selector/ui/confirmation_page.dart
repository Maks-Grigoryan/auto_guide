import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/selected_car_notifier.dart';

class ConfirmationPage extends ConsumerWidget {
  const ConfirmationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The notifier holds the in-progress selection; state may be null during
    // first-time flow (user hasn't confirmed yet). Read the notifier directly.
    final notifier = ref.read(selectedCarNotifierProvider.notifier);
    final car = ref.watch(selectedCarNotifierProvider);

    // If state is null and there's no in-progress selection yet, fall back to
    // placeholder strings. Plan 03 will expose the in-progress object properly.
    final makeName = car?.makeName ?? '—';
    final modelName = car?.modelName ?? '—';
    final generationLabel = car?.generationLabel ?? 'Не указано';

    return Scaffold(
      backgroundColor: const Color(0xFF1C1F26),
      appBar: AppBar(
        title: const Text('Ваше авто'),
        backgroundColor: const Color(0xFF2A2D36),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: const Color(0xFF2A2D36),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _ConfirmationRow(
                        label: 'Марка',
                        value: makeName,
                        onTap: () => context.push('/selector/make'),
                      ),
                      const Divider(color: Color(0xFF3D4050)),
                      _ConfirmationRow(
                        label: 'Модель',
                        value: modelName,
                        onTap: () {
                          // Navigate back to model picker; makeId is not
                          // available on the confirmed state when null, so
                          // fall back to make picker (cascade reset anyway).
                          if (car != null) {
                            context.push(
                              '/selector/model',
                              extra: car.makeId,
                            );
                          } else {
                            context.push('/selector/make');
                          }
                        },
                      ),
                      const Divider(color: Color(0xFF3D4050)),
                      _ConfirmationRow(
                        label: 'Поколение',
                        value: generationLabel,
                        onTap: () {
                          if (car != null) {
                            context.push(
                              '/selector/generation',
                              extra: car.modelId,
                            );
                          } else {
                            context.push('/selector/make');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
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
                onPressed: () {
                  notifier.confirm();
                  context.go('/');
                },
                child: const Text('Подтвердить выбор'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmationRow extends StatelessWidget {
  const _ConfirmationRow({
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
      trailing: const Icon(Icons.edit, size: 20, color: Color(0xFFF5A623)),
      onTap: onTap,
    );
  }
}
