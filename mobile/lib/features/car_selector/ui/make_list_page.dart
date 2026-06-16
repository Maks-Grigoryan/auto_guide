import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/catalog_providers.dart';
import '../state/selected_car_notifier.dart';
import 'widgets/async_state_view.dart';
import 'widgets/catalog_list_tile.dart';
import 'widgets/search_field.dart';

class MakeListPage extends ConsumerStatefulWidget {
  const MakeListPage({super.key});

  @override
  ConsumerState<MakeListPage> createState() => _MakeListPageState();
}

class _MakeListPageState extends ConsumerState<MakeListPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final makesAsync = ref.watch(makesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1C1F26),
      appBar: AppBar(
        title: const Text('Выберите марку'),
        backgroundColor: const Color(0xFF2A2D36),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SearchField(
                hintText: 'Поиск марки...',
                onChanged: (value) => setState(() => _query = value.trim()),
              ),
            ),
            Expanded(
              child: AsyncStateView<List<Map<String, dynamic>>>(
                asyncValue: makesAsync,
                errorHeading: 'Не удалось загрузить марки',
                onRetry: () => ref.refresh(makesProvider),
                dataBuilder: (makes) {
                  // Client-side case-insensitive contains filter + compareTo sort
                  // (Pitfall 5 — Cyrillic sort).
                  final filtered = _query.isEmpty
                      ? List<Map<String, dynamic>>.from(makes)
                      : makes.where((m) {
                          final name =
                              (m['name'] as String).toLowerCase();
                          return name.contains(_query.toLowerCase());
                        }).toList();

                  filtered.sort((a, b) => (a['name'] as String)
                      .compareTo(b['name'] as String));

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'Марка не найдена. Проверьте написание.',
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
                      final make = filtered[index];
                      final id = make['id'] as int;
                      final name = make['name'] as String;

                      return CatalogListTile(
                        title: name,
                        onTap: () {
                          ref
                              .read(selectedCarProvider.notifier)
                              .pickMake(id, name);
                          context.push('/selector/model', extra: id);
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
