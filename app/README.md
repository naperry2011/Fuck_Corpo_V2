# Corpo Dump / F*ck Corpo Uncut (Flutter app)

The Android app. The full story, screenshots, and setup live in the [root README](../README.md); project state and decisions are in [`memory.md`](../memory.md).

```bash
flutter pub get
flutter test
flutter run
```

Plain commands use the clean `play` flavor. For the uncut edition, add `--flavor uncut --dart-define=EDITION=uncut`.

After changing `lib/data/database.dart`, regenerate drift code with `dart run build_runner build`.
