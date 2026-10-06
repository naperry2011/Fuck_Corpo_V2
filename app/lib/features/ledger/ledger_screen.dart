import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/break_mode.dart';
import '../../core/format.dart';
import '../../core/stats.dart';
import '../../data/database.dart';
import '../../data/dev_seed.dart';
import '../../state/providers.dart';
import '../../widgets/payslip_parts.dart';
import '../receipt/receipt_screen.dart';
import '../wrapped/wrapped_screen.dart';
import 'manual_log_screen.dart';

class LedgerScreen extends ConsumerStatefulWidget {
  const LedgerScreen({super.key});

  @override
  ConsumerState<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends ConsumerState<LedgerScreen> {
  Period _period = Period.week;

  Future<void> _void(Session s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('VOID RECEIPT #${s.id.toString().padLeft(6, '0')}?'),
        content: const Text("Corpo gets that money back. Don't let them."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('KEEP IT')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('VOID')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(databaseProvider).deleteSession(s.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider)!;
    final isPro = ref.watch(proProvider);
    final sessions = ref.watch(sessionsProvider).value ?? const [];
    final now = DateTime.now();
    final stats = statsFor(sessions, _period, now);
    final streaks = streaksFor(sessions, now);
    final cur = profile.currency;
    final faded = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text('FUCK CORPO INC.\nPAY HISTORY',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            const DashedDivider(),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final p in Period.values)
                ModeChip(
                  label: p.label,
                  selected: _period == p,
                  onTap: () => setState(() => _period = p),
                ),
            ]),
            const SizedBox(height: 16),
            for (final (i, m) in BreakMode.values
                .where((m) => !m.pro || isPro || stats.earnedByMode[m]! > 0)
                .indexed)
              LineItem('Box ${i + 1} · ${m.receiptItem}',
                  money(stats.earnedByMode[m]!, cur)),
            LineItem('Sessions', '${stats.count}'),
            LineItem('Time on the clock, off the job', longDuration(stats.time)),
            if (stats.longest != null)
              LineItem('Longest ${stats.longest!.mode.receiptItem.toLowerCase()}',
                  longDuration(Duration(milliseconds: stats.longest!.durationMs))),
            const DashedDivider(),
            Text('TOTAL RECLAIMED', style: TextStyle(color: faded)),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(money(stats.total, cur),
                  style: const TextStyle(fontSize: 40)),
            ),
            const SizedBox(height: 16),
            LineItem('Current streak', _days(streaks.current)),
            LineItem('Best streak', _days(streaks.best)),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => WrappedScreen(year: now.year))),
              child: Text(now.month == 12
                  ? 'CORPO WRAPPED ${now.year}'
                  : 'PREVIEW CORPO WRAPPED ${now.year}'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ManualLogScreen())),
              child: const Text('+ FILE LATE PAPERWORK'),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => seedFakeYear(ref.read(databaseProvider),
                    profile.rate, DateTime.now()),
                child: const Text('DEBUG: SEED FAKE YEAR'),
              ),
            ],
            const DashedDivider(),
            Text('RECEIPTS  (tap to share, hold to void)',
                style: TextStyle(color: faded)),
            const SizedBox(height: 8),
            if (sessions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No receipts yet. Go take a paid shit.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: faded),
                ),
              ),
            for (final s in sessions)
              ReceiptRow(
                session: s,
                currency: cur,
                onLongPress: () => _void(s),
              ),
          ],
        ),
      ),
    );
  }

  static String _days(int n) => n == 1 ? '1 day' : '$n days';
}

class ReceiptRow extends StatelessWidget {
  const ReceiptRow({
    super.key,
    required this.session,
    required this.currency,
    this.onLongPress,
  });

  final Session session;
  final String currency;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final s = session;
    return InkWell(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ReceiptScreen(session: s))),
      onLongPress: onLongPress,
      child: LineItem(
        '#${s.id.toString().padLeft(6, '0')} '
            '${DateFormat('MMM d').format(s.startedAt).toUpperCase()} '
            '${s.mode.label} ${longDuration(Duration(milliseconds: s.durationMs))}',
        money(s.earned, currency),
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
