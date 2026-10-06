import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/achievements.dart';
import '../../core/receipt_styles.dart';
import '../../data/csv_export.dart';
import '../../state/providers.dart';
import '../../widgets/payslip_parts.dart';
import '../onboarding/intake_form_screen.dart';
import 'paywall_screen.dart';

class PerksScreen extends ConsumerWidget {
  const PerksScreen({super.key});

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final sessions = ref.read(sessionsProvider).value ?? const [];
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/fuck-corpo-ledger.csv');
    await file.writeAsString(sessionsToCsv(sessions));
    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path, mimeType: 'text/csv')],
      subject: 'Fuck Corpo ledger',
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(proProvider);
    final style = ref.watch(receiptStyleProvider);
    final themeMode = ref.watch(themeModeProvider);
    final sessions = ref.watch(sessionsProvider).value ?? const [];
    final earned = [for (final a in achievements) a.test(sessions)];
    final scheme = Theme.of(context).colorScheme;
    final faded = scheme.onSurfaceVariant;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text('FUCK CORPO INC.\nBENEFITS PACKAGE',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            const DashedDivider(),
            if (isPro) ...[
              const Center(child: Stamp('MANAGEMENT', fontSize: 18)),
              const SizedBox(height: 16),
              Text("You're management now. Gross. Enjoy the perks.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: faded)),
            ] else ...[
              const Text('You are entry level. Perks are for management.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => PaywallScreen.open(context),
                child: const Text('GET PROMOTED'),
              ),
            ],
            const DashedDivider(),
            LineItem('ACHIEVEMENTS',
                '${earned.where((e) => e).length} / ${achievements.length}'),
            const SizedBox(height: 8),
            for (final (i, a) in achievements.indexed)
              InkWell(
                onTap: isPro ? null : () => PaywallScreen.open(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        !isPro
                            ? Icons.lock_outline
                            : earned[i]
                                ? Icons.verified_outlined
                                : Icons.radio_button_unchecked,
                        size: 20,
                        color: isPro && earned[i] ? scheme.secondary : faded,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.title,
                                style: TextStyle(
                                    color: isPro && earned[i]
                                        ? scheme.onSurface
                                        : faded)),
                            Text(a.description,
                                style: TextStyle(color: faded, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const DashedDivider(),
            Text('RECEIPT STYLE', style: TextStyle(color: faded)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final s in ReceiptStyle.values)
                ModeChip(
                  label: s.pro && !isPro ? '${s.label} (PRO)' : s.label,
                  selected: style == s,
                  onTap: s.pro && !isPro
                      ? () => PaywallScreen.open(context)
                      : () => ref.read(receiptStyleProvider.notifier).select(s),
                ),
            ]),
            const DashedDivider(),
            Text('APPEARANCE', style: TextStyle(color: faded)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final (mode, label) in const [
                (ThemeMode.system, 'SYSTEM'),
                (ThemeMode.light, 'PAPER'),
                (ThemeMode.dark, 'NIGHT SHIFT'),
              ])
                ModeChip(
                  label: label,
                  selected: themeMode == mode,
                  onTap: () =>
                      ref.read(themeModeProvider.notifier).select(mode),
                ),
            ]),
            const DashedDivider(),
            OutlinedButton(
              onPressed: isPro
                  ? () => _export(context, ref)
                  : () => PaywallScreen.open(context),
              child: Text(isPro ? 'EXPORT LEDGER (CSV)' : 'EXPORT LEDGER (PRO)'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const IntakeFormScreen(editing: true))),
              child: const Text('AMEND PAPERWORK'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => showLicensePage(
                context: context,
                applicationName: 'F*ck Corpo',
                applicationLegalese:
                    'Satire. We just do the math. Your ledger never leaves '
                    'this phone.',
              ),
              child: const Text('LEGAL FINE PRINT'),
            ),
            if (kDebugMode && isPro) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => ref.read(proProvider.notifier).relock(),
                child: const Text('DEBUG: DEMOTE TO ENTRY LEVEL'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
