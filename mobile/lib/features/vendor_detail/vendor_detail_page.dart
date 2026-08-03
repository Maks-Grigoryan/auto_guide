import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/vendor_detail.dart';
import '../../l10n/l10n.dart';
import 'contact_launcher.dart';
import 'vendor_detail_provider.dart';

class VendorDetailPage extends ConsumerWidget {
  VendorDetailPage({
    super.key,
    required this.vendorId,
    ContactLauncher? contactLauncher,
  }) : contactLauncher = contactLauncher ?? ContactLauncher();

  final String vendorId;
  final ContactLauncher contactLauncher;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendor = ref.watch(vendorDetailProvider(vendorId));
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.vendor)),
      body: vendor.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _LoadError(
          onRetry: () => ref.invalidate(vendorDetailProvider(vendorId)),
        ),
        data: (detail) => VendorDetailView(
          vendor: detail,
          contactLauncher: contactLauncher,
        ),
      ),
    );
  }
}

class VendorDetailView extends StatelessWidget {
  const VendorDetailView({
    super.key,
    required this.vendor,
    required this.contactLauncher,
  });

  final VendorDetail vendor;
  final ContactLauncher contactLauncher;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(vendor.name, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(_typeLabel(context, vendor.type)),
          if (vendor.isVerified) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.verified, color: Color(0xFFF5A623)),
                const SizedBox(width: 8),
                Expanded(child: Text(context.l10n.verifiedVendor)),
              ],
            ),
          ],
          if (vendor.rating != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFF5A623)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.ratingOutOfFive(
                      vendor.rating!.toStringAsFixed(1),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (vendor.address?.trim().isNotEmpty ?? false) ...[
            const SizedBox(height: 20),
            _InfoRow(icon: Icons.place_outlined, text: vendor.address!),
          ],
          if (vendor.phone?.trim().isNotEmpty ?? false) ...[
            const SizedBox(height: 12),
            _InfoRow(icon: Icons.phone_outlined, text: vendor.phone!),
          ],
          if (vendor.hours?.isNotEmpty ?? false) ...[
            const SizedBox(height: 24),
            Text(
              context.l10n.openingHours,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: vendor.hours!.entries
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(_hoursLabel(context, entry.key)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          if (vendor.phone?.trim().isNotEmpty ?? false) ...[
            ElevatedButton.icon(
              onPressed: () => _perform(
                context,
                () => contactLauncher.call(vendor.phone!),
              ),
              icon: const Icon(Icons.phone),
              label: Text(context.l10n.call),
            ),
            const SizedBox(height: 12),
          ],
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              foregroundColor: const Color(0xFFF5A623),
              side: const BorderSide(color: Color(0xFFF5A623)),
            ),
            onPressed: () => _perform(
              context,
              () => contactLauncher.route(lat: vendor.lat, lng: vendor.lng),
            ),
            icon: const Icon(Icons.directions_outlined),
            label: Text(context.l10n.route),
          ),
        ],
      ),
    );
  }

  Future<void> _perform(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.openAppError)),
      );
    }
  }

  static String _typeLabel(BuildContext context, String type) => switch (type) {
        'repair_shop' => context.l10n.repairShop,
        'parts_shop' => context.l10n.partsShop,
        _ => type,
      };

  static String _hoursLabel(BuildContext context, String value) =>
      switch (value.toLowerCase()) {
        'mon-fri' => context.l10n.weekdaysShort,
        'sat' => context.l10n.saturdayShort,
        'sun' => context.l10n.sundayShort,
        _ => value,
      };
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFE0E0E0)),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48),
            const SizedBox(height: 16),
            Text(
              context.l10n.vendorLoadError,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
