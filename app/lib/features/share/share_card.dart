import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/format.dart';
import '../../core/receipt_styles.dart';
import '../../core/theme.dart';
import '../../data/database.dart';
import '../../widgets/payslip_parts.dart';
import '../../widgets/pixel_ceo.dart';

/// Logical size of an exported card. Captured at 3x for a 1080x1350 PNG,
/// the 4:5 ratio Instagram, X, and TikTok all display without cropping.
const shareCardSize = Size(360, 450);
const shareCardPixelRatio = 3.0;

/// Torn paper slip on a colored background with the brand footer. Ignores
/// the app's dark mode so shared images look the same for everyone.
class ReceiptFrame extends StatelessWidget {
  const ReceiptFrame({
    super.key,
    required this.child,
    this.style = ReceiptStyle.classic,
  });

  final Widget child;
  final ReceiptStyle style;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: style.themeData,
      child: SizedBox.fromSize(
        size: shareCardSize,
        child: ColoredBox(
          color: style.background,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Column(
              children: [
                Expanded(
                  child: ClipPath(
                    clipper: _ReceiptEdges(),
                    child: ColoredBox(
                      color: style.paper,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                        child: DefaultTextStyle(
                          style: TextStyle(
                            fontFamily: Payslip.fontFamily,
                            color: style.ink,
                            fontSize: 12.5,
                          ),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 34,
                  child: Center(
                    child: Text(
                      'FUCK CORPO · GET PAID TO POOP',
                      style: TextStyle(
                        fontFamily: Payslip.fontFamily,
                        color: style.footer,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShareCard extends StatelessWidget {
  const ShareCard({
    super.key,
    required this.session,
    required this.currency,
    required this.bossName,
    required this.roast,
    this.style = ReceiptStyle.classic,
  });

  final Session session;
  final String currency;
  final String bossName;
  final String roast;
  final ReceiptStyle style;

  @override
  Widget build(BuildContext context) {
    final s = session;
    final duration = Duration(milliseconds: s.durationMs);
    const small = TextStyle(fontSize: 11.5);

    return ReceiptFrame(
      style: style,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${style.header}\n'
            'RECEIPT #${s.id.toString().padLeft(6, '0')}\n'
            '${DateFormat('MMM d, y · h:mm a').format(s.startedAt).toUpperCase()}',
            textAlign: TextAlign.center,
            style: small,
          ),
          const DashedDivider(),
          LineItem('1x ${s.mode.receiptItem}', money(s.earned, currency)),
          LineItem('Duration', longDuration(duration)),
          LineItem('Paid by', "$bossName's budget"),
          LineItem('Tip from shareholders', money(0, currency)),
          const DashedDivider(),
          LineItem(
            'TOTAL',
            money(s.earned, currency),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PixelCeo(anger: angerFor(s.earned), size: 64),
              const Stamp('PAID IN FULL', fontSize: 15),
            ],
          ),
          const Spacer(),
          Text(roast, textAlign: TextAlign.center, style: small),
        ],
      ),
    );
  }
}

/// Torn-paper zigzag along the top and bottom edges.
class _ReceiptEdges extends CustomClipper<Path> {
  static const _tooth = 8.0;

  @override
  Path getClip(Size size) {
    final teeth = (size.width / _tooth).floor();
    final step = size.width / teeth;
    final path = Path()..moveTo(0, _tooth / 2);
    for (var i = 0; i < teeth; i++) {
      path
        ..lineTo(step * i + step / 2, 0)
        ..lineTo(step * (i + 1), _tooth / 2);
    }
    path.lineTo(size.width, size.height - _tooth / 2);
    for (var i = teeth; i > 0; i--) {
      path
        ..lineTo(step * i - step / 2, size.height)
        ..lineTo(step * (i - 1), size.height - _tooth / 2);
    }
    return path..close();
  }

  @override
  bool shouldReclip(_ReceiptEdges old) => false;
}
