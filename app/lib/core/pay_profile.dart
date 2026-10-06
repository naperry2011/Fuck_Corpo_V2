import 'rate.dart';

class PayProfile {
  const PayProfile({
    required this.type,
    required this.amount,
    required this.hoursPerWeek,
    required this.currency,
    required this.bossName,
  });

  final PayType type;
  final double amount;
  final double hoursPerWeek;
  final String currency;
  final String bossName;

  PayRate get rate =>
      PayRate(type: type, amount: amount, hoursPerWeek: hoursPerWeek);
}
