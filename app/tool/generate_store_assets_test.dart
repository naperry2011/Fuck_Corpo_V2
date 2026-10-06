// Renders the launcher icons and Google Play listing graphics from the app's
// own widgets. Not part of the normal test suite; run it on demand:
//
//   flutter test tool/generate_store_assets_test.dart
//
// Phone screenshots: drop raw 1080x2400 emulator captures named
// `<n>_<anything>.png` into store_assets/raw/ and add a caption below.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:fcorpo/core/theme.dart';
import 'package:fcorpo/widgets/payslip_parts.dart';
import 'package:fcorpo/widgets/pixel_ceo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

const _res = 'android/app/src/main/res';
const _play = 'store_assets/play';
const _raw = 'store_assets/raw';

/// Store captions keyed by the raw screenshot's number prefix. Kept clean:
/// store metadata gets stricter review than in-app content.
const _captions = {
  '1': 'YOUR BOSS PAYS YOU\nTO POOP. WATCH IT TICK.',
  '2': 'EVERY DUMP GETS\nA RECEIPT.',
  '3': 'TRACK EVERY\nSTOLEN MINUTE.',
  '4': 'YOUR YEAR-END\nW-2(ISH).',
  '5': 'WAGES STOLEN BACK,\nAUDITED BY NOBODY.',
  '6': 'UNLOCK MOGUL.\nBECOME UNION REP.',
  '7': 'FOUR RECEIPT STYLES.\nZERO SHAME.',
};

Future<img.Image> _render(WidgetTester tester, Size size, Widget child) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  final key = GlobalKey();
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: size),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: DefaultTextStyle(
          style: const TextStyle(
              fontFamily: Payslip.fontFamily, color: Payslip.ink),
          child: RepaintBoundary(
            key: key,
            child: SizedBox.fromSize(size: size, child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  });
  return img.decodePng(bytes!)!;
}

void _writePng(String path, img.Image image, {bool alpha = false}) {
  final out = alpha ? image : image.convert(numChannels: 3);
  File(path)
    ..parent.createSync(recursive: true)
    ..writeAsBytesSync(img.encodePng(out));
}

void _writeJpg(String path, img.Image image) {
  File(path)
    ..parent.createSync(recursive: true)
    ..writeAsBytesSync(img.encodeJpg(image.convert(numChannels: 3), quality: 95));
}

Widget _icon({required bool background, required double ceoScale}) {
  return ColoredBox(
    color: background ? Payslip.paper : Colors.transparent,
    child: LayoutBuilder(
      builder: (context, c) => Center(
        child: PixelCeo(anger: 2, size: c.maxWidth * ceoScale),
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    final font = FontLoader('CourierPrime')
      ..addFont(rootBundle.load('assets/fonts/CourierPrime-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/CourierPrime-Bold.ttf'));
    await font.load();
  });

  testWidgets('launcher icons', (tester) async {
    const legacy = {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192};
    for (final MapEntry(key: dpi, value: px) in legacy.entries) {
      final s = Size.square(px.toDouble());
      _writePng('$_res/mipmap-$dpi/ic_launcher.png',
          await _render(tester, s, _icon(background: true, ceoScale: 0.78)));
      // Adaptive foreground is 108dp; launchers only promise the middle
      // 66dp stays visible, so the CEO sits well inside it.
      final f = Size.square(px * 108 / 48);
      _writePng('$_res/mipmap-$dpi/ic_launcher_foreground.png',
          await _render(tester, f, _icon(background: false, ceoScale: 0.5)),
          alpha: true);
    }
    File('$_res/mipmap-anydpi-v26/ic_launcher.xml')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync('''
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
''');
    File('$_res/values/ic_launcher_background.xml').writeAsStringSync('''
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#F4F1E8</color>
</resources>
''');

    _writePng('$_play/icon-512.png',
        await _render(tester, const Size.square(512),
            _icon(background: true, ceoScale: 0.72)));
  });

  testWidgets('feature graphic', (tester) async {
    const paper = TextStyle(
        fontFamily: Payslip.fontFamily, color: Payslip.paper);
    final graphic = await _render(
      tester,
      const Size(1024, 500),
      Theme(
        data: payslipLight,
        child: ColoredBox(
          color: Payslip.ink,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(64, 48, 48, 48),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('F*CK CORPO',
                          style: paper.copyWith(
                              fontSize: 24, letterSpacing: 6)),
                      const SizedBox(height: 12),
                      Text('GET PAID\nTO POOP.',
                          style: paper.copyWith(
                              fontSize: 76,
                              fontWeight: FontWeight.bold,
                              height: 1.0)),
                      const SizedBox(height: 18),
                      Text('Clock every dump on company time.',
                          style: paper.copyWith(
                              fontSize: 22, color: const Color(0xFFB4B2A9))),
                    ],
                  ),
                ),
                SizedBox(
                  width: 340,
                  child: Container(
                    color: Payslip.paper,
                    padding: const EdgeInsets.all(28),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PixelCeo(anger: 3, size: 190),
                        SizedBox(height: 24),
                        Stamp('PAID IN FULL', fontSize: 26),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    _writePng('$_play/feature-graphic-1024x500.png', graphic);
  });

  testWidgets('framed phone screenshots', (tester) async {
    final dir = Directory(_raw);
    if (!dir.existsSync()) return;
    final raws = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.png')).toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    for (final file in raws) {
      final name = file.uri.pathSegments.last;
      final caption = _captions[name.split('_').first] ?? '';
      final shot = await tester.runAsync(() async {
        final codec = await ui.instantiateImageCodec(file.readAsBytesSync());
        return (await codec.getNextFrame()).image;
      });

      // 1080x1920 (9:16) keeps the long side under Play's 2:1 limit.
      final framed = await _render(
        tester,
        const Size(1080, 1920),
        ColoredBox(
          color: Payslip.ink,
          child: Column(
            children: [
              SizedBox(
                height: 360,
                child: Center(
                  child: Text(
                    caption,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: Payslip.fontFamily,
                      color: Payslip.paper,
                      fontSize: 58,
                      fontWeight: FontWeight.bold,
                      height: 1.15,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(150, 0, 150, 0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(36)),
                      child: RawImage(image: shot, fit: BoxFit.fitWidth),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      shot!.dispose();
      _writeJpg('$_play/screenshot-${name.replaceAll('.png', '.jpg')}', framed);
    }
  });
}
