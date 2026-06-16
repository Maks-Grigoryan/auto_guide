import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/catalog_providers.dart';
import '../state/selected_car_notifier.dart';
import 'widgets/async_state_view.dart';
import 'widgets/catalog_list_tile.dart';
import 'widgets/search_field.dart';

class ModelListPage extends ConsumerStatefulWidget {
  const ModelListPage({super.key, required this.makeId});

  final int makeId;

  @override
  ConsumerState<ModelListPage> createState() => _ModelListPageState();
}

class _ModelListPageState extends ConsumerState<ModelListPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final modelsAsync = ref.watch(modelsProvider(widget.makeId));
    final car = ref.watch(selectedCarProvider);
    final appBarTitle = car?.makeName ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF1C1F26),
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: const Color(0xFF2A2D36),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SearchField(
                hintText: 'Поиск модели...',
                onChanged: (value) => setState(() => _query = value.trim()),
              ),
            ),
            Expanded(
              child: AsyncStateView<List<Map<String, dynamic>>>(
                asyncValue: modelsAsync,
                errorHeading: 'Не удалось загрузить модели',
                onRetry: () => ref.refresh(modelsProvider(widget.makeId)),
                dataBuilder: (models) {
                  final filtered = _query.isEmpty
                      ? List<Map<String, dynamic>>.from(models)
                      : models.where((m) {
                          final name =
                              (m['name'] as String).toLowerCase();
                          return name.contains(_query.toLowerCase());
                        }).toList();

                  filtered.sort((a, b) => (a['name'] as String)
                      .compareTo(b['name'] as String));

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'Модель не найдена. Проверьте написание.',
                        style: TextStyle(
                          color: Color(0xFFE0E0E0),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(
                      color: Color(0xFF3D4050),
                      indent: 16,
                    ),
                    itemBuilder: (context, index) {
                      final model = filtered[index];
                      final id = model['id'] as int;
                      final name = model['name'] as String;

                      return CatalogListTile(
                        title: name,
                        onTap: () {
                          ref
                              .read(selectedCarProvider.notifier)
                              .pickModel(id, name);
                          context.push('/selector/generation', extra: id);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
