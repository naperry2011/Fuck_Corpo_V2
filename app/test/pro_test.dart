import 'package:fcorpo/core/achievements.dart';
import 'package:fcorpo/core/break_mode.dart';
import 'package:fcorpo/core/receipt_styles.dart';
import 'package:fcorpo/data/csv_export.dart';
import 'package:fcorpo/data/database.dart';
import 'package:fcorpo/features/share/share_card.dart';
import 'package:fcorpo/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

var _id = 0;

Session _s(BreakMode mode, {int sec = 300, double earned = 1, DateTime? at}) =>
    Session(
      id: ++_id,
      mode: mode,
      startedAt: at ?? DateTime(2026, 10, 5, 10),
      durationMs: sec * 1000,
      earned: earned,
    );

Set<String> _earned(List<Session> s) =>
    {for (final a in achievements) if (a.test(s)) a.title};

void main() {
  test('free users only get the original three modes', () {
    expect(BreakMode.available(isPro: false),
        [BreakMode.throne, BreakMode.smoke, BreakMode.lunch]);
    expect(BreakMode.available(isPro: true), BreakMode.values);
  });

  test('achievements unlock from session history', () {
    expect(_earned(const []), isEmpty);
    expect(_earned([_s(BreakMode.throne, sec: 45)]),
        {'FIRST DEPOSIT', 'SNIP IT OFF'});
    expect(_earned([_s(BreakMode.lunch, sec: 50 * 60, earned: 120)]),
        {'THREE-COURSE HEIST', 'BIG SPENDER', 'MOGUL'});
    expect(_earned([for (var i = 0; i < 5; i++) _s(BreakMode.smoke)]),
        contains('CHAIN SMOKER'));
    expect(_earned([for (var i = 0; i < 100; i++) _s(BreakMode.smoke, earned: 10)]),
        containsAll(['UNION REP', 'GRAND LARCENY']));
  });

  test('csv export format', () {
    final csv = sessionsToCsv([
      Session(
        id: 7,
        mode: BreakMode.meeting,
        startedAt: DateTime(2026, 10, 5, 14, 30),
        durationMs: 90500,
        earned: 1.23456,
      ),
    ]);
    final lines = csv.trim().split('\n');
    expect(lines.first, 'receipt,mode,started_at,duration_seconds,earned');
    expect(lines[1], '7,FAKE MEETING,2026-10-05T14:30:00.000,91,1.2346');
  });

  test('pro unlock persists and gates receipt styles', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final c = ProviderContainer(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)]);
    addTearDown(c.dispose);

    expect(c.read(proProvider), isFalse);
    await c.read(receiptStyleProvider.notifier).select(ReceiptStyle.gold);
    c.invalidate(receiptStyleProvider);
    expect(c.read(receiptStyleProvider), ReceiptStyle.classic);

    await c.read(proProvider.notifier).unlock();
    expect(c.read(receiptStyleProvider), ReceiptStyle.gold);

    final fresh = ProviderContainer(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)]);
    addTearDown(fresh.dispose);
    expect(fresh.read(proProvider), isTrue);

    await c.read(proProvider.notifier).relock();
    expect(c.read(receiptStyleProvider), ReceiptStyle.classic);
  });

  testWidgets('every receipt style renders without overflow', (tester) async {
    await tester.runAsync(() async {
      final font = FontLoader('CourierPrime')
        ..addFont(rootBundle.load('assets/fonts/CourierPrime-Regular.ttf'))
        ..addFont(rootBundle.load('assets/fonts/CourierPrime-Bold.ttf'));
      await font.load();
    });
    for (final style in ReceiptStyle.values) {
      await tester.pumpWidget(MaterialApp(
        home: Center(
          child: ShareCard(
            session: _s(BreakMode.coffee, sec: 1800, earned: 9876.54),
            currency: r'$',
            bossName: 'Maximilian Von Boss',
            roast: 'The CEO\'s yacht is now 0.0001% smaller. Legend.',
            style: style,
          ),
        ),
      ));
      expect(tester.takeException(), isNull, reason: style.name);
    }
  });
}
