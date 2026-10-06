# Code Map

Generated: 2026-10-05 | commit be5fb09 | by /code-map

Two independent parts: `app/` (Flutter, Android) and `web/` (static site). No backend.

## App Shell and Theme

Category: UI

Primary Files:
* app/lib/main.dart
* app/lib/features/home_shell.dart
* app/lib/core/theme.dart

Supporting Files:
* app/lib/widgets/payslip_parts.dart (DashedDivider, Stamp, LineItem, ModeChip)
* app/lib/widgets/pixel_ceo.dart (pixel CEO painter, `angerFor`)

Entry Points:
* `main()` in app/lib/main.dart

## State and Persistence

Category: Service

Primary Files:
* app/lib/state/providers.dart
* app/lib/data/database.dart (+ generated database.g.dart)
* app/lib/data/settings_repository.dart

External Integrations:
* SQLite via drift / drift_flutter
* shared_preferences

## Pay Math and Domain Models

Category: Other (pure Dart)

Primary Files:
* app/lib/core/rate.dart
* app/lib/core/pay_profile.dart
* app/lib/core/break_mode.dart
* app/lib/core/format.dart

## Onboarding (Intake Form)

Category: UI

Primary Files:
* app/lib/features/onboarding/intake_form_screen.dart

## Timer

Category: UI

Primary Files:
* app/lib/features/timer/timer_screen.dart

Supporting Files:
* app/lib/copy/roasts.dart (CEO quotes)

## Receipt and Sharing

Category: UI

Primary Files:
* app/lib/features/receipt/receipt_screen.dart
* app/lib/features/share/share_card.dart (ReceiptFrame, ShareCard)
* app/lib/features/share/share_service.dart

Supporting Files:
* app/lib/core/receipt_styles.dart
* app/lib/copy/roasts.dart

External Integrations:
* share_plus (Android share sheet), path_provider (temp files)

## Ledger, Stats, Manual Log

Category: UI

Primary Files:
* app/lib/features/ledger/ledger_screen.dart (also ReceiptRow)
* app/lib/features/ledger/manual_log_screen.dart
* app/lib/core/stats.dart

Supporting Files:
* app/lib/data/dev_seed.dart (debug only)

## Corpo Wrapped

Category: UI

Primary Files:
* app/lib/features/wrapped/wrapped_screen.dart
* app/lib/features/wrapped/wrapped_slides.dart
* app/lib/core/wrapped.dart

External Integrations:
* flutter_animate

## Pro (Paywall, Billing, Perks)

Category: UI / Service

Primary Files:
* app/lib/features/pro/billing.dart
* app/lib/features/pro/paywall_screen.dart
* app/lib/features/pro/perks_screen.dart

Supporting Files:
* app/lib/core/achievements.dart
* app/lib/core/receipt_styles.dart
* app/lib/data/csv_export.dart

External Integrations:
* Google Play Billing via in_app_purchase (product `pro_unlock`)

## Copy

Category: Other

Primary Files:
* app/lib/copy/roasts.dart (roasts, CEO quotes, share captions, CEO rate constant)

## Store Assets Tooling

Category: CLI

Primary Files:
* app/tool/generate_store_assets_test.dart

Supporting Files:
* app/store_assets/raw/ (input captures), app/store_assets/play/ (output)
* app/android/app/src/main/res/mipmap-* (generated launcher icons)

## Android Build Config

Category: Infra

Primary Files:
* app/android/app/build.gradle.kts (release signing via key.properties)
* app/android/app/src/main/AndroidManifest.xml
* app/pubspec.yaml

## Website

Category: Page

Primary Files:
* web/index.html (landing + calculator)
* web/calc.js
* web/privacy.html

Supporting Files:
* web/styles.css, web/fonts/, web/favicon.svg, web/og.png
* web/vercel.json, .claude/launch.json (local preview)

External Integrations:
* Vercel hosting (project `fuck_corpo_v2-web`)

## Tests

Category: Other

Primary Files:
* app/test/*.dart (rate, stats, wrapped, session flow, share card, pro, billing, format)
