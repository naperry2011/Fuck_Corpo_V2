import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:fcorpo/core/achievements.dart';
import 'package:fcorpo/core/break_mode.dart';
import 'package:fcorpo/core/pay_profile.dart';
import 'package:fcorpo/core/portfolio.dart';
import 'package:fcorpo/core/rate.dart';
import 'package:fcorpo/core/receipt_styles.dart';
import 'package:fcorpo/core/takeover.dart';
import 'package:fcorpo/core/wrapped.dart';
import 'package:fcorpo/data/database.dart';
import 'package:fcorpo/features/share/share_card.dart';
import 'package:fcorpo/features/wrapped/wrapped_slides.dart';
import 'package:fcorpo/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

var _id = 0;

Session _t(
  String name,
  BusinessCategory c, {
  int min = 5,
  double damages = 0.2,
  DateTime? at,
}) => Session(
  id: ++_id,
  mode: BreakMode.throne,
  startedAt: at ?? DateTime(2026, 10, 1 + _id % 20, 10),
  durationMs: min * 60000,
  earned: 1,
  businessName: name,
  businessCategory: c,
  damages: damages,
);

const _profile = PayProfile(
  type: PayType.hourly,
  amount: 36,
  hoursPerWeek: 40,
  currency: r'$',
  bossName: 'Karen',
);

Future<void> _loadFont() async {
  final font = FontLoader('CourierPrime')
    ..addFont(rootBundle.load('assets/fonts/CourierPrime-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/CourierPrime-Bold.ttf'));
  await font.load();
}

