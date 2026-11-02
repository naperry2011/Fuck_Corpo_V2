import 'dart:io';

import 'package:fcorpo/core/edition.dart';
import 'package:flutter_test/flutter_test.dart';

final _banned = RegExp(r'fuck|f\*ck|shit(?!\w*ell)|bastard|bitch|asshole|cunt',
    caseSensitive: false);

void main() {
  test('profanity only lives in core/edition.dart', () {
    final offenders = <String>[];
    for (final root in ['lib', 'tool']) {
      for (final file in Directory(root).listSync(recursive: true)) {
        if (file is! File || !file.path.endsWith('.dart')) continue;
        final path = file.path.replaceAll(r'\', '/');
        if (path.endsWith('core/edition.dart') || path.endsWith('.g.dart')) {
          continue;
        }
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          if (_banned.hasMatch(lines[i])) offenders.add('$path:${i + 1}');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test('a default build is the clean edition', () {
    expect(isUncut, isFalse);
    for (final text in [
      Edition.brand,
      Edition.appName,
      Edition.fileSlug,
      Edition.hashtag,
      Edition.throneHeadline,
      Edition.hoursLabel,
      Edition.emptyReceipts,
    ]) {
      expect(_banned.hasMatch(text), isFalse, reason: text);
    }
  });
}
