import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';

const _card = Color(0xFF2A2D36);
const _accent = Color(0xFFF5A623);
const _surface = Color(0xFF1C1F26);
const _textSecondary = Color(0xFFE0E0E0);

/// Entry point to the assistant, sitting above the section list.
///
/// Shaped like a text field on purpose: it invites typing, which is what the
/// assistant wants, and it reads differently from the section tiles below —
/// those are places you go, this is a question you ask. It is a button, not a
/// field: tapping opens the full chat, where the real input lives and the
/// keyboard has room.
///
/// The accent outline is the only one in the app: sections are outlined in
/// grey, so the single warm border marks the new thing without another block
/// of solid yellow competing with the tiles.
class AiChatBar extends StatelessWidget {
  const AiChatBar({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Material(
      color: _card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _accent, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: _accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 22,
                    color: _surface,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.aiChatBarPrompt,
                    // Two lines: the prompt is a sentence, and at a large
                    // system text scale it will not sit on one.
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _textSecondary,
                      fontSize: 16,
                      height: 1.3,
                    ),
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
