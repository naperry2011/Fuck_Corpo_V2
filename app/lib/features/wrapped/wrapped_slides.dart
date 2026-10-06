import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../copy/roasts.dart';
import '../../core/break_mode.dart';
import '../../core/format.dart';
import '../../core/pay_profile.dart';
import '../../core/receipt_styles.dart';
import '../../core/wrapped.dart';
import '../../widgets/payslip_parts.dart';
import '../../widgets/pixel_ceo.dart';
import '../share/share_card.dart';

String _hours(Duration d) {
  final h = d.inMinutes / 60;
  if (h < 1) return '${d.inMinutes} min';
  return '${h.toStringAsFixed(h < 10 ? 1 : 0)} hours';
}

String _ceoTime(double amount) {
  final seconds = amount / ceoPerSecond;
  if (seconds < 120) return '${seconds.toStringAsFixed(seconds < 10 ? 1 : 0)} SECONDS';
  final minutes = seconds / 60;
  if (minutes < 120) return '${minutes.round()} MINUTES';
  return '${(minutes / 60).toStringAsFixed(1)} HOURS';
}

List<Widget> buildWrappedSlides(WrappedStats w, PayProfile profile,
    {ReceiptStyle style = ReceiptStyle.classic}) {
  final cur = profile.currency;
  final form = 'FORM W-2(ish) · ${w.year}';

  if (w.isEmpty) {
    return [
      _Slide(
        style: style,
        form: form,
        kicker: 'NO THEFT ON RECORD',
        headline: money(0, cur),
        body: 'Corpo thanks you for your loyal service. Disgusting.',
        extra: const PixelCeo(anger: 0, size: 72),
      ),
    ];
  }

  final throneCount = w.countByMode[BreakMode.throne]!;
  final richest = w.richest!;
  final top = w.topMode;

  final slides = <Widget Function(String box)>[
    (box) => _Slide(
          style: style,
          form: form,
          box: box,
          kicker: 'FUCK CORPO',
          headline: 'WRAPPED\n${w.year}',
          body: 'A year of stealing your time back. Audited by nobody.',
          extra: const Stamp('CONFIDENTIAL', fontSize: 16),
        ),
    (box) => _Slide(
          style: style,
          form: form,
          box: box,
          kicker: 'TOTAL RECLAIMED',
          headline: money(w.total, cur),
          body: 'Paid to not work across ${w.count} sessions and '
              '${_hours(w.time)} on the clock, off the job.',
          extra: const PixelCeo(anger: 3, size: 72),
        ),
    (box) => _Slide(
          style: style,
          form: form,
          box: box,
          kicker: 'THRONE REPORT',
          headline: throneCount == 1 ? '1 DUMP' : '$throneCount DUMPS',
          body: throneCount == 0
              ? 'Not one paid dump all year? Who hurt you?'
              : '${_hours(w.timeByMode[BreakMode.throne]!)} on the toilet. '
                  'Corpo paid ${money(w.earnedByMode[BreakMode.throne]!, cur)} for it.',
        ),
    (box) => _Slide(
          style: style,
          form: form,
          box: box,
          kicker: 'YOUR SIGNATURE MOVE',
          headline: top.label,
          body: '${(w.topModeShare * 100).round()}% of your stolen wages came '
              'from the ${top.receiptItem.toLowerCase()}.',
        ),
    (box) => _Slide(
          style: style,
          form: form,
          box: box,
          kicker: 'MOST EXPENSIVE ${richest.mode.label}',
          headline: money(richest.earned, cur),
          body: '${DateFormat('MMM d').format(richest.startedAt).toUpperCase()}. '
              '${longDuration(Duration(milliseconds: richest.durationMs))}. '
              '${profile.bossName} never noticed.',
          extra: const Stamp('PAID IN FULL', fontSize: 15),
        ),
    (box) => _Slide(
          style: style,
          form: form,
          box: box,
          kicker: 'PEAK SLACKING SEASON',
          headline: DateFormat('MMMM')
              .format(DateTime(w.year, w.busiestMonth!))
              .toUpperCase(),
          body: '${money(w.busiestMonthEarned, cur)} reclaimed in one month. '
              'Productivity reports were... creative.',
        ),
    (box) => _Slide(
          style: style,
          form: form,
          box: box,
          kicker: 'LONGEST STREAK',
          headline: w.bestStreak == 1 ? '1 DAY' : '${w.bestStreak} DAYS',
          body: 'Days in a row of taking it back. Unbroken. Unbothered.',
        ),
    (box) => _Slide(
          style: style,
          form: form,
          box: box,
          kicker: 'MEANWHILE',
          headline: _ceoTime(w.total),
          body: 'How long a CEO on a ${money(20000000, cur, decimals: 0)} '
              'package takes to make your ${money(w.total, cur)}. '
              'Still worth it.',
          extra: const PixelCeo(anger: 1, size: 72),
        ),
    (box) => _Summary(w: w, cur: cur, form: form, style: style),
  ];

  return [
    for (final (i, build) in slides.indexed)
      build('BOX ${i + 1} OF ${slides.length}'),
  ];
}

