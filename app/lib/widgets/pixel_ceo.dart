import 'package:flutter/material.dart';

int angerFor(double earned) {
  if (earned < 0.25) return 0;
  if (earned < 1) return 1;
  if (earned < 3) return 2;
  return 3;
}

/// Placeholder pixel-art CEO until real sprites exist. [anger] is 0..3.
class PixelCeo extends StatelessWidget {
  const PixelCeo({super.key, required this.anger, this.size = 120});

  final int anger;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _CeoPainter(anger.clamp(0, 3))),
    );
  }
}

const _skinByAnger = [
  Color(0xFFF0C8A0),
  Color(0xFFF0997B),
  Color(0xFFE2705A),
  Color(0xFFD04040),
];

const _brows = [
  ['..SSKKSSSSKKSS..', '..SSSSSSSSSSSS..'],
  ['..SSKKSSSSSSSS..', '..SSSSSSSSKKSS..'],
  ['..SKSSSSSSSSKS..', '..SSKKSSSSKKSS..'],
  ['..SKSSSSSSSSKS..', '..SSKKSSSSKKSS..'],
];
const _mouths = [
  '..SSSSSSSKKSSS..',
  '..SSSSKKKKSSSS..',
  '..SSSKKKKKKSSS..',
  '..SSSKWWWWKSSS..',
];

List<String> _sprite(int anger) => [
      '....KKKKKKKK....',
      '....KKKKKKKK....',
      '....KKKKKKKK....',
      '..KKKKKKKKKKKK..',
      '...SSSSSSSSSS...',
      '..SSSSSSSSSSSS..',
      ..._brows[anger],
      '..SSWKSSSSWKGS..',
      '..SSSSSSSSSSGS..',
      '..SSSSSKKSSSGS..',
      '..SSSKKKKKKSSS..',
      _mouths[anger],
      '...SSSSSSSSSS...',
      '...KKWWTTWWKK...',
      '..KKKKWTTWKKKK..',
      'KKKKKKKTTKKKKKKK',
    ];

class _CeoPainter extends CustomPainter {
  _CeoPainter(this.anger);

  final int anger;

  @override
  void paint(Canvas canvas, Size size) {
    final rows = _sprite(anger);
    final px = size.width / 16;
    final top = (size.height - rows.length * px) / 2;
    final colors = {
      'K': const Color(0xFF1A1A1A),
      'S': _skinByAnger[anger],
      'W': const Color(0xFFFFFFFF),
      'G': const Color(0xFFEF9F27),
      'T': const Color(0xFFA32D2D),
    };
    final paint = Paint();
    for (var y = 0; y < rows.length; y++) {
      for (var x = 0; x < rows[y].length; x++) {
        final c = colors[rows[y][x]];
        if (c == null) continue;
        paint.color = c;
        canvas.drawRect(Rect.fromLTWH(x * px, top + y * px, px, px), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_CeoPainter old) => old.anger != anger;
}
