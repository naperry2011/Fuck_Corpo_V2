import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'share_card.dart';

Future<File> captureCard(RenderRepaintBoundary boundary, String name) async {
  final image = await boundary.toImage(pixelRatio: shareCardPixelRatio);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$name.png');
  await file.writeAsBytes(bytes!.buffer.asUint8List(), flush: true);
  return file;
}

Future<void> shareCardImage(File file, {required String text}) async {
  await SharePlus.instance.share(ShareParams(
    files: [XFile(file.path, mimeType: 'image/png')],
    text: text,
  ));
}
