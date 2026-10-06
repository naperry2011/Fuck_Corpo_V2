import 'package:intl/intl.dart';

String money(double value, String currency, {int decimals = 2}) =>
    NumberFormat.currency(symbol: currency, decimalDigits: decimals)
        .format(value);

String clock(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

String longDuration(Duration d) {
  final m = d.inMinutes;
  final s = d.inSeconds.remainder(60);
  return m > 0 ? '${m}m ${s}s' : '${s}s';
}
