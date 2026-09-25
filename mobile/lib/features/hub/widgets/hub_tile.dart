import 'package:flutter/material.dart';

const _card = Color(0xFF2A2D36);
const _outline = Color(0xFF3D4050);
const _accent = Color(0xFFF5A623);
const _textPrimary = Color(0xFFFFFFFF);
const _textSecondary = Color(0xFFE0E0E0);

/// One section button on the main screen.
///
/// Deliberately large: this is the top-level menu of the whole app, and the
/// audience includes people who do not aim well at small controls. The icon
/// carries the section as well as the words do, so the screen still reads for
/// someone skimming it in an unfamiliar language.
class HubTile extends StatelessWidget {
  const HubTile({
    super.key,
    required this.icon,
    required this.label,
    required this.hint,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;

  /// Second line: what the section actually does, in plain words.
  final String hint;

  final VoidCallback onTap;

  /// Short marker beside the label, e.g. «Скоро».
  ///
  /// A section that is only a button so far has to say so on its face. Left
  /// unmarked it would look finished, and the tap that does nothing would read
  /// as the app being broken.
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _outline),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 30, color: const Color(0xFF1C1F26)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Wrap, not a Row: at 200% text scale the label alone
                      // fills the width, and a side-by-side badge would push
                      // it into an overflow.
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              color: _textPrimary,
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                          if (badge != null) _Badge(text: badge!),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hint,
                        style: const TextStyle(
                          color: _textSecondary,
                          fontSize: 15,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: _textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Outlined rather than filled: the accent fill is what a working control looks
/// like in this app, and this badge marks the opposite.
class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _accent),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: _accent,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
