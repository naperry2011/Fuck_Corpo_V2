# Entry Points

Generated: 2026-10-05 | commit be5fb09 | by /code-map

## Flutter App

Path: app/lib/main.dart
Responsibility: Registers font license, loads SharedPreferences, starts ProviderScope, picks IntakeFormScreen (no profile) or HomeShell; starts billing listener unless built with UNLOCK_PRO.
Invokes: features/home_shell.dart, features/onboarding/intake_form_screen.dart, features/pro/billing.dart
Depends On: state/providers.dart, core/theme.dart

## Home Tabs

Path: app/lib/features/home_shell.dart
Responsibility: Bottom navigation between Clock, Ledger, Perks.
Invokes: TimerScreen, LedgerScreen, PerksScreen
Depends On: none beyond the three screens

## Android Host

Path: app/android/app/src/main/AndroidManifest.xml (MainActivity)
Responsibility: Launcher activity, app label "F*ck Corpo", icon.
Invokes: Flutter engine -> main()
Depends On: app/android/app/build.gradle.kts

## Store Asset Generator

Path: app/tool/generate_store_assets_test.dart
Responsibility: Renders launcher icons, Play icon, feature graphic, framed screenshots.
Invokes: `flutter test tool/generate_store_assets_test.dart`
Depends On: widgets/pixel_ceo.dart, widgets/payslip_parts.dart, core/theme.dart, package:image

## Code Generation

Path: app/lib/data/database.dart -> database.g.dart
Responsibility: drift table/DAO codegen.
Invokes: `dart run build_runner build`
Depends On: drift_dev, build_runner

## Test Suite

Path: app/test/
Responsibility: Unit and widget tests.
Invokes: `flutter test`
Depends On: lib/

## Build Commands

Path: app/ (Flutter CLI)
Responsibility: Play bundle and personal APK.
Invokes: `flutter build appbundle --release`; `flutter build apk --release --dart-define=UNLOCK_PRO=true`
Depends On: app/android/key.properties (optional; falls back to debug key)

## Website

Path: web/index.html, web/privacy.html
Responsibility: Static landing page, calculator, privacy policy.
Invokes: web/calc.js (in browser)
Depends On: web/styles.css, web/fonts/

## Website Local Preview

Path: .claude/launch.json ("web")
Responsibility: Serves web/ on port 4317 via `npx serve`.

## Website Deploy

Path: web/vercel.json
Responsibility: Vercel config (clean URLs, headers). Deploys from GitHub repo with root directory `web`, no build step.
