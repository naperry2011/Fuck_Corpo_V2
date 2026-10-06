import 'package:fcorpo/core/break_mode.dart';
import 'package:fcorpo/core/pay_profile.dart';
import 'package:fcorpo/core/rate.dart';
import 'package:fcorpo/core/wrapped.dart';
import 'package:fcorpo/data/database.dart';
import 'package:fcorpo/features/wrapped/wrapped_slides.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

var _id = 0;

Session _s(DateTime at, BreakMode mode, int min, double earned) => Session(
      id: ++_id,
      mode: mode,
      startedAt: at,
      durationMs: min * 60000,
      earned: earned,
    );

final _sessions = [
  _s(DateTime(2026, 3, 2, 10), BreakMode.throne, 12, 4.0),
  _s(DateTime(2026, 3, 3, 10), BreakMode.throne, 8, 3.0),
  _s(DateTime(2026, 3, 4, 12), BreakMode.lunch, 40, 15.0),
  _s(DateTime(2026, 7, 1, 15), BreakMode.smoke, 6, 2.5),
  _s(DateTime(2025, 12, 30, 9), BreakMode.lunch, 60, 99.0),
];

const _profile = PayProfile(
  type: PayType.salary,
  amount: 250000,
  hoursPerWeek: 40,
  currency: r'$',
  bossName: 'Maximilian Von Boss',
);

void main() {
  test('stats only count the requested year', () {
    final w = WrappedStats.from(_sessions, 2026);
    expect(w.count, 4);
    expect(w.total, 24.5);
    expect(w.countByMode[BreakMode.throne], 2);
    expect(w.timeByMode[BreakMode.throne], const Duration(minutes: 20));
    expect(w.topMode, BreakMode.lunch);
    expect(w.topModeShare, closeTo(15 / 24.5, 1e-9));
    expect(w.longest!.durationMs, 40 * 60000);
    expect(w.richest!.earned, 15.0);
    expect(w.busiestMonth, 3);
    expect(w.busiestMonthEarned, 22.0);
    expect(w.bestStreak, 3);
  });

  test('empty year', () {
    final w = WrappedStats.from(_sessions, 2024);
    expect(w.isEmpty, isTrue);
    expect(w.busiestMonth, isNull);
    expect(buildWrappedSlides(w, _profile), hasLength(1));
  });

  testWidgets('every slide renders without overflow', (tester) async {
    await tester.runAsync(() async {
      final font = FontLoader('CourierPrime')
        ..addFont(rootBundle.load('assets/fonts/CourierPrime-Regular.ttf'))
        ..addFont(rootBundle.load('assets/fonts/CourierPrime-Bold.ttf'));
      await font.load();
    });
    final big = [
      ..._sessions,
      _s(DateTime(2026, 8, 1, 9), BreakMode.lunch, 480, 123456.78),
    ];
    for (final year in [2026, 2024]) {
      final slides = buildWrappedSlides(WrappedStats.from(big, year), _profile);
      for (final slide in slides) {
        await tester.pumpWidget(MaterialApp(home: Center(child: slide)));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    }
  });
}
