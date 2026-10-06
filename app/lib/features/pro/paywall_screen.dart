import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/providers.dart';
import '../../widgets/payslip_parts.dart';
import 'billing.dart';

const _perks = [
  ('3 NEW BREAKS', 'Doomscroll, Fake Meeting, and Coffee Run.'),
  ('10 ACHIEVEMENTS', 'Mogul, Union Rep, Snip It Off, and more.'),
  ('3 RECEIPT STYLES', 'Gold Receipt, CEO Memo, and Strike Poster.'),
  ('UNHINGED ROAST PACK', 'Meaner receipts. HR would not approve.'),
  ('CSV EXPORT', 'Your full ledger, for spreadsheets or the union.'),
];

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  static Future<void> open(BuildContext context) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const PaywallScreen()));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(proProvider, (was, isPro) {
      if (was == false && isPro) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Welcome to management. Gross.')));
        Navigator.of(context).maybePop();
      }
    });

    final billing = ref.watch(billingProvider);
    final notifier = ref.read(billingProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final faded = scheme.onSurfaceVariant;
    final price = billing.product?.price;
    final busy = billing.status == BillingStatus.loading ||
        billing.status == BillingStatus.pending;

    void unavailable() => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(billing.message ?? 'Still connecting to Google Play.')));

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          children: [
            const Text('FUCK CORPO INC.\nPROMOTION OFFER',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            const DashedDivider(),
            const Text(
              'Congratulations. You have been promoted to MANAGEMENT. '
              'Same job, worse ethics, better perks.',
            ),
            const SizedBox(height: 20),
            for (final (title, body) in _perks)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('+ $title',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(body, style: TextStyle(color: faded, fontSize: 13)),
                  ],
                ),
              ),
            const DashedDivider(),
            LineItem('COMPENSATION', price == null ? '...' : '$price ONE TIME',
                style: const TextStyle(fontSize: 18)),
            Text("No subscription. We're not monsters.",
                style: TextStyle(color: faded, fontSize: 12)),
            if (billing.message != null &&
                billing.status != BillingStatus.ready) ...[
              const SizedBox(height: 16),
              Text(
                billing.message!,
                style: TextStyle(
                    color: billing.status == BillingStatus.pending
                        ? faded
                        : scheme.error,
                    fontSize: 13),
              ),
            ],
            const SizedBox(height: 28),
            FilledButton(
              onPressed: busy
                  ? null
                  : billing.product == null
                      ? unavailable
                      : notifier.buy,
              child: Text(switch (billing.status) {
                BillingStatus.loading => 'CONNECTING TO HR...',
                BillingStatus.pending => 'PROCESSING PAPERWORK...',
                _ => price == null
                    ? 'ACCEPT PROMOTION'
                    : 'ACCEPT PROMOTION · $price',
              }),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: notifier.restore,
              child: const Text('ALREADY PROMOTED? RESTORE'),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => ref.read(proProvider.notifier).unlock(),
                child: const Text('DEBUG: PROMOTE WITHOUT PAYING'),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'One-time purchase through Google Play. Restores automatically '
              'on reinstall with the same Google account.',
              textAlign: TextAlign.center,
              style: TextStyle(color: faded, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
