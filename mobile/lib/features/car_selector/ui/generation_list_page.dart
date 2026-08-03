import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/l10n.dart';

import '../data/catalog_providers.dart';
import '../state/selected_car_notifier.dart';
import 'widgets/async_state_view.dart';
import 'widgets/catalog_list_tile.dart';

class GenerationListPage extends ConsumerWidget {
  const GenerationListPage({super.key, required this.modelId});

  final int modelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generationsAsync = ref.watch(generationsProvider(modelId));

    final car = ref.watch(selectedCarProvider);
    final appBarTitle = car != null ? '${car.makeName} ${car.modelName}' : '';

    return Scaffold(
      backgroundColor: const Color(0xFF1C1F26),
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: const Color(0xFF2A2D36),
      ),
      body: SafeArea(
        child: AsyncStateView<List<Map<String, dynamic>>>(
          asyncValue: generationsAsync,
          errorHeading: context.l10n.generationsLoadError,
          onRetry: () => ref.refresh(generationsProvider(modelId)),
          dataBuilder: (generations) {
            return ListView.builder(
              // +1 for the leading "Пропустить" row
              itemCount: generations.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    children: [
                      CatalogListTile(
                        title: context.l10n.skipGeneration,
                        titleStyle: const TextStyle(
                          color: Color(0xFFF5A623),
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                        onTap: () => context.push('/selector/confirm'),
                      ),
                      const Divider(
                        color: Color(0xFF3D4050),
                        thickness: 1.5,
                        indent: 0,
                      ),
                    ],
                  );
                }

                final gen = generations[index - 1];
                final id = gen['id'] as int;
                final name = gen['name'] as String;
                final yearFrom = gen['year_from'] as int?;
                final yearTo = gen['year_to'] as int?;

                final yearSubtitle = _buildYearSubtitle(
                  context,
                  yearFrom,
                  yearTo,
                );

                return Column(
                  children: [
                    CatalogListTile(
                      title: name,
                      subtitle: yearSubtitle,
                      onTap: () {
                        ref
                            .read(selectedCarProvider.notifier)
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

  String? _buildYearSubtitle(
    BuildContext context,
    int? yearFrom,
    int? yearTo,
  ) {
    if (yearFrom != null && yearTo != null) return '$yearFrom–$yearTo';
    if (yearFrom != null) return context.l10n.fromYear(yearFrom);
    return null;
  }
}
