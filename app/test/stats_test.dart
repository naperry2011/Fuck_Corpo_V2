import 'package:fcorpo/core/break_mode.dart';
import 'package:fcorpo/core/stats.dart';
import 'package:fcorpo/data/database.dart';
import 'package:flutter_test/flutter_test.dart';

var _id = 0;

Session _s(DateTime at, {BreakMode mode = BreakMode.throne, int min = 5}) =>
    Session(
      id: ++_id,
      mode: mode,
      startedAt: at,
      durationMs: min * 60000,
      earned: min * 0.5,
    );

void main() {
  // Wednesday
  final now = DateTime(2026, 10, 7, 15);

  test('period starts', () {
    expect(Period.today.start(now), DateTime(2026, 10, 7));
    expect(Period.week.start(now), DateTime(2026, 10, 5));
    expect(Period.month.start(now), DateTime(2026, 10, 1));
    expect(Period.year.start(now), DateTime(2026, 1, 1));
  });

  test('totals split by mode and respect period', () {
    final sessions = [
      _s(DateTime(2026, 10, 7, 9), min: 10),
      _s(DateTime(2026, 10, 6, 12), mode: BreakMode.lunch, min: 30),
      _s(DateTime(2026, 9, 30, 12), mode: BreakMode.smoke),
    ];
    final today = statsFor(sessions, Period.today, now);
    expect(today.count, 1);
    expect(today.total, 5);

    final week = statsFor(sessions, Period.week, now);
    expect(week.count, 2);
    expect(week.earnedByMode[BreakMode.lunch], 15);
    expect(week.earnedByMode[BreakMode.smoke], 0);
    expect(week.longest?.mode, BreakMode.lunch);
    expect(week.time, const Duration(minutes: 40));

    expect(statsFor(sessions, Period.year, now).count, 3);
  });

  test('empty period has no longest', () {
    expect(statsFor(const [], Period.month, now).longest, isNull);
  });

  test('streaks', () {
    expect(streaksFor(const [], now).current, 0);

    final sessions = [
      _s(DateTime(2026, 10, 6, 9)),
      _s(DateTime(2026, 10, 5, 9)),
      _s(DateTime(2026, 10, 5, 14)),
      _s(DateTime(2026, 10, 1, 9)),
      _s(DateTime(2026, 9, 30, 9)),
      _s(DateTime(2026, 9, 29, 9)),
      _s(DateTime(2026, 9, 28, 9)),
    ];
    // Nothing today yet, so the streak counts back from yesterday.
    final s = streaksFor(sessions, now);
    expect(s.current, 2);
    expect(s.best, 4);

    expect(streaksFor(sessions, DateTime(2026, 10, 9)).current, 0);
  });
}
