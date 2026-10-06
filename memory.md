# Fuck Corpo: project memory

Satirical app that calculates how much your employer pays you while you poop, smoke, or eat on the clock. Android first (Flutter), plus a static website. Last updated 2026-10-05.

## Current state

| Area | Status |
|---|---|
| Android app (`app/`) | Feature complete for v1. 28 tests passing. Release AAB builds. |
| Website (`web/`) | Live at https://fuckcorpov2-web.vercel.app |
| Play Store | Not submitted. Listing assets ready in `app/store_assets/play/`. |
| iOS | Not started (needs a Mac or cloud build service). |

## Decisions

- **Platform:** Android only for now; the user develops on Windows. Flutter so iOS can follow from the same code.
- **Name:** censored in store metadata and launcher label ("F*ck Corpo"). In-app copy and website stay uncensored ("full send").
- **Design:** payslip/receipt parody. Off-white paper `#F4F1E8`, ink `#1A1A1A`, stamp red `#A32D2D`, Courier Prime (bundled, OFL). Screens are parody paperwork (intake form, receipts, W-2(ish)). Mascot is a pixel-art fat-cat CEO who gets angrier as earnings rise. Dark mode is "night shift" carbon copy, selectable in Perks (System / Paper / Night shift).
- **Social:** solo app, no accounts or backend. All data on device (drift/SQLite + shared_preferences). Shareable 1080x1350 receipt and Wrapped images via the system share sheet.
- **Money:** free core plus one-time Pro unlock ("promotion to Management"), placeholder price $2.99. Uses Google's `in_app_purchase` plugin (chosen over RevenueCat: one non-consumable product does not need a third-party account). Purchases are trusted client-side, no receipt server.
- **Pay math:** hourly = amount / 3600 per second. Salary = amount / (hours per week x 52 x 3600). Website calculator uses the same formula.
- **CEO comparison:** a hypothetical CEO on a $20M package paid around the clock. Framed as hypothetical on purpose, not a factual claim.

## App layout (`app/lib/`)

- `core/`: pay rate math, formatting, stats and streaks, Wrapped stats, achievements, receipt styles, theme.
- `data/`: drift database (sessions), settings repository (prefs), CSV export, debug-only fake-year seeder.
- `state/providers.dart`: Riverpod providers (profile, active session, Pro, receipt style, theme mode).
- `features/`: onboarding (intake form), timer, receipt, ledger (+ late paperwork), share (card + capture), wrapped, pro (paywall, billing, perks).
- `copy/roasts.dart`: all jokes, CEO quotes, captions. Edit copy here.
- `tool/generate_store_assets_test.dart`: regenerates launcher icons and Play graphics from app widgets. Run with `flutter test tool/generate_store_assets_test.dart`. Raw emulator captures go in `store_assets/raw/`.

## Pro

- Product ID `pro_unlock` (non-consumable). Must be created in Play Console > Monetize > In-app products.
- Pro unlocks: Doomscroll, Fake Meeting, Coffee Run modes; 10 achievements; Gold Receipt, CEO Memo, Strike Poster styles; unhinged roast pack; CSV export.
- Purchases restore automatically at launch. Pending, canceled, and failed purchases never unlock.
- Personal builds: `--dart-define=UNLOCK_PRO=true` grants Pro at compile time. Never use it for a Play upload.
- Debug builds show "DEBUG: promote without paying", "DEBUG: seed fake year", and "DEBUG: demote" buttons. Hidden in release.

## Commands

```bash
flutter test
flutter build appbundle --release
flutter build apk --release --dart-define=UNLOCK_PRO=true
```

The first is run from `app/`; the bundle is for Play upload; the APK is the personal phone build with Pro unlocked (last copy saved at `C:\dev\fuck-corpo-personal-pro.apk`, outside the repo).

## Release signing

`app/android/app/build.gradle.kts` signs release builds with the upload key from `app/android/key.properties` (keys: `storePassword`, `keyPassword`, `keyAlias`, `storeFile`). Both that file and `*.jks` are gitignored. Without it, release builds fall back to the debug key (local testing only). The user has not created the upload key yet.

## Website

- Plain static HTML/CSS/JS in `web/`, no build step. Vercel project `fuck_corpo_v2-web` (team "naperry2011's projects"), deploys from GitHub `naperry2011/Fuck_Corpo_V2` with root directory `web`.
- Pages: landing + calculator (`index.html`, `calc.js`), privacy policy (`privacy.html`, served at `/privacy`).
- Local preview: `.claude/launch.json` config "web" (serves `web/` on port 4317).
- Old V1 project `fuck-corpo` was deleted, so `fuck-corpo.vercel.app` is free to reassign.

## Store facts (verified 2026-10-05)

- Icon 512x512 PNG, no transparency. Feature graphic 1024x500. Phone screenshots: long side at most 2x the short side (so 1080x1920, not raw 1080x2400 captures).
- New personal Play accounts need a closed test with 12 testers opted in for 14 consecutive days before production.

## Open items

1. Create upload keystore and `key.properties`.
2. Play Console: create listing (copy drafted in session), `pro_unlock` product, license testers, content rating questionnaire (expect Teen), data safety (no data collected).
3. Run the 12-tester / 14-day closed test.
4. Decide whether uncensored in-app text in screenshots is acceptable for the listing; check Google's metadata policy first.
5. Confirm package ID `com.fcorpo.fcorpo` before first upload (permanent).
6. Pick a domain; then set absolute `og:image` URL, add sitemap, and put the store link and domain on share cards.
7. Add a real contact email to `web/privacy.html` (currently a "coming soon" line) before Play submission.
8. Optional later: app icon variants (Pro), iOS build.

## Gotchas

- The Android emulator `emulator-5554` is shared with another project (`com.nickperry.afterword`). Check the foreground app before automating taps.
- `uiautomator dump` fails while the timer is ticking (screen never idles); tap by coordinates then.
- In Git Bash, set `MSYS_NO_PATHCONV=1` before adb commands that use `/sdcard/...` paths.
