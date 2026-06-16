import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/selected_car_notifier.dart';
import 'widgets/confirmation_row.dart';

class ConfirmationPage extends ConsumerWidget {
  const ConfirmationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(selectedCarProvider.notifier);
    final car = ref.watch(selectedCarProvider);

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
                      ConfirmationRow(
                        label: 'Марка',
                        value: makeName,
                        onTap: () => context.push('/selector/make'),
                      ),
                      const Divider(color: Color(0xFF3D4050)),
                      ConfirmationRow(
                        label: 'Модель',
                        value: modelName,
                        onTap: () {
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
                      ConfirmationRow(
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
