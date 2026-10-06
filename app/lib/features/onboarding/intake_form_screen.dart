import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/pay_profile.dart';
import '../../core/rate.dart';
import '../../state/providers.dart';
import '../../widgets/payslip_parts.dart';

const _currencies = [r'$', '€', '£'];

class IntakeFormScreen extends ConsumerStatefulWidget {
  const IntakeFormScreen({super.key, this.editing = false});

  final bool editing;

  @override
  ConsumerState<IntakeFormScreen> createState() => _IntakeFormScreenState();
}

class _IntakeFormScreenState extends ConsumerState<IntakeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late PayType _type;
  late String _currency;
  late final TextEditingController _amount;
  late final TextEditingController _hours;
  late final TextEditingController _boss;

  @override
  void initState() {
    super.initState();
    final p = ref.read(profileProvider);
    _type = p?.type ?? PayType.hourly;
    _currency = p?.currency ?? r'$';
    _amount = TextEditingController(text: p == null ? '' : _trim(p.amount));
    _hours = TextEditingController(
        text: p == null ? '40' : _trim(p.hoursPerWeek));
    _boss = TextEditingController(
        text: p == null || p.bossName == 'the boss' ? '' : p.bossName);
  }

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  @override
  void dispose() {
    _amount.dispose();
    _hours.dispose();
    _boss.dispose();
    super.dispose();
  }

  String? _positive(String? v, {double max = double.infinity}) {
    final n = double.tryParse(v ?? '');
    if (n == null || n <= 0) return 'Put a real number in, champ.';
    if (n > max) return 'There are only 168 hours in a week.';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final boss = _boss.text.trim();
    await ref.read(profileProvider.notifier).save(PayProfile(
          type: _type,
          amount: double.parse(_amount.text),
          hoursPerWeek: double.parse(_hours.text),
          currency: _currency,
          bossName: boss.isEmpty ? 'the boss' : boss,
        ));
    if (widget.editing && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final faded = Theme.of(context).colorScheme.onSurfaceVariant;
    final numberInput = [
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
    ];
    return Scaffold(
      appBar: widget.editing ? AppBar() : null,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text('FUCK CORPO INC.\nEMPLOYEE INTAKE FORM',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
              const DashedDivider(),
              Text('PAY TYPE', style: TextStyle(color: faded)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [
                for (final t in PayType.values)
                  ModeChip(
                    label: t.name.toUpperCase(),
                    selected: _type == t,
                    onTap: () => setState(() => _type = t),
                  ),
              ]),
              const SizedBox(height: 20),
              Text('CURRENCY', style: TextStyle(color: faded)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [
                for (final c in _currencies)
                  ModeChip(
                    label: c,
                    selected: _currency == c,
                    onTap: () => setState(() => _currency = c),
                  ),
              ]),
              const SizedBox(height: 20),
              TextFormField(
                controller: _amount,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: numberInput,
                validator: _positive,
                decoration: InputDecoration(
                  labelText: "WAGE THEY THINK YOU'RE WORTH",
                  prefixText: '$_currency ',
                  suffixText: _type == PayType.hourly ? '/ hr' : '/ yr',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hours,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: numberInput,
                validator: (v) => _positive(v, max: 168),
                decoration: const InputDecoration(
                  labelText: 'HOURS YOU GIVE THESE BASTARDS',
                  suffixText: '/ week',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _boss,
                textCapitalization: TextCapitalization.words,
                maxLength: 24,
                decoration: const InputDecoration(
                  labelText: "BOSS'S NAME (FOR ROASTING)",
                  counterText: '',
                ),
              ),
              const SizedBox(height: 12),
              Text('Stored on your phone only. HR will never know.',
                  style: TextStyle(color: faded, fontSize: 12)),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _submit,
                child: Text(widget.editing ? 'AMEND PAPERWORK' : 'SIGN AWAY NOTHING'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
