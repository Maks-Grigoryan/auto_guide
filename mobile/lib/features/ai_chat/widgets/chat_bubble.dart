import 'package:flutter/material.dart';

import '../domain/chat_message.dart';

const _card = Color(0xFF2A2D36);
const _outline = Color(0xFF3D4050);
const _accent = Color(0xFFF5A623);
const _surface = Color(0xFF1C1F26);

/// One message, sided by who wrote it.
///
/// The user gets the accent fill, the assistant a grey card. Side and colour
/// both carry the distinction, so the thread stays readable for someone who
/// cannot separate the two hues — the app's colour rule, applied to a screen
/// that is nothing but coloured blocks.
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        // Never full width: an edge of background on the far side is what makes
        // the thread scan as a conversation rather than as stacked paragraphs.
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isUser ? _accent : _card,
            border: isUser ? null : Border.all(color: _outline),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              // The squared-off corner points at its author.
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: isUser ? _surface : Colors.white,
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}

/// Placeholder shown while an answer is on its way.
///
/// Static dots rather than an animation: this screen has no backend yet, and a
/// pulsing indicator would promise work that is not happening.
class TypingBubble extends StatelessWidget {
  const TypingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _card,
          border: Border.all(color: _outline),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(),
            SizedBox(width: 5),
            _Dot(),
            SizedBox(width: 5),
            _Dot(),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(
        color: Color(0xFFE0E0E0),
        shape: BoxShape.circle,
      ),
    );
  }
}
