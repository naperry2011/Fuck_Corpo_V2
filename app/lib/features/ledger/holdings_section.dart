import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/portfolio.dart';
import '../../core/takeover.dart';
import '../../state/providers.dart';
import '../../widgets/payslip_parts.dart';
import '../pro/paywall_screen.dart';

/// All-time hostile takeover portfolio, shown on the Ledger.
class HoldingsSection extends ConsumerWidget {
  const HoldingsSection({super.key});

  static const _shown = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cur = ref.watch(profileProvider)!.currency;
    final isPro = ref.watch(proProvider);
    final sessions = ref.watch(sessionsProvider).value ?? const [];
    final p = Portfolio.from(sessions);
    final faded = Theme.of(context).colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DashedDivider(),
        Text('FUCK CORPO HOLDINGS · ACQUISITIONS',
            style: TextStyle(color: faded)),
        const SizedBox(height: 8),
        if (p.isEmpty)
          Text(
            'No hostile takeovers yet. Next time nature calls somewhere '
            'else, pick HOSTILE TAKEOVER on the clock.',
            style: TextStyle(color: faded, fontSize: 13),
          )
        else ...[
          LineItem('Companies acquired', '${p.companies}'),
          LineItem('Total takeovers', '${p.takeovers}'),
          LineItem('Damages billed', money(p.damages, cur)),
          LineItem('Favorite target',
              '${p.favorite!.name} (${p.favorite!.takeovers}x)'),
          const SizedBox(height: 12),
          Text('HOLDINGS', style: TextStyle(color: faded)),
          for (final h in p.holdings.take(_shown))
            LineItem(h.name, '${h.takeovers}x',
                style: const TextStyle(fontSize: 13)),
          if (p.holdings.length > _shown)
            Text('+ ${p.holdings.length - _shown} more',
                style: TextStyle(color: faded, fontSize: 13)),
          const SizedBox(height: 12),
          if (isPro) ...[
            Text('BY INDUSTRY', style: TextStyle(color: faded)),
            for (final c in BusinessCategory.values)
              if (p.byCategory[c]! > 0)
                LineItem(c.label, '${p.byCategory[c]}x',
                    style: const TextStyle(fontSize: 13)),
          ] else
            OutlinedButton(
              onPressed: () => PaywallScreen.open(context),
              child: const Text('PORTFOLIO INTEL (PRO)'),
            ),
        ],
      ],
    );
  }
}
