import 'package:fcorpo/core/rate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PayRate', () {
    test('hourly converts to per-second', () {
      const rate = PayRate(type: PayType.hourly, amount: 36, hoursPerWeek: 40);
      expect(rate.perSecond, closeTo(0.01, 1e-12));
    });

    test('salary spreads over 52 weeks of worked hours', () {
      const rate =
          PayRate(type: PayType.salary, amount: 52000, hoursPerWeek: 40);
      // 52000 / 2080 h = $25/h
      expect(rate.perSecond, closeTo(25 / 3600, 1e-12));
    });

    test('earned scales with duration', () {
      const rate = PayRate(type: PayType.hourly, amount: 24.5, hoursPerWeek: 40);
      expect(rate.earned(const Duration(minutes: 6, seconds: 42)),
          closeTo(24.5 * 402 / 3600, 1e-9));
    });

    test('zero or negative inputs earn nothing', () {
      expect(
          const PayRate(type: PayType.salary, amount: 50000, hoursPerWeek: 0)
              .perSecond,
          0);
      expect(
          const PayRate(type: PayType.hourly, amount: -5, hoursPerWeek: 40)
              .perSecond,
          0);
      expect(
          const PayRate(type: PayType.hourly, amount: 20, hoursPerWeek: 40)
              .earned(Duration.zero),
          0);
    });
  });
}