class _Slide extends StatelessWidget {
  const _Slide({
    required this.form,
    required this.style,
    required this.kicker,
    required this.headline,
    required this.body,
    this.box,
    this.extra,
  });

  final String form;
  final ReceiptStyle style;
  final String? box;
  final String kicker;
  final String headline;
  final String body;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return ReceiptFrame(
      style: style,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(box == null ? form : '$form\n$box',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11.5)),
          const DashedDivider(),
          const Spacer(),
          Text(kicker,
              style: TextStyle(
                  color: style.faded, letterSpacing: 1.5)),
          const SizedBox(height: 6),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(headline,
                style: const TextStyle(
                    fontSize: 40, fontWeight: FontWeight.bold, height: 1.05)),
          )
              .animate()
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.25, curve: Curves.easeOutCubic),
          const SizedBox(height: 10),
          Text(body, style: const TextStyle(fontSize: 13.5, height: 1.35))
              .animate()
              .fadeIn(delay: 250.ms, duration: 350.ms),
          const Spacer(),
          if (extra != null)
            Center(child: extra!)
                .animate()
                .fadeIn(delay: 450.ms)
                .scale(begin: const Offset(1.3, 1.3), curve: Curves.easeOutBack),
          const Spacer(),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.w,
    required this.cur,
    required this.form,
    required this.style,
  });

  final WrappedStats w;
  final String cur;
  final String form;
  final ReceiptStyle style;

  @override
  Widget build(BuildContext context) {
    final longest = w.longest!;
    return ReceiptFrame(
      style: style,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('$form\nWAGES STOLEN BACK',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11.5)),
          const DashedDivider(),
          for (final (i, m) in BreakMode.values
              .where((m) => !m.pro || w.earnedByMode[m]! > 0)
              .indexed)
            LineItem('Box ${i + 1} · ${m.label.toLowerCase()}',
                money(w.earnedByMode[m]!, cur)),
          LineItem('Hours on the clock, off the job',
              (w.time.inMinutes / 60).toStringAsFixed(1)),
          LineItem('Longest ${longest.mode.receiptItem.toLowerCase()}',
              longDuration(Duration(milliseconds: longest.durationMs))),
          const DashedDivider(),
          const Text('TOTAL RECLAIMED'),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(money(w.total, cur),
                style: const TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold)),
          ),
          const Spacer(),
          const Center(
            child: Stamp('AUDITED BY NOBODY', angle: 0.1, fontSize: 14),
          ).animate().fadeIn(delay: 300.ms).scale(
              begin: const Offset(1.4, 1.4), curve: Curves.easeOutBack),
          const Spacer(),
        ],
      ),
    );
  }
}
