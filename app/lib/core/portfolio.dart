import '../data/database.dart';
import 'takeover.dart';

class Holding {
  Holding(this.name, this.category);

  /// Display name as first typed; grouping ignores case.
  final String name;
  final BusinessCategory category;
  int takeovers = 0;
  double damages = 0;
}

class Portfolio {
  const Portfolio({
    required this.holdings,
    required this.takeovers,
    required this.damages,
    required this.byCategory,
  });

  /// Most-acquired first.
  final List<Holding> holdings;
  final int takeovers;
  final double damages;
  final Map<BusinessCategory, int> byCategory;

  int get companies => holdings.length;
  bool get isEmpty => takeovers == 0;
  Holding? get favorite => holdings.firstOrNull;

  factory Portfolio.from(Iterable<Session> sessions) {
    final byKey = <String, Holding>{};
    final byCategory = {for (final c in BusinessCategory.values) c: 0};
    var takeovers = 0;
    var damages = 0.0;

    // Oldest first, so the display name is the earliest spelling.
    final ordered = sessions.where((s) => s.businessName != null).toList()
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
    for (final s in ordered) {
      final category = s.businessCategory ?? BusinessCategory.other;
      final h = byKey.putIfAbsent(
          s.businessName!.toLowerCase(), () => Holding(s.businessName!, category));
      h.takeovers++;
      h.damages += s.damages ?? 0;
      byCategory[category] = byCategory[category]! + 1;
      takeovers++;
      damages += s.damages ?? 0;
    }

    final holdings = byKey.values.toList()
      ..sort((a, b) => b.takeovers != a.takeovers
          ? b.takeovers.compareTo(a.takeovers)
          : a.name.compareTo(b.name));
    return Portfolio(
      holdings: holdings,
      takeovers: takeovers,
      damages: damages,
      byCategory: byCategory,
    );
  }
}
