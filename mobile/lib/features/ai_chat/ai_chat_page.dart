import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import 'domain/chat_message.dart';
import 'widgets/chat_bubble.dart';

const _surface = Color(0xFF1C1F26);
const _bar = Color(0xFF2A2D36);
const _outline = Color(0xFF3D4050);
const _accent = Color(0xFFF5A623);
const _textSecondary = Color(0xFFE0E0E0);

/// Full-screen assistant conversation.
///
/// Interface only: there is no backend behind it yet, so every answer is the
/// same honest placeholder. It is a [ConsumerStatefulWidget] rather than a
/// plain one because the thread moves into a provider the moment a server
/// exists, and the car and location it will need already live in providers.
class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <ChatMessage>[];
  bool _awaitingReply = false;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send(String raw) {
    final text = raw.trim();
    if (text.isEmpty || _awaitingReply) return;

    setState(() {
      _messages.add(ChatMessage.user(text));
      _awaitingReply = true;
      _input.clear();
    });
    _scrollToEnd();

    // Stands in for the round trip to the server. Deliberately short: a beat so
    // the reply does not land in the same frame as the question, not a fake
    // imitation of thinking.
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _awaitingReply = false;
        _messages.add(ChatMessage.assistant(context.l10n.aiChatNotConnected));
      });
      _scrollToEnd();
    });
  }

  void _scrollToEnd() {
    // After the frame: the new bubble has to be laid out before its offset
    // exists.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEmpty = _messages.isEmpty && !_awaitingReply;

    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        title: Text(l10n.aiChatTitle),
        backgroundColor: _bar,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      itemCount: _messages.length + (_awaitingReply ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) {
                          return const TypingBubble();
                        }
                        return ChatBubble(message: _messages[index]);
                      },
                    ),
            ),
            // Sits above the input rather than inside the empty state, so it
            // stays on screen once the conversation starts. A warning that
            // scrolls away with the greeting is a warning nobody sees at the
            // moment it matters — when an answer about brakes has just arrived.
            const _Disclaimer(),
            _Composer(
              controller: _input,
              enabled: !_awaitingReply,
              onSend: _send,
            ),
          ],
        ),
      ),
    );
  }
}

/// What the screen shows before the first question: the question itself.
///
/// The safety notice used to live here too, and now sits above the input where
/// it survives the conversation starting.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          context.l10n.aiChatGreeting,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
        ),
      ),
    );
  }
}

/// The one line that must be read, kept permanently in view above the input.
class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: _textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.aiChatDisclaimer,
              style: const TextStyle(
                color: _textSecondary,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The input row pinned to the bottom.
class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // No panel behind the input: the field has its own outline, and a second
    // grey slab under it only cut the screen in two.
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              // Grows with the question instead of scrolling a one-line field:
              // describing a fault takes more than a few words.
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: onSend,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: l10n.aiChatInputHint,
                hintStyle: const TextStyle(
                  color: _textSecondary,
                  fontSize: 16,
                ),
                filled: true,
                fillColor: _surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: _outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: _outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: _accent, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 52 dp of solid accent: the one control on the screen that must be
          // hittable without aiming.
          Material(
            color: enabled ? _accent : _outline,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: enabled ? () => onSend(controller.text) : null,
              child: Tooltip(
                message: l10n.aiChatSend,
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: Icon(
                    Icons.arrow_upward,
                    color: enabled ? _surface : _textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