void main() {
  group('damages', () {
    test('short visit is one flush and costs cents', () {
      final d = Damages(const Duration(minutes: 3));
      expect(d.flushes, 1);
      expect(d.lines, hasLength(5));
      expect(d.total, inInclusiveRange(0.05, 0.25));
    });

    test('long visit adds a flush and scales up', () {
      final short = Damages(const Duration(minutes: 3)).total;
      final long = Damages(const Duration(minutes: 20));
      expect(long.flushes, 2);
      expect(long.total, greaterThan(short));
      expect(
        long.total,
        closeTo(long.lines.fold<double>(0, (a, l) => a + l.amount), 1e-12),
      );
    });
  });

  test('target names are trimmed, collapsed, and capped', () {
    expect(TakeoverTarget.cleanName('   '), isNull);
    expect(TakeoverTarget.cleanName('  Star   bucks '), 'Star bucks');
    expect(TakeoverTarget.cleanName('x' * 60), hasLength(40));
  });

  test('portfolio groups case-insensitively and ranks by visits', () {
    final p = Portfolio.from([
      _t('Starbucks', BusinessCategory.coffee, at: DateTime(2026, 1, 1)),
      _t('starbucks', BusinessCategory.coffee),
      _t('STARBUCKS', BusinessCategory.coffee),
      _t('Target', BusinessCategory.bigBox),
      Session(
        id: 999,
        mode: BreakMode.smoke,
        startedAt: DateTime(2026, 2, 1),
        durationMs: 1000,
        earned: 1,
      ),
    ]);
    expect(p.companies, 2);
    expect(p.takeovers, 4);
    expect(p.favorite!.name, 'Starbucks');
    expect(p.favorite!.takeovers, 3);
    expect(p.damages, closeTo(0.8, 1e-9));
    expect(p.byCategory[BusinessCategory.coffee], 3);
    expect(p.byCategory[BusinessCategory.bank], 0);
  });

  test('takeover achievements', () {
    Set<String> earned(List<Session> s) => {
      for (final a in achievements)
        if (a.test(s)) a.title,
    };

    expect(
      earned([_t('Chase', BusinessCategory.bank)]),
      containsAll(['HOSTILE TAKEOVER', 'BANK RUN']),
    );
    expect(
      earned([
        for (final n in ['A', 'B', 'C', 'D', 'E'])
          _t(n, BusinessCategory.coffee),
      ]),
      contains('FRANCHISE TOUR'),
    );
    expect(
      earned([
        for (var i = 0; i < 5; i++) _t('Target', BusinessCategory.bigBox),
      ]),
      contains('REPEAT OFFENDER'),
    );
    expect(
      earned([
        for (var i = 0; i < 10; i++) _t('Co $i', BusinessCategory.other),
      ]),
      contains('FORTUNE 500'),
    );
    expect(achievements, hasLength(15));
  });

  test('takeover target survives restart and is saved with damages', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase(NativeDatabase.memory());
    final c = ProviderContainer(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
      ],
    );
    addTearDown(() async {
      c.dispose();
      await db.close();
    });
    await c.read(profileProvider.notifier).save(_profile);

    const target = TakeoverTarget(
      name: 'Starbucks',
      category: BusinessCategory.coffee,
    );
    await c
        .read(activeSessionProvider.notifier)
        .start(BreakMode.throne, target: target);
    expect(c.read(settingsProvider).loadActive()?.target?.name, 'Starbucks');

    final session = await c.read(activeSessionProvider.notifier).stop();
    expect(session.businessName, 'Starbucks');
    expect(session.businessCategory, BusinessCategory.coffee);
    expect(session.damages, isNotNull);
    expect(c.read(settingsProvider).loadActive(), isNull);

    await c
        .read(activeSessionProvider.notifier)
        .start(BreakMode.smoke, target: target);
    final smoke = await c.read(activeSessionProvider.notifier).stop();
    expect(smoke.businessName, isNull, reason: 'takeovers are throne-only');
  });

  test('upgrading a v1 database keeps old sessions', () async {
    final db = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          if (raw.userVersion != 0) return;
          raw.execute(
            'CREATE TABLE "sessions" ('
            '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
            '"mode" TEXT NOT NULL, "started_at" INTEGER NOT NULL, '
            '"duration_ms" INTEGER NOT NULL, "earned" REAL NOT NULL)',
          );
          raw.execute(
            "INSERT INTO sessions (mode, started_at, duration_ms, earned) "
            "VALUES ('throne', 1759700000, 45000, 0.31)",
          );
          raw.userVersion = 1;
        },
      ),
    );
    addTearDown(db.close);

    final rows = await db.select(db.sessions).get();
    expect(rows, hasLength(1));
    expect(rows.single.earned, 0.31);
    expect(rows.single.businessName, isNull);

    final added = await db.addSession(
      SessionsCompanion.insert(
        mode: BreakMode.throne,
        startedAt: DateTime(2026, 10, 25),
        durationMs: 60000,
        earned: 1,
        businessName: const Value('Target'),
        businessCategory: const Value(BusinessCategory.bigBox),
        damages: const Value(0.12),
      ),
    );
    expect(added.businessCategory, BusinessCategory.bigBox);
  });

  testWidgets('invoice card fits in every receipt style', (tester) async {
    await tester.runAsync(_loadFont);
    final s = _t(
      'Maximilian Von Corporation Intl Holdings',
      BusinessCategory.hotel,
      min: 45,
      damages: 1.23,
    );
    for (final style in ReceiptStyle.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: InvoiceCard(
              session: s,
              currency: r'$',
              roast:
                  'You left a deposit. They left no receipt. Now they have one.',
              style: style,
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull, reason: style.name);
    }
  });

  testWidgets('wrapped adds a takeover slide that renders', (tester) async {
    await tester.runAsync(_loadFont);
    final sessions = [
      _t('Starbucks', BusinessCategory.coffee, at: DateTime(2026, 3, 1)),
      _t('Target', BusinessCategory.bigBox, at: DateTime(2026, 3, 2)),
    ];
    final withTakeovers = buildWrappedSlides(
      WrappedStats.from(sessions, 2026),
      _profile,
    );
    final plain = buildWrappedSlides(
      WrappedStats.from([
        for (final s in sessions)
          s.copyWith(
            businessName: const Value(null),
            businessCategory: const Value(null),
            damages: const Value(null),
          ),
      ], 2026),
      _profile,
    );
    expect(withTakeovers.length, plain.length + 1);
    for (final slide in withTakeovers) {
      await tester.pumpWidget(MaterialApp(home: Center(child: slide)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
