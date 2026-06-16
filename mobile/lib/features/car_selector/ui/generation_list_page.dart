import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/catalog_providers.dart';
import '../state/selected_car_notifier.dart';

class GenerationListPage extends ConsumerWidget {
  const GenerationListPage({super.key, required this.modelId});

  final int modelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generationsAsync = ref.watch(generationsProvider(modelId));

    // AppBar title: "{MakeName} {ModelName}" — read from confirmed state.
    // During the picker flow, state may be null (make/model not yet confirmed).
    // Use an empty fallback; Plan 03 will improve this with a proper in-progress
    // state object exposed on the notifier.
    final car = ref.watch(selectedCarNotifierProvider);
    final appBarTitle =
        car != null ? '${car.makeName} ${car.modelName}' : '';

    return Scaffold(
      backgroundColor: const Color(0xFF1C1F26),
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: const Color(0xFF2A2D36),
      ),
      body: SafeArea(
        child: generationsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFF5A623)),
          ),
          error: (error, _) => _ErrorView(
            heading: 'Не удалось загрузить поколения',
            onRetry: () => ref.refresh(generationsProvider(modelId)),
          ),
          data: (generations) {
            return ListView.builder(
              itemCount: generations.length + 1, // +1 for "Пропустить" row
              itemBuilder: (context, index) {
                // First row is always "Пропустить (поколение не важно)"
                if (index == 0) {
                  return Column(
                    children: [
                      ListTile(
                        minVerticalPadding: 8,
                        title: const Text(
                          'Пропустить (поколение не важно)',
                          style: TextStyle(
                            color: Color(0xFFF5A623),
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        onTap: () {
                          // Skip generation — navigate to confirm with null generationId
                          context.push('/selector/confirm');
                        },
                      ),
                      const Divider(
                        color: Color(0xFF3D4050),
                        thickness: 1.5,
                      ),
                    ],
                  );
                }

                final gen = generations[index - 1];
                final id = gen['id'] as int;
                final name = gen['name'] as String;
                final yearFrom = gen['year_from'] as int?;
                final yearTo = gen['year_to'] as int?;

                final yearSubtitle = _buildYearSubtitle(yearFrom, yearTo);

                return Column(
                  children: [
                    ListTile(
                      minVerticalPadding: 8,
                      title: Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: yearSubtitle != null
                          ? Text(
                              yearSubtitle,
                              style: const TextStyle(
                                color: Color(0xFFE0E0E0),
                                fontSize: 16,
                              ),
                            )
                          : null,
                      onTap: () {
                        ref
                            .read(selectedCarNotifierProvider.notifier)
                            .pickGeneration(id, name);
                        context.push('/selector/confirm');
                      },
                    ),
                    if (index < generations.length)
                      const Divider(
                        color: Color(0xFF3D4050),
                        indent: 16,
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  String? _buildYearSubtitle(int? yearFrom, int? yearTo) {
    if (yearFrom != null && yearTo != null) return '$yearFrom–$yearTo';
    if (yearFrom != null) return 'с $yearFrom';
    return null;
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.heading, required this.onRetry});

  final String heading;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: Color(0xFFE0E0E0)),
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
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'Повторить',
                style: TextStyle(color: Color(0xFFF5A623), fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
