import 'package:flutter/material.dart';

import '../../core/takeover.dart';
import '../../widgets/payslip_parts.dart';

/// Bottom sheet asking which business is being acquired. Pops with a
/// [TakeoverTarget], or null if dismissed.
class TakeoverSheet extends StatefulWidget {
  const TakeoverSheet({super.key, this.initial});

  final TakeoverTarget? initial;

  static Future<TakeoverTarget?> open(BuildContext context,
          {TakeoverTarget? initial}) =>
      showModalBottomSheet<TakeoverTarget>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(),
        builder: (_) => TakeoverSheet(initial: initial),
      );

  @override
  State<TakeoverSheet> createState() => _TakeoverSheetState();
}

class _TakeoverSheetState extends State<TakeoverSheet> {
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
  late BusinessCategory _category =
      widget.initial?.category ?? BusinessCategory.coffee;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    final name = TakeoverTarget.cleanName(_name.text);
    if (name == null) {
      setState(() => _error = "Name the company you're acquiring.");
      return;
    }
    Navigator.of(context)
        .pop(TakeoverTarget(name: name, category: _category));
  }

  @override
  Widget build(BuildContext context) {
    final faded = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('HOSTILE TAKEOVER\nACQUISITION FORM',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
          const DashedDivider(),
          TextField(
            controller: _name,
            autofocus: true,
            maxLength: TakeoverTarget.maxNameLength,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: 'TARGET COMPANY',
              hintText: 'Starbucks, 5th Ave',
              errorText: _error,
              counterText: '',
            ),
          ),
          const SizedBox(height: 16),
          Text('INDUSTRY', style: TextStyle(color: faded)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final c in BusinessCategory.values)
              ModeChip(
                label: c.label,
                selected: _category == c,
                onTap: () => setState(() => _category = c),
              ),
          ]),
          const SizedBox(height: 24),
          FilledButton(
              onPressed: _submit, child: const Text('PLANT THE FLAG')),
        ],
      ),
    );
  }
}
