import 'dart:math';

import '../core/break_mode.dart';
import '../core/rate.dart';
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
      rows.add(SessionsCompanion.insert(
        mode: mode,
        startedAt: day.add(Duration(hours: 9 + rng.nextInt(8), minutes: rng.nextInt(60))),
        durationMs: duration.inMilliseconds,
        earned: rate.earned(duration),
      ));
    }
  }
  await db.batch((b) => b.insertAll(db.sessions, rows));
}
