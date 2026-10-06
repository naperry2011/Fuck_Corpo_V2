import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../copy/roasts.dart';
import '../../core/break_mode.dart';
import '../../core/format.dart';
import '../../core/stats.dart';
import '../../state/providers.dart';
import '../../widgets/payslip_parts.dart';
import '../../widgets/pixel_ceo.dart';
import '../ledger/ledger_screen.dart';
import '../onboarding/intake_form_screen.dart';
import '../pro/paywall_screen.dart';
import '../receipt/receipt_screen.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  BreakMode _selected = BreakMode.throne;
  Timer? _ticker;
  int _lastAnger = -1;
  String _quote = '';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _syncTicker(ref.read(activeSessionProvider) != null);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _syncTicker(bool active) {
    if (active && _ticker == null) {
      _ticker = Timer.periodic(
          const Duration(milliseconds: 100), (_) => setState(() {}));
    } else if (!active && _ticker != null) {
      _ticker!.cancel();
      _ticker = null;
    }
  }

  Future<void> _clockIn() async {
    setState(() => _busy = true);
    await ref
        .read(activeSessionProvider.notifier)
        .start(_effective(_selected, ref.read(proProvider)));
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _clockOut() async {
    setState(() => _busy = true);
    final session = await ref.read(activeSessionProvider.notifier).stop();
    if (!mounted) return;
    setState(() => _busy = false);
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReceiptScreen(session: session)),
    );
  }

  /// Falls back to the throne if Pro was revoked while a Pro mode was picked.
  static BreakMode _effective(BreakMode m, bool isPro) =>
      m.pro && !isPro ? BreakMode.throne : m;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider)!;
    final active = ref.watch(activeSessionProvider);
    final isPro = ref.watch(proProvider);
    ref.listen(activeSessionProvider, (_, next) => _syncTicker(next != null));

    final mode = active?.mode ?? _effective(_selected, isPro);
    var elapsed = active == null
        ? Duration.zero
        : DateTime.now().difference(active.startedAt);
    if (elapsed.isNegative) elapsed = Duration.zero;
    final earned = profile.rate.earned(elapsed);
    final anger = angerFor(earned);
    if (anger != _lastAnger) {
      _lastAnger = anger;
      _quote = pick(ceoQuotes[anger]);
    }

    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text('MODE: ${mode.label}')),
                  Text(clock(elapsed)),
                  IconButton(
                    tooltip: 'Edit paperwork',
                    icon: const Icon(Icons.edit_note),
                    onPressed: active != null
                        ? null
                        : () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) =>
                                const IntakeFormScreen(editing: true))),
                  ),
                ],
              ),
              const DashedDivider(),
              Center(child: PixelCeo(anger: anger, size: 128)),
              const SizedBox(height: 8),
              Text(_quote,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.secondary)),
              const DashedDivider(),
              Text(mode.earnedHeadline),
              FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(
                  money(earned, profile.currency, decimals: 4),
                  style: const TextStyle(fontSize: 44),
                ),
              ),
              Text(
                '+${money(profile.rate.perSecond, profile.currency, decimals: 4)} every second',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final m in BreakMode.values)
                    ModeChip(
                      label: m.label,
                      selected: m == mode,
                      locked: m.pro && !isPro,
                      onTap: active != null
                          ? null
                          : m.pro && !isPro
                              ? () => PaywallScreen.open(context)
                              : () => setState(() => _selected = m),
                    ),
                ],
              ),
              const DashedDivider(),
              const Expanded(child: _TodayPanel()),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _busy
                    ? null
                    : active == null
                        ? _clockIn
                        : _clockOut,
                child: Text(active == null ? 'CLOCK IN' : 'CLOCK OUT'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayPanel extends ConsumerWidget {
  const _TodayPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cur = ref.watch(profileProvider)!.currency;
    final sessions = ref.watch(sessionsProvider).value ?? const [];
    final today = statsFor(sessions, Period.today, DateTime.now());
    final todays = sessions.take(today.count).take(3).toList();
    final faded = Theme.of(context).colorScheme.onSurfaceVariant;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        LineItem("TODAY'S TAKE", money(today.total, cur),
            style: const TextStyle(fontSize: 18)),
        LineItem('Sessions', '${today.count}',
            style: TextStyle(color: faded)),
        const SizedBox(height: 8),
        if (todays.isEmpty)
          Text('Nothing stolen back yet today. Disgraceful.',
              style: TextStyle(color: faded, fontSize: 13))
        else
          for (final s in todays) ReceiptRow(session: s, currency: cur),
      ],
    );
  }
}
