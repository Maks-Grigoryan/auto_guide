import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/l10n.dart';
import '../../../core/utils/json_value.dart';

import '../data/catalog_providers.dart';
import '../state/selected_car_notifier.dart';
import 'widgets/async_state_view.dart';
import 'widgets/catalog_list_tile.dart';
import 'widgets/year_picker_sheet.dart';

const _surface = Color(0xFF1C1F26);
const _bar = Color(0xFF2A2D36);
const _outline = Color(0xFF3D4050);
const _accent = Color(0xFFF5A623);
const _textSecondary = Color(0xFFE0E0E0);

/// Stateful because the chosen year has to survive the sheet closing and show
/// in the row before anything is confirmed. The notifier already holds it, but
/// its draft is not listenable, so the screen keeps a copy to rebuild from.
class GenerationListPage extends ConsumerStatefulWidget {
  const GenerationListPage({super.key, required this.modelId});

  final int modelId;

  @override
  ConsumerState<GenerationListPage> createState() => _GenerationListPageState();
}

class _GenerationListPageState extends ConsumerState<GenerationListPage> {
  int? _year;

  @override
  void initState() {
    super.initState();
    // Coming back to this step should show what was picked last time rather
    // than silently forgetting it.
    _year = ref.read(selectedCarProvider.notifier).draftYear;
  }

  Future<void> _pickYear() async {
    final choice = await showYearPickerSheet(context, selectedYear: _year);
    // null means the sheet was dismissed — leave the year alone. A cleared year
    // arrives as YearChoice.skipped(), which is a decision and does apply.
    if (choice == null || !mounted) return;

    setState(() => _year = choice.year);
    ref.read(selectedCarProvider.notifier).pickYear(choice.year);
  }

  @override
  Widget build(BuildContext context) {
    final generationsAsync = ref.watch(generationsProvider(widget.modelId));

    final car = ref.watch(selectedCarProvider);
    final draft = ref.read(selectedCarProvider.notifier);
    final makeName = draft.draftMakeName ?? car?.makeName;
    final modelName = draft.draftModelName ?? car?.modelName;
    final appBarTitle =
        makeName != null && modelName != null ? '$makeName $modelName' : '';

    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: _bar,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Above the generations, and outside the list, because it applies
            // whether or not this model has any. For most makes in this
            // catalogue it does not, and then the year is the only thing that
            // narrows the car down at all.
            // A band of page background between the app bar and this row. Both
            // are the same grey, so without it they merged into one tall header
            // and the year looked like part of the title.
            const SizedBox(height: 10),
            _YearRow(
              year: _year,
              onTap: _pickYear,
              onSkip: () => context.push('/selector/confirm'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: AsyncStateView<List<Map<String, dynamic>>>(
                asyncValue: generationsAsync,
                errorHeading: context.l10n.generationsLoadError,
                onRetry: () => ref.refresh(generationsProvider(widget.modelId)),
                dataBuilder: (generations) {
                  // Skipping now lives in the year row above, so this list is
                  // generations and nothing else.
                  return ListView.builder(
                    itemCount: generations.length,
                    itemBuilder: (context, index) {
                      final gen = generations[index];
                      final id = jsonInt(gen['id'], field: 'generation.id');
                      final name = gen['name'] as String;
                      final yearFrom = jsonNullableInt(
                        gen['year_from'],
                        field: 'generation.year_from',
                      );
                      final yearTo = jsonNullableInt(
                        gen['year_to'],
                        field: 'generation.year_to',
                      );

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
                          if (index < generations.length - 1)
                            const Divider(
                              color: _outline,
                              indent: 16,
                            ),
                        ],
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

/// The year, plus the way past this whole step.
///
/// Two targets in one row, side by side rather than stacked: they are the two
/// things a person can do here, and putting "skip" on its own line under the
/// year made it read as a third generation to choose from.
class _YearRow extends StatelessWidget {
  const _YearRow({
    required this.year,
    required this.onTap,
    required this.onSkip,
  });

  final int? year;
  final VoidCallback onTap;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isSet = year != null;

    // Four things in one row — arrow, label, value, skip — stop fitting once
    // the system text scale grows. Past that they stack, which costs a line of
    // height and keeps both targets reachable.
    final isWide = MediaQuery.textScalerOf(context).scale(18) <= 26;

    final yearTarget = InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 8, 14),
        child: Row(
          children: [
            // Leading, not trailing: it points at the value it opens, and the
            // right edge now belongs to «Пропустить».
            const Icon(Icons.expand_more, color: _textSecondary),
            const SizedBox(width: 8),
            // Wrap, not a Row: at a large text scale the label alone fills the
            // width and a side-by-side value would overflow.
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 2,
                children: [
                  Text(
                    l10n.yearLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  // Nothing stands in for an unset year. The label and the
                  // arrow already say a value belongs here; «Не указан» only
                  // restated the blank in words.
                  if (isSet)
                    Text(
                      '$year',
                      style: const TextStyle(
                        color: _accent,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final skipTarget = InkWell(
      onTap: onSkip,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 16),
        child: Text(
          l10n.skipGeneration,
          style: const TextStyle(color: _accent, fontSize: 15),
        ),
      ),
    );

    return Material(
      color: _bar,
      child: isWide
          ? Row(children: [Expanded(child: yearTarget), skipTarget])
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                yearTarget,
                Align(alignment: Alignment.centerRight, child: skipTarget),
              ],
            ),
    );
  }
}
