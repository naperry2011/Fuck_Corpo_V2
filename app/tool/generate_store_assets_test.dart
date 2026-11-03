// Renders the Android and iOS app icons and Google Play listing graphics
// from the app's own widgets. Not part of the normal test suite; run it on demand:
//
//   flutter test tool/generate_store_assets_test.dart
//
// Phone screenshots: drop raw 1080x2400 emulator captures named
// `<n>_<anything>.png` into store_assets/raw/ (Play) and 1320x2868 iPhone 17
// Pro Max simulator captures into store_assets/raw_ios/ (App Store), and add a
// caption below. Build the iOS capture with --dart-define=SCREENSHOTS=true so
// the debug buttons stay hidden.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:fcorpo/core/edition.dart';
import 'package:fcorpo/core/theme.dart';
import 'package:fcorpo/widgets/payslip_parts.dart';
import 'package:fcorpo/widgets/pixel_ceo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

const _res = 'android/app/src/main/res';
const _iosIcon = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
const _play = 'store_assets/play';
const _raw = 'store_assets/raw';
const _rawIos = 'store_assets/raw_ios';
const _appStore = 'store_assets/app_store';

/// Store captions keyed by the raw screenshot's number prefix. Kept clean:
/// store metadata gets stricter review than in-app content.
const _captions = {
  '1': 'YOUR BOSS PAYS YOU\nTO POOP. WATCH IT TICK.',
  '2': 'HOSTILE TAKEOVER.\nBILL THE COMPANY.',
  '3': 'EVERY DUMP GETS\nA RECEIPT.',
  '4': 'TRACK EVERY\nSTOLEN MINUTE.',
  '5': 'BUILD YOUR\nACQUISITIONS PORTFOLIO.',
  '6': 'WAGES STOLEN BACK,\nAUDITED BY NOBODY.',
  '7': 'UNLOCK MOGUL.\nBECOME UNION REP.',
  '8': 'FOUR RECEIPT STYLES.\nZERO SHAME.',
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

    // iOS takes one opaque 1024px icon and masks the corners itself.
    _writePng('$_iosIcon/Icon-App-1024x1024@1x.png',
        await _render(tester, const Size.square(1024),
            _icon(background: true, ceoScale: 0.72)));
    File('$_iosIcon/Contents.json').writeAsStringSync('''
{
  "images" : [
    {
      "filename" : "Icon-App-1024x1024@1x.png",
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
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
                      Text(Edition.brand,
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

  testWidgets('framed Play screenshots', (tester) async {
    // 1080x1920 (9:16) keeps the long side under Play's 2:1 limit.
    await _frameScreenshots(
      tester,
      raw: _raw,
      out: _play,
      size: const Size(1080, 1920),
      captionHeight: 360,
      fontSize: 58,
      sidePadding: 150,
    );
  });

  testWidgets('framed App Store screenshots', (tester) async {
    // 6.3-inch (1206x2622) is the size App Store Connect requires; 6.9-inch
    // (1320x2868) is optional. Both come from the 6.9-inch raw captures.
    await _frameScreenshots(
      tester,
      raw: _rawIos,
      out: '$_appStore/6.3',
      size: const Size(1206, 2622),
      captionHeight: 512,
      fontSize: 66,
      sidePadding: 110,
    );
    await _frameScreenshots(
      tester,
      raw: _rawIos,
      out: '$_appStore/6.9',
      size: const Size(1320, 2868),
      captionHeight: 560,
      fontSize: 72,
      sidePadding: 120,
    );
  });
}

/// Puts each `<n>_<anything>.png` capture in [raw] under its caption on an
/// ink background and writes `screenshot-<n>_<anything>.jpg` to [out].
Future<void> _frameScreenshots(
  WidgetTester tester, {
  required String raw,
  required String out,
  required Size size,
  required double captionHeight,
  required double fontSize,
  required double sidePadding,
}) async {
  final dir = Directory(raw);
  if (!dir.existsSync()) return;
  final raws =
      dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.png'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  for (final file in raws) {
    final name = file.uri.pathSegments.last;
    final caption = _captions[name.split('_').first] ?? '';
    final shot = await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(file.readAsBytesSync());
      return (await codec.getNextFrame()).image;
    });

    final framed = await _render(
      tester,
      size,
      ColoredBox(
        color: Payslip.ink,
        child: Column(
          children: [
            SizedBox(
              height: captionHeight,
              child: Center(
                child: Text(
                  caption,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: Payslip.fontFamily,
                    color: Payslip.paper,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    height: 1.15,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sidePadding),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(36),
                    ),
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
    _writeJpg('$out/screenshot-${name.replaceAll('.png', '.jpg')}', framed);
  }
}
