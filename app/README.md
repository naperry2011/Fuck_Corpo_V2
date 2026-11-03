# Corpo Dump / F*ck Corpo Uncut (Flutter app)

The Android and iOS app. The full story, screenshots, and setup live in the [root README](../README.md); project state and decisions are in [`memory.md`](../memory.md).

```bash
flutter pub get
flutter test
flutter run
```

Plain commands use the clean `play` flavor. For the uncut edition, add `--flavor uncut --dart-define=EDITION=uncut`. On iOS the flavors are the Xcode schemes `play` and `uncut`; build from a folder outside iCloud Drive.

After changing `lib/data/database.dart`, regenerate drift code with `dart run build_runner build`.
