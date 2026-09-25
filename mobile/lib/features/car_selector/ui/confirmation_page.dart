import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/l10n.dart';

import '../state/selected_car_notifier.dart';
import 'widgets/confirmation_row.dart';

class ConfirmationPage extends ConsumerWidget {
  const ConfirmationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(selectedCarProvider.notifier);

    final makeName = notifier.draftMakeName;
    final modelName = notifier.draftModelName;

    // Reached without a draft — a hot restart, or a pasted URL on the web.
    // There is nothing to confirm, so start the wizard rather than show a page
    // of dashes above a button that would throw on its null assertions.
    if (makeName == null || modelName == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/selector/make');
      });
      return const Scaffold(backgroundColor: Color(0xFF1C1F26));
    }

    // Draft only, never falling back to the confirmed car: mixing the two
    // showed the previous car's generation beside the new make and model
    // whenever someone chose «Пропустить» on the generation step.
    final generationLabel =
        notifier.draftGenerationLabel ?? context.l10n.generationNotSpecified;

    final draftYear = notifier.draftYear;
    final yearLabel =
        draftYear != null ? '$draftYear' : context.l10n.yearNotSpecified;

    return Scaffold(
      backgroundColor: const Color(0xFF1C1F26),
      appBar: AppBar(
        title: Text(context.l10n.yourCar),
        backgroundColor: const Color(0xFF2A2D36),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: const Color(0xFF2A2D36),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    ConfirmationRow(
                      label: context.l10n.make,
                      value: makeName,
                      onTap: () => context.push('/selector/make'),
                    ),
                    const Divider(color: Color(0xFF3D4050)),
                    ConfirmationRow(
                      label: context.l10n.model,
                      value: modelName,
                      onTap: () {
                        // Draft only: the guard above has already established
                        // there is one, and the confirmed car's make would send
                        // the person to the model list of a different car.
                        final makeId = notifier.draftMakeId;
                        if (makeId != null) {
                          context.push('/selector/model', extra: makeId);
                        } else {
                          context.push('/selector/make');
                        }
                      },
                    ),
                    const Divider(color: Color(0xFF3D4050)),
                    ConfirmationRow(
                      label: context.l10n.generation,
                      value: generationLabel,
                      onTap: () {
                        final modelId = notifier.draftModelId;
                        if (modelId != null) {
                          context.push(
                            '/selector/generation',
                            extra: modelId,
                          );
                        } else {
                          context.push('/selector/make');
                        }
                      },
                    ),
                    const Divider(color: Color(0xFF3D4050)),
                    // Same destination as the generation row: both are chosen
                    // on that screen, and a separate step for the year would
                    // mean leaving one to change the other.
                    ConfirmationRow(
                      label: context.l10n.yearLabel,
                      value: yearLabel,
                      onTap: () {
                        final modelId = notifier.draftModelId;
                        if (modelId != null) {
                          context.push(
                            '/selector/generation',
                            extra: modelId,
                          );
                        } else {
                          context.push('/selector/make');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5A623),
                foregroundColor: const Color(0xFF1C1F26),
                minimumSize: const Size(double.infinity, 56),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                notifier.confirm();
                // Back to the search, not to the main screen: the car is only
                // ever asked for on the way into the search section, so that is
                // where the person was going.
                context.go('/search');
              },
              child: Text(context.l10n.confirmSelection),
            ),
          ],
        ),
      ),
    );
  }
}
