import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/l10n.dart';
import '../../../core/utils/json_value.dart';

import '../data/catalog_providers.dart';
import '../state/selected_car_notifier.dart';
import 'widgets/async_state_view.dart';
import 'widgets/catalog_grid_tile.dart';
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
        title: Text(context.l10n.selectMake),
        backgroundColor: const Color(0xFF2A2D36),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SearchField(
                hintText: context.l10n.makeSearchHint,
                onChanged: (value) => setState(() => _query = value.trim()),
              ),
            ),
            Expanded(
              child: AsyncStateView<List<Map<String, dynamic>>>(
                asyncValue: makesAsync,
                errorHeading: context.l10n.makesLoadError,
                onRetry: () => ref.refresh(makesProvider),
                dataBuilder: (makes) {
                  // Client-side case-insensitive contains filter + compareTo sort
                  // (Pitfall 5 — Cyrillic sort).
                  final filtered = _query.isEmpty
                      ? List<Map<String, dynamic>>.from(makes)
                      : makes.where((m) {
                          final name = (m['name'] as String).toLowerCase();
                          return name.contains(_query.toLowerCase());
                        }).toList();

                  // Case-insensitive: compareTo orders by code unit, which put
                  // every capital ahead of every lowercase — «AIQAR» landed
                  // above «Abarth» and «iCar» fell past «ZX» to the very end.
                  filtered.sort((a, b) => (a['name'] as String)
                      .toLowerCase()
                      .compareTo((b['name'] as String).toLowerCase()));

                  if (filtered.isEmpty) {
                    // Same split as the model list: an empty catalogue is not a
                    // spelling mistake.
                    final message = _query.isEmpty
                        ? context.l10n.noMakesInCatalog
                        : context.l10n.makeNotFound;
                    return Center(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Color(0xFFE0E0E0),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  // Two columns halve the scrolling through a catalogue that
                  // runs to several hundred makes. They only work while a make
                  // name still fits half the width, so the grid collapses back
                  // to one column once the system text scale grows — the 200%
                  // scale contract outranks density.
                  final scaledTitle =
                      MediaQuery.textScalerOf(context).scale(18);
                  final columns = scaledTitle > 24 ? 1 : 2;
                  // Every cell in a row gets the same height, so size it for
                  // the two-line worst case («Alfa Romeo» at column width)
                  // rather than letting one long name overflow the row.
                  final cellHeight = math.max(56.0, scaledTitle * 2.6 + 32);

                  final gridDelegate =
                      SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: cellHeight,
                  );

                  // Group under the first letter. `filtered` is already
                  // sorted, so insertion order carries straight through:
                  // Latin A→Z first, then Cyrillic В, Г, У — which is what the
                  // code units give and what the catalogue mostly is.
                  final groups = <String, List<Map<String, dynamic>>>{};
                  for (final make in filtered) {
                    final name = make['name'] as String;
                    final letter =
                        name.isEmpty ? '#' : name[0].toUpperCase();
                    groups.putIfAbsent(letter, () => []).add(make);
                  }

                  return CustomScrollView(
                    slivers: [
                      for (final group in groups.entries) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(20, 16, 16, 8),
                            child: Text(
                              group.key,
                              style: const TextStyle(
                                color: Color(0xFFF5A623),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverGrid(
                            gridDelegate: gridDelegate,
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final make = group.value[index];
                                final id =
                                    jsonInt(make['id'], field: 'make.id');
                                final name = make['name'] as String;

                                return CatalogGridTile(
                                  title: name,
                                  onTap: () {
                                    ref
                                        .read(selectedCarProvider.notifier)
                                        .pickMake(id, name);
                                    context.push(
                                      '/selector/model',
                                      extra: id,
                                    );
                                  },
                                );
                              },
                              childCount: group.value.length,
                            ),
                          ),
                        ),
                      ],
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    ],
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
