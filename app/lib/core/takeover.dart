enum BusinessCategory {
  coffee('COFFEE'),
  bigBox('BIG BOX'),
  bank('BANK'),
  fastFood('FAST FOOD'),
  hotel('HOTEL'),
  other('OTHER');

  const BusinessCategory(this.label);

  final String label;
}

/// The business whose bathroom is being acquired.
class TakeoverTarget {
  const TakeoverTarget({required this.name, required this.category});

  final String name;
  final BusinessCategory category;

  static const maxNameLength = 40;

  /// Trimmed, collapsed whitespace; null when nothing usable was typed.
  static String? cleanName(String raw) {
    final name = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (name.isEmpty) return null;
    return name.length > maxNameLength
        ? name.substring(0, maxNameLength)
        : name;
  }
}

class DamageLine {
  const DamageLine(this.label, this.amount);

  final String label;
  final double amount;
}

/// Playful utility-cost estimates billed to the target business. Not real
/// figures; tuned so a normal visit lands in the tens of cents.
class Damages {
  Damages(Duration duration) : minutes = duration.inSeconds / 60;

  final double minutes;

  static const _perFlush = 0.016;
  static const _perSheet = 0.004;
  static const _perPump = 0.01;
  static const _climatePerMinute = 0.012;
  static const _wifiPerMinute = 0.004;

  int get flushes => minutes > 8 ? 2 : 1;
  int get sheets => 6 + (minutes * 0.9).round();
  int get pumps => 2;

  List<DamageLine> get lines => [
        DamageLine(
            'Water (${flushes == 1 ? '1 flush' : '$flushes flushes'})',
            flushes * _perFlush),
        DamageLine('Toilet paper, $sheets sheets', sheets * _perSheet),
        DamageLine('Hand soap, $pumps pumps', pumps * _perPump),
        DamageLine('AC + lighting', minutes * _climatePerMinute),
        DamageLine('Wi-Fi', minutes * _wifiPerMinute),
      ];

  double get total => lines.fold(0, (sum, l) => sum + l.amount);
}
