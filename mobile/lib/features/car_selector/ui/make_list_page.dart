import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/catalog_providers.dart';
import '../state/selected_car_notifier.dart';

class MakeListPage extends ConsumerStatefulWidget {
  const MakeListPage({super.key});

  @override
  ConsumerState<MakeListPage> createState() => _MakeListPageState();
}

class _MakeListPageState extends ConsumerState<MakeListPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Поиск марки...',
                  hintStyle: const TextStyle(
                    color: Color(0xFFE0E0E0),
                    fontSize: 16,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFE0E0E0)),
                  filled: true,
                  fillColor: const Color(0xFF2A2D36),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Expanded(
              child: makesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFF5A623),
                  ),
                ),
                error: (error, _) => _ErrorView(
                  heading: 'Не удалось загрузить марки',
                  onRetry: () => ref.refresh(makesProvider),
                ),
                data: (makes) {
                  final filtered = _query.isEmpty
                      ? makes
                      : makes.where((m) {
                          final name =
                              (m['name'] as String).toLowerCase();
                          return name.contains(_query.toLowerCase());
                        }).toList();

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

                      return ListTile(
                        minVerticalPadding: 8,
                        title: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        onTap: () {
                          ref
                              .read(selectedCarNotifierProvider.notifier)
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
