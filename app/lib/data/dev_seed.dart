import 'dart:math';

import 'package:drift/drift.dart' show Value;

import '../core/break_mode.dart';
import '../core/rate.dart';
import '../core/takeover.dart';
import 'database.dart';

/// Debug-only: fills the database with a plausible year of workday breaks so
/// Wrapped and the ledger can be previewed without months of real use.
Future<void> seedFakeYear(AppDatabase db, PayRate rate, DateTime now) async {
  final rng = Random(42);
  const ranges = {
    BreakMode.throne: (3, 20),
    BreakMode.smoke: (4, 10),
    BreakMode.lunch: (15, 45),
  };
  // Made-up names: these end up in store screenshots.
  const targets = [
    TakeoverTarget(name: 'Beanery on 5th', category: BusinessCategory.coffee),
    TakeoverTarget(name: 'Daily Grind Cafe', category: BusinessCategory.coffee),
    TakeoverTarget(name: 'MegaMart Superstore', category: BusinessCategory.bigBox),
    TakeoverTarget(name: 'First Vault Bank', category: BusinessCategory.bank),
    TakeoverTarget(name: 'Grand Plaza Hotel', category: BusinessCategory.hotel),
    TakeoverTarget(name: 'Burger Barn', category: BusinessCategory.fastFood),
  ];
  final rows = <SessionsCompanion>[];
  for (var day = DateTime(now.year);
      day.isBefore(DateTime(now.year, now.month, now.day));
      day = DateTime(day.year, day.month, day.day + 1)) {
    if (day.weekday > DateTime.friday || rng.nextDouble() < 0.15) continue;
    final breaks = 1 + rng.nextInt(3);
    for (var i = 0; i < breaks; i++) {
      final mode = ranges.keys.elementAt(rng.nextInt(ranges.length));
      final (lo, hi) = ranges[mode]!;
      final duration =
          Duration(minutes: lo + rng.nextInt(hi - lo + 1), seconds: rng.nextInt(60));
      final isTakeover = mode == BreakMode.throne && rng.nextDouble() < 0.2;
      final target = isTakeover ? targets[rng.nextInt(targets.length)] : null;
      rows.add(SessionsCompanion.insert(
        mode: mode,
        startedAt: day.add(Duration(hours: 9 + rng.nextInt(8), minutes: rng.nextInt(60))),
        durationMs: duration.inMilliseconds,
        earned: rate.earned(duration),
        businessName: Value(target?.name),
        businessCategory: Value(target?.category),
        damages: Value(target == null ? null : Damages(duration).total),
      ));
    }
  }
  await db.batch((b) => b.insertAll(db.sessions, rows));
}
