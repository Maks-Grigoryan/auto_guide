import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';

const _surface = Color(0xFF1C1F26);
const _card = Color(0xFF2A2D36);
const _outline = Color(0xFF3D4050);
const _accent = Color(0xFFF5A623);

/// Oldest year offered. Cars older than this exist, but not in a catalogue of
/// parts anyone is selling — the list has to end somewhere, and a wall of
/// unreachable years costs every user scrolling for nothing.
const _oldestYear = 1980;

/// Result of the sheet: which year, or the explicit decision not to say.
///
/// Needed because `null` alone is ambiguous — it cannot tell "cleared the year"
/// apart from "dismissed the sheet", and those must behave differently.
class YearChoice {
  const YearChoice(this.year);

  const YearChoice.skipped() : year = null;

  final int? year;
}

/// Modal list of years, newest first.
///
/// A grid rather than a dropdown: the audience includes people who do not aim
/// well at small targets, and a Material dropdown puts forty years into a strip
/// of 16 sp rows. Three columns keep every cell comfortably past the 56 dp the
/// rest of this app holds to.
Future<YearChoice?> showYearPickerSheet(
  BuildContext context, {
  int? selectedYear,
}) {
  return showModalBottomSheet<YearChoice>(
    context: context,
    backgroundColor: _surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _YearPickerSheet(selectedYear: selectedYear),
  );
}

class _YearPickerSheet extends StatelessWidget {
  const _YearPickerSheet({this.selectedYear});

  final int? selectedYear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Next year, not this one: cars are sold ahead of their model year, and
    // someone who just bought one should find it in the list.
    final newestYear = DateTime.now().year + 1;
    final years = [
      for (var year = newestYear; year >= _oldestYear; year -= 1) year,
    ];

    final scaledLabel = MediaQuery.textScalerOf(context).scale(18);
    final columns = scaledLabel > 26 ? 2 : 3;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.selectYear,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            // Skipping sits above the years, not buried under forty of them: it
            // is a real answer, and the one a person who does not know the year
            // needs to reach first.
            _SkipRow(
              label: l10n.yearSkip,
              isSelected: selectedYear == null,
              onTap: () =>
                  Navigator.of(context).pop(const YearChoice.skipped()),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  mainAxisExtent: (scaledLabel * 2.2 + 24).clamp(56, 140),
                ),
                itemCount: years.length,
                itemBuilder: (context, index) {
                  final year = years[index];
                  return _YearCell(
                    year: year,
                    isSelected: year == selectedYear,
                    onTap: () => Navigator.of(context).pop(YearChoice(year)),
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

class _SkipRow extends StatelessWidget {
  const _SkipRow({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isSelected ? _accent : _outline),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                if (isSelected) ...[
                  const Icon(Icons.check, color: _accent, size: 20),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: _accent,
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _YearCell extends StatelessWidget {
  const _YearCell({
    required this.year,
    required this.isSelected,
    required this.onTap,
  });

  final int year;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? _accent : _card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? _accent : _outline),
          ),
          child: Center(
            child: Text(
              '$year',
              style: TextStyle(
                color: isSelected ? _surface : Colors.white,
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
