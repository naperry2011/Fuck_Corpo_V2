import '../data/database.dart';
import 'break_mode.dart';
import 'stats.dart';

class WrappedStats {
  const WrappedStats({
    required this.year,
    required this.total,
    required this.earnedByMode,
    required this.countByMode,
    required this.timeByMode,
    required this.count,
    required this.time,
    required this.longest,
    required this.richest,
    required this.busiestMonth,
    required this.busiestMonthEarned,
    required this.bestStreak,
  });

  final int year;
  final double total;
  final Map<BreakMode, double> earnedByMode;
  final Map<BreakMode, int> countByMode;
  final Map<BreakMode, Duration> timeByMode;
  final int count;
  final Duration time;
  final Session? longest;
  final Session? richest;

  /// 1-12, or null with no sessions.
  final int? busiestMonth;
  final double busiestMonthEarned;
  final int bestStreak;

  bool get isEmpty => count == 0;

  BreakMode get topMode => BreakMode.values
      .reduce((a, b) => earnedByMode[b]! > earnedByMode[a]! ? b : a);

  double get topModeShare => total == 0 ? 0 : earnedByMode[topMode]! / total;

  factory WrappedStats.from(List<Session> all, int year) {
    final sessions = all.where((s) => s.startedAt.year == year).toList();
    final earned = {for (final m in BreakMode.values) m: 0.0};
    final counts = {for (final m in BreakMode.values) m: 0};
    final times = {for (final m in BreakMode.values) m: Duration.zero};
    final byMonth = List.filled(13, 0.0);
    Session? longest;
    Session? richest;
    var ms = 0;

    for (final s in sessions) {
      final d = Duration(milliseconds: s.durationMs);
      earned[s.mode] = earned[s.mode]! + s.earned;
      counts[s.mode] = counts[s.mode]! + 1;
      times[s.mode] = times[s.mode]! + d;
      byMonth[s.startedAt.month] += s.earned;
      ms += s.durationMs;
      if (longest == null || s.durationMs > longest.durationMs) longest = s;
      if (richest == null || s.earned > richest.earned) richest = s;
    }

    int? busiest;
    for (var m = 1; m <= 12; m++) {
      if (byMonth[m] > 0 && (busiest == null || byMonth[m] > byMonth[busiest])) {
        busiest = m;
      }
    }

    return WrappedStats(
      year: year,
      total: earned.values.fold(0, (a, b) => a + b),
      earnedByMode: earned,
      countByMode: counts,
      timeByMode: times,
      count: sessions.length,
      time: Duration(milliseconds: ms),
      longest: longest,
      richest: richest,
      busiestMonth: busiest,
      busiestMonthEarned: busiest == null ? 0 : byMonth[busiest],
      bestStreak: streaksFor(sessions, DateTime(year, 12, 31)).best,
    );
  }
}
