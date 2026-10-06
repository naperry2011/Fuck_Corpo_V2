import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../copy/roasts.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../state/providers.dart';
import '../share/share_card.dart';
import '../share/share_service.dart';

class ReceiptScreen extends ConsumerStatefulWidget {
  const ReceiptScreen({super.key, required this.session});

  final Session session;

  @override
  ConsumerState<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends ConsumerState<ReceiptScreen> {
  final _cardKey = GlobalKey();
  late final String _roast =
      receiptRoast(widget.session.mode, isPro: ref.read(proProvider));
  bool _sharing = false;

  Future<void> _share() async {
    setState(() => _sharing = true);
    try {
      final boundary = _cardKey.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
      final file = await captureCard(
          boundary, 'fuck-corpo-receipt-${widget.session.id}');
      await shareCardImage(file, text: shareCaption);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Couldn't print the receipt. Try again.")));
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider)!;
    final s = widget.session;
    final ceoMade = ceoPerSecond * s.durationMs / 1000;
    final cur = profile.currency;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          children: [
            FittedBox(
              child: RepaintBoundary(
                key: _cardKey,
                child: ShareCard(
                  session: s,
                  currency: cur,
                  bossName: profile.bossName,
                  roast: _roast,
                  style: ref.watch(receiptStyleProvider),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'A CEO on a ${money(20000000, cur, decimals: 0)} package made '
              '${money(ceoMade, cur)} in that time. You still won.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _sharing ? null : _share,
              icon: const Icon(Icons.ios_share),
              label: const Text('SHARE RECEIPT'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("BACK TO 'WORK'"),
            ),
          ],
        ),
      ),
    );
  }
}
