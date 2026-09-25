import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ai_chat/widgets/ai_chat_bar.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/widgets/language_picker.dart';
import '../../l10n/l10n.dart';
import 'widgets/hub_tile.dart';

const _surface = Color(0xFF1C1F26);
const _bar = Color(0xFF2A2D36);
const _accent = Color(0xFFF5A623);
const _textSecondary = Color(0xFFE0E0E0);

/// Main screen: the app's top-level menu.
///
/// The parts-and-repair search used to be the landing screen; it is now one
/// section among several. This screen owns the account chrome — admin badge,
/// language, sign out — because it is the one screen every session starts on.
///
/// No car is required to be here. The car belongs to the search section and is
/// asked for on the way into it, not at the door of the app.
class HubPage extends ConsumerWidget {
  const HubPage({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).signOut();
    if (!context.mounted) return;
    // go, not push: the signed-in screens must not stay on the back stack.
    context.go('/auth');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isAdmin = ref.watch(authControllerProvider)?.isAdmin ?? false;

    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        title: Text(l10n.appTitle),
        backgroundColor: _bar,
        actions: [
          // Marks an admin session. The role is whatever the server reported at
          // sign-in; the app never decides it and cannot ask for it.
          if (isAdmin)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.authAdminBadge,
                  style: const TextStyle(
                    color: _surface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          const LanguageButton(),
          IconButton(
            tooltip: l10n.authSignOut,
            onPressed: () => _signOut(context, ref),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        // Scrolls rather than shrinks: more sections are coming, and at 200%
        // text scale even this one already fills a short screen.
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          children: [
            // Above the sections, not among them: the assistant is a way of
            // asking rather than a place to go, and someone who cannot name the
            // part should meet it before the menu that expects them to.
            AiChatBar(onTap: () => context.push('/ai-chat')),
            const SizedBox(height: 24),
            Text(
              l10n.hubSectionsLabel,
              style: const TextStyle(
                color: _textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            HubTile(
              icon: Icons.shopping_bag_outlined,
              label: l10n.hubParts,
              hint: l10n.hubPartsHint,
              // push, not go: the section is entered from here and comes back
              // here, so it keeps the main screen underneath it.
              // extra selects the section on the search screen: 0 = parts.
              onTap: () => context.push('/search', extra: 0),
            ),
            const SizedBox(height: 12),
            HubTile(
              icon: Icons.build_outlined,
              label: l10n.hubRepair,
              hint: l10n.hubRepairHint,
              // extra selects the section on the search screen: 1 = repair.
              onTap: () => context.push('/search', extra: 1),
            ),
            const SizedBox(height: 12),
            HubTile(
              icon: Icons.local_shipping_outlined,
              label: l10n.hubRoadside,
              hint: l10n.hubRoadsideHint,
              badge: l10n.hubComingSoon,
              // The section itself does not exist yet. Say so out loud rather
              // than swallowing the tap: a button that answers nothing reads as
              // a broken app, not as an unfinished one.
              onTap: () => _sayComingSoon(context, l10n),
            ),
          ],
        ),
      ),
    );
  }

  void _sayComingSoon(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.hubComingSoonMessage)));
  }
}
