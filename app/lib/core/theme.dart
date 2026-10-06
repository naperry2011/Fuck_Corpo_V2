import 'package:flutter/material.dart';

class Payslip {
  static const paper = Color(0xFFF4F1E8);
  static const ink = Color(0xFF1A1A1A);
  static const fadedInk = Color(0xFF5F5E5A);
  static const stamp = Color(0xFFA32D2D);

  static const carbon = Color(0xFF16161A);
  static const carbonInk = Color(0xFFE6E2D6);
  static const carbonFaded = Color(0xFF8A877E);
  static const carbonStamp = Color(0xFFE24B4A);

  static const fontFamily = 'CourierPrime';
}

ThemeData _build({
  required Brightness brightness,
  required Color paper,
  required Color ink,
  required Color faded,
  required Color stamp,
}) {
  final scheme = ColorScheme(
    brightness: brightness,
    primary: ink,
    onPrimary: paper,
    secondary: stamp,
    onSecondary: paper,
    error: stamp,
    onError: paper,
    surface: paper,
    onSurface: ink,
    onSurfaceVariant: faded,
    outline: ink,
  );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: paper,
    fontFamily: Payslip.fontFamily,
  );
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(6));
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: ink, displayColor: ink),
    dividerTheme: DividerThemeData(color: ink, thickness: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ink,
        foregroundColor: paper,
        shape: shape,
        minimumSize: const Size.fromHeight(52),
        textStyle: const TextStyle(
            fontFamily: Payslip.fontFamily, letterSpacing: 1.5),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ink,
        side: BorderSide(color: ink),
        shape: shape,
        minimumSize: const Size.fromHeight(52),
        textStyle: const TextStyle(
            fontFamily: Payslip.fontFamily, letterSpacing: 1.5),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: paper,
      indicatorColor: ink,
      indicatorShape: const RoundedRectangleBorder(),
      height: 68,
      iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? paper : ink)),
      labelTextStyle: WidgetStatePropertyAll(TextStyle(
          fontFamily: Payslip.fontFamily,
          color: ink,
          fontSize: 12,
          letterSpacing: 1.5)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: paper,
      foregroundColor: ink,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: UnderlineInputBorder(borderSide: BorderSide(color: ink)),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ink)),
      focusedBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: ink, width: 2)),
      labelStyle: TextStyle(color: faded),
    ),
  );
}

final payslipLight = _build(
  brightness: Brightness.light,
  paper: Payslip.paper,
  ink: Payslip.ink,
  faded: Payslip.fadedInk,
  stamp: Payslip.stamp,
);

final payslipNightShift = _build(
  brightness: Brightness.dark,
  paper: Payslip.carbon,
  ink: Payslip.carbonInk,
  faded: Payslip.carbonFaded,
  stamp: Payslip.carbonStamp,
);
