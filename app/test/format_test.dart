import 'package:fcorpo/core/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('longDuration switches to hours past 60 minutes', () {
    expect(longDuration(const Duration(seconds: 45)), '45s');
    expect(longDuration(const Duration(minutes: 9, seconds: 41)), '9m 41s');
    expect(longDuration(const Duration(minutes: 59, seconds: 59)), '59m 59s');
    expect(longDuration(const Duration(hours: 89, minutes: 18, seconds: 14)),
        '89h 18m');
  });

  test('clock pads minutes and seconds', () {
    expect(clock(const Duration(minutes: 2, seconds: 5)), '02:05');
    expect(clock(const Duration(hours: 1, minutes: 2, seconds: 5)), '1:02:05');
  });
}
