/// Which edition this build is. Defaults to the clean Play edition, so a
/// build only gets the uncensored copy with `--dart-define=EDITION=uncut`.
///
/// This is the only file allowed to hold profanity (test/edition_test.dart
/// enforces it). Google Play bans profanity in apps and listings, so the
/// uncut copy must never reach a Play build.
const bool isUncut = String.fromEnvironment('EDITION') == 'uncut';

class Edition {
  static const brand = isUncut ? 'FUCK CORPO' : 'CORPO DUMP';
  static const appName = isUncut ? 'F*ck Corpo' : 'Corpo Dump';
  static const fileSlug = isUncut ? 'fuck-corpo' : 'corpo-dump';
  static const hashtag = isUncut ? '#FuckCorpo' : '#CorpoDump';
  static const throneHeadline =
      isUncut ? 'EARNED WHILE SHITTING' : 'EARNED ON THE THRONE';
  static const hoursLabel =
      isUncut ? 'HOURS YOU GIVE THESE BASTARDS' : 'HOURS YOU GIVE THESE CLOWNS';
  static const emptyReceipts = isUncut
      ? 'No receipts yet. Go take a paid shit.'
      : 'No receipts yet. Go take a paid dump.';
}
