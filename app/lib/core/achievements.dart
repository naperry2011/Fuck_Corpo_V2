import '../data/database.dart';
import 'break_mode.dart';
import 'stats.dart';

class Achievement {
  const Achievement(this.title, this.description, this.test);

  final String title;
  final String description;
  final bool Function(List<Session> sessions) test;
}

bool _any(List<Session> s, bool Function(Session) f) => s.any(f);

double _total(List<Session> s) => s.fold(0, (a, b) => a + b.earned);

bool _maxPerDay(List<Session> s, BreakMode mode, int n) {
  final perDay = <DateTime, int>{};
  for (final x in s.where((x) => x.mode == mode)) {
    final d = DateTime(x.startedAt.year, x.startedAt.month, x.startedAt.day);
    perDay[d] = (perDay[d] ?? 0) + 1;
  }
  return perDay.values.any((c) => c >= n);
}

final achievements = <Achievement>[
  Achievement('FIRST DEPOSIT', 'Log your first paid dump.',
      (s) => _any(s, (x) => x.mode == BreakMode.throne)),
  Achievement('SNIP IT OFF', 'A paid dump in under 1 minute.',
      (s) => _any(s, (x) => x.mode == BreakMode.throne && x.durationMs < 60000)),
  Achievement('THE MARATHON', 'A single dump over 20 minutes.',
      (s) => _any(
          s, (x) => x.mode == BreakMode.throne && x.durationMs >= 20 * 60000)),
  Achievement('BIG SPENDER', 'Earn \$10+ in a single session.',
      (s) => _any(s, (x) => x.earned >= 10)),
  Achievement('MOGUL', 'Earn \$100+ in a single session.',
      (s) => _any(s, (x) => x.earned >= 100)),
  Achievement('CHAIN SMOKER', '5 smoke breaks in one day.',
      (s) => _maxPerDay(s, BreakMode.smoke, 5)),
  Achievement('THREE-COURSE HEIST', 'A lunch heist over 45 minutes.',
      (s) => _any(
          s, (x) => x.mode == BreakMode.lunch && x.durationMs >= 45 * 60000)),
  Achievement('PERFECT ATTENDANCE', 'A 5-day streak.',
      (s) => streaksFor(s, DateTime.now()).best >= 5),
  Achievement('UNION REP', 'Log 100 sessions.', (s) => s.length >= 100),
  Achievement('GRAND LARCENY', 'Reclaim \$1,000 total.',
      (s) => _total(s) >= 1000),
];
