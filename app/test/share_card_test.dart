import 'package:fcorpo/core/break_mode.dart';
import 'package:fcorpo/data/database.dart';
import 'package:fcorpo/features/share/share_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('share card exports as a 1080x1350 image without overflow',
      (tester) async {
    await tester.runAsync(() async {
      final font = FontLoader('CourierPrime')
        ..addFont(rootBundle.load('assets/fonts/CourierPrime-Regular.ttf'))
        ..addFont(rootBundle.load('assets/fonts/CourierPrime-Bold.ttf'));
      await font.load();
    });
    final key = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      home: Center(
        child: RepaintBoundary(
          key: key,
          child: ShareCard(
            session: Session(
              id: 427,
              mode: BreakMode.throne,
              startedAt: DateTime(2026, 10, 5, 14, 14),
              durationMs: 402000,
              earned: 1234.5678,
            ),
            currency: r'$',
            bossName: 'Maximilian Von Boss',
            roast: 'Shareholders have been notified. They are crying.',
          ),
        ),
      ),
    ));
    expect(tester.takeException(), isNull);

    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await tester.runAsync(
        () => boundary.toImage(pixelRatio: shareCardPixelRatio));
    expect(image!.width, 1080);
    expect(image.height, 1350);
    image.dispose();
  });
}
