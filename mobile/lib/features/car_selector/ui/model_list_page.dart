import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/catalog_providers.dart';
import '../state/selected_car_notifier.dart';

class ModelListPage extends ConsumerStatefulWidget {
  const ModelListPage({super.key, required this.makeId});

  final int makeId;

  @override
  ConsumerState<ModelListPage> createState() => _ModelListPageState();
}

class _ModelListPageState extends ConsumerState<ModelListPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modelsAsync = ref.watch(modelsProvider(widget.makeId));

    // Use the confirmed-state make name for the AppBar title if available.
    // During editing, _inProgress is transient — fall back to empty string.
    final car = ref.watch(selectedCarNotifierProvider);
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
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Поиск модели...',
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
              child: modelsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFF5A623),
                  ),
                ),
                error: (error, _) => _ErrorView(
                  heading: 'Не удалось загрузить модели',
                  onRetry: () => ref.refresh(modelsProvider(widget.makeId)),
                ),
                data: (models) {
                  final filtered = _query.isEmpty
                      ? models
                      : models.where((m) {
                          final name =
                              (m['name'] as String).toLowerCase();
                          return name.contains(_query.toLowerCase());
                        }).toList();

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
