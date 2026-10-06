enum PayType { hourly, salary }

class PayRate {
  const PayRate({
    required this.type,
    required this.amount,
    required this.hoursPerWeek,
  });

  final PayType type;
  final double amount;
  final double hoursPerWeek;

  static const _weeksPerYear = 52;
  static const _secondsPerHour = 3600;

  double get perSecond {
    if (amount <= 0) return 0;
    switch (type) {
      case PayType.hourly:
        return amount / _secondsPerHour;
      case PayType.salary:
        if (hoursPerWeek <= 0) return 0;
        return amount / (hoursPerWeek * _weeksPerYear * _secondsPerHour);
    }
  }

  double earned(Duration elapsed) =>
      perSecond * elapsed.inMicroseconds / Duration.microsecondsPerSecond;
}
