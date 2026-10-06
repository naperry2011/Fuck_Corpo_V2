import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/break_mode.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../state/providers.dart';
import '../../widgets/payslip_parts.dart';
import '../pro/paywall_screen.dart';

class ManualLogScreen extends ConsumerStatefulWidget {
  const ManualLogScreen({super.key});

  @override
  ConsumerState<ManualLogScreen> createState() => _ManualLogScreenState();
}

class _ManualLogScreenState extends ConsumerState<ManualLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _minutes = TextEditingController(text: '10');
  BreakMode _mode = BreakMode.throne;
  late DateTime _when;
  String? _whenError;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _when = DateTime(now.year, now.month, now.day, now.hour, now.minute)
        .subtract(const Duration(hours: 1));
  }

  @override
  void dispose() {
    _minutes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _when,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() => _when = DateTime(
        picked.year, picked.month, picked.day, _when.hour, _when.minute));
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(_when));
    if (picked == null) return;
    setState(() => _when = DateTime(
        _when.year, _when.month, _when.day, picked.hour, picked.minute));
  }

  Future<void> _submit() async {
    final future = _when.isAfter(DateTime.now());
    setState(() =>
        _whenError = future ? "Can't log a dump you haven't taken yet." : null);
    if (!_formKey.currentState!.validate() || future) return;

    final duration = Duration(minutes: int.parse(_minutes.text));
    final rate = ref.read(profileProvider)!.rate;
    await ref.read(databaseProvider).addSession(SessionsCompanion.insert(
          mode: _mode,
          startedAt: _when,
          durationMs: duration.inMilliseconds,
          earned: rate.earned(duration),
        ));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider)!;
    final isPro = ref.watch(proProvider);
    final scheme = Theme.of(context).colorScheme;
    final minutes = int.tryParse(_minutes.text) ?? 0;
    final preview = profile.rate.earned(Duration(minutes: minutes));

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            children: [
              const Text('LATE PAPERWORK\nFORM 69-B',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
              const DashedDivider(),
              Text('TYPE OF THEFT',
                  style: TextStyle(color: scheme.onSurfaceVariant)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final m in BreakMode.values)
                  ModeChip(
                    label: m.label,
                    selected: _mode == m,
                    locked: m.pro && !isPro,
                    onTap: m.pro && !isPro
                        ? () => PaywallScreen.open(context)
                        : () => setState(() => _mode = m),
                  ),
              ]),
              const SizedBox(height: 20),
              Text('WHEN IT WENT DOWN',
                  style: TextStyle(color: scheme.onSurfaceVariant)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickDate,
                    child: Text(
                        DateFormat('MMM d, y').format(_when).toUpperCase()),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickTime,
                    child: Text(DateFormat('h:mm a').format(_when)),
                  ),
                ),
              ]),
              if (_whenError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(_whenError!,
                      style: TextStyle(color: scheme.error, fontSize: 12)),
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _minutes,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1) return 'At least a minute, come on.';
                  if (n > 480) return "Over 8 hours? That's a career, not a break.";
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'HOW LONG',
                  suffixText: 'minutes',
                ),
              ),
              const DashedDivider(),
              LineItem('1x ${_mode.receiptItem}',
                  money(preview, profile.currency),
                  style: const TextStyle(fontSize: 18)),
              Text('At your current rate.',
                  style:
                      TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
              const SizedBox(height: 32),
              FilledButton(onPressed: _submit, child: const Text('FILE IT')),
            ],
          ),
        ),
      ),
    );
  }
}
