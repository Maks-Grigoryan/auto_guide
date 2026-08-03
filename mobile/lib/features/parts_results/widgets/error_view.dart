import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';

/// Error state for the results screen (RES-07 / T-03-11 mitigation).
///
/// Shows icon + heading + generic body + retry button.
/// Never exposes raw exception or stack trace.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: Color(0xFFE0E0E0)),
            const SizedBox(height: 16),
            Text(
              context.l10n.resultsLoadError,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.connectionHelp,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFFE0E0E0),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 56,
              child: TextButton(
                onPressed: onRetry,
                child: Text(
                  context.l10n.retry,
                  style: const TextStyle(
                    color: Color(0xFFF5A623),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
