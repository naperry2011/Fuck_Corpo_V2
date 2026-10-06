import 'package:flutter/material.dart';

import 'theme.dart';

/// Looks for exported receipts and Wrapped slides. Everything but [classic]
/// is Pro.
enum ReceiptStyle {
  classic(
    label: 'CLASSIC',
    header: 'FUCK CORPO INC.',
    background: Payslip.ink,
    paper: Payslip.paper,
    ink: Payslip.ink,
    faded: Payslip.fadedInk,
    stamp: Payslip.stamp,
    footer: Payslip.paper,
  ),
  gold(
    label: 'GOLD RECEIPT',
    header: 'FUCK CORPO PRIVATE BANKING',
    background: Color(0xFF1A1A1A),
    paper: Color(0xFFEFD9A0),
    ink: Color(0xFF412402),
    faded: Color(0xFF854F0B),
    stamp: Color(0xFFA32D2D),
    footer: Color(0xFFEFD9A0),
    pro: true,
  ),
  memo(
    label: 'CEO MEMO',
    header: 'INTERNAL MEMO · DO NOT FORWARD',
    background: Color(0xFF0C447C),
    paper: Color(0xFFFFFFFF),
    ink: Color(0xFF042C53),
    faded: Color(0xFF185FA5),
    stamp: Color(0xFFA32D2D),
    footer: Color(0xFFFFFFFF),
    pro: true,
  ),
  strike(
    label: 'STRIKE POSTER',
    header: 'ON STRIKE (SORT OF)',
    background: Color(0xFFA32D2D),
    paper: Color(0xFFFAC775),
    ink: Color(0xFF1A1A1A),
    faded: Color(0xFF633806),
    stamp: Color(0xFFA32D2D),
    footer: Color(0xFFFAC775),
    pro: true,
  );

  const ReceiptStyle({
    required this.label,
    required this.header,
    required this.background,
    required this.paper,
    required this.ink,
    required this.faded,
    required this.stamp,
    required this.footer,
    this.pro = false,
  });

  final String label;
  final String header;
  final Color background;
  final Color paper;
  final Color ink;
  final Color faded;
  final Color stamp;
  final Color footer;
  final bool pro;

  ThemeData get themeData => payslipLight.copyWith(
        colorScheme: payslipLight.colorScheme.copyWith(
          surface: paper,
          onSurface: ink,
          onSurfaceVariant: faded,
          secondary: stamp,
        ),
      );
}
