import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/providers.dart';
import '../../widgets/payslip_parts.dart';

/// Placeholder until the Play Console product exists. Shown on the paywall
/// so nobody forgets it is not the real price yet.
const proPriceLabel = r'$2.99';

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
    final faded = Theme.of(context).colorScheme.onSurfaceVariant;
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
            const LineItem('COMPENSATION', '$proPriceLabel ONE TIME',
                style: TextStyle(fontSize: 18)),
            Text("No subscription. We're not monsters.",
                style: TextStyle(color: faded, fontSize: 12)),
            const SizedBox(height: 24),
            const Center(child: Stamp('TEST MODE', fontSize: 14)),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                await ref.read(proProvider.notifier).unlock();
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('ACCEPT PROMOTION (TEST)'),
            ),
            const SizedBox(height: 8),
            Text(
              'Test mode: no money changes hands. Real Google Play billing '
              'replaces this before launch.',
              textAlign: TextAlign.center,
              style: TextStyle(color: faded, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
