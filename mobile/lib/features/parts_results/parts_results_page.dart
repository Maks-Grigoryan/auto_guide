import 'package:flutter/material.dart';

/// Placeholder for the parts search results screen.
///
/// Real implementation lands in 03-04 / 03-05.
/// Scaffold ensures the route is renderable and the smoke test can navigate
/// without a crash.
class PartsResultsPage extends StatelessWidget {
  const PartsResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Результаты поиска')),
      body: const Center(
        child: Text('Загрузка...'),
      ),
    );
  }
}
