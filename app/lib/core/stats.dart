import '../data/database.dart';
import 'break_mode.dart';

enum Period {
  today('TODAY'),
  week('WEEK'),
  month('MONTH'),
  year('YEAR');

  const Period(this.label);

  final String label;

  DateTime start(DateTime now) {
    switch (this) {
      case Period.today:
        return DateTime(now.year, now.month, now.day);
      case Period.week:
        return DateTime(now.year, now.month, now.day - (now.weekday - 1));
      case Period.month:
        return DateTime(now.year, now.month);
      case Period.year:
        return DateTime(now.year);
    }
  }
}

class PeriodStats {
  const PeriodStats({
    required this.earnedByMode,
    required this.count,
    required this.time,
    required this.longest,
  });

  final Map<BreakMode, double> earnedByMode;
  final int count;
  final Duration time;
  final Session? longest;

  double get total => earnedByMode.values.fold(0, (a, b) => a + b);
}

PeriodStats statsFor(List<Session> sessions, Period period, DateTime now) {
  final start = period.start(now);
  final byMode = {for (final m in BreakMode.values) m: 0.0};
  var count = 0;
  var ms = 0;
  Session? longest;
  for (final s in sessions) {
    if (s.startedAt.isBefore(start)) continue;
    byMode[s.mode] = byMode[s.mode]! + s.earned;
    count++;
    ms += s.durationMs;
    if (longest == null || s.durationMs > longest.durationMs) longest = s;
  }
  return PeriodStats(
    earnedByMode: byMode,
    count: count,
    time: Duration(milliseconds: ms),
    longest: longest,
  );
}

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

class Streaks {
  const Streaks(this.current, this.best);

  final int current;
  final int best;
}

/// Consecutive calendar days with at least one session. The current streak
/// survives until the end of today even if today has no session yet.
Streaks streaksFor(List<Session> sessions, DateTime now) {
  final days = {for (final s in sessions) _day(s.startedAt)};
  if (days.isEmpty) return const Streaks(0, 0);

  var cursor = _day(now);
  if (!days.contains(cursor)) {
    cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
  }
  var current = 0;
  while (days.contains(cursor)) {
    current++;
    cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
  }

  final sorted = days.toList()..sort();
  var best = 1;
  var run = 1;
  for (var i = 1; i < sorted.length; i++) {
    final prev = sorted[i - 1];
    final expected = DateTime(prev.year, prev.month, prev.day + 1);
    run = sorted[i] == expected ? run + 1 : 1;
    if (run > best) best = run;
  }
  return Streaks(current, best);
}
