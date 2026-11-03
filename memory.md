# Corpo Dump / Fuck Corpo: project memory

Satirical app that calculates how much your employer pays you while you poop, smoke, or eat on the clock. Android first (Flutter), plus a static website. Ships as two editions: Corpo Dump (clean, Google Play) and F*ck Corpo Uncut (direct APK). Last updated 2026-11-01.

## Current state

| Area | Status |
|---|---|
| Android app (`app/`) | v1 plus Hostile Takeovers, in two editions. 39 tests passing. Play AAB and uncut APK both build. |
| Website (`web/`) | Live at https://www.corpodump.com (bare domain redirects to www). Privacy policy: https://www.corpodump.com/privacy |
| Play Store | Google account approved. Not submitted. Corpo Dump assets ready in `app/store_assets/play/`. |
| iOS (`app/ios/`) | Scaffolded 2026-11-02 on the Mac. Both editions build and the play edition runs on the iOS 26.5 simulator. Not on a device, not in App Store Connect. |

## Decisions

- **Platform:** Android first (developed on Windows), iOS from the same Flutter code (built on a Mac).
- **iOS (2026-11-02):** Xcode schemes `play` and `uncut` mirror the Android flavors (build configs `Debug-play`, `Release-uncut`, etc.). `play`: "Corpo Dump", `com.corpodump.app`, App Store IAP. `uncut`: "F*ck Corpo", `com.fcorpo.fcorpo`, for personal installs only (no App Store, no sideload channel). iPhone only, portrait only, iOS 15 minimum (Xcode 26 will not archive below 15). Signed by the individual team Nicholas Perry (`PGVTN7X3HQ`), automatic signing; Xcode has registered `com.corpodump.app` and made the App Store profile. Plugins come in through Swift Package Manager, so there is no Podfile. Billing uses StoreKit 2; the launch-time restore reads current entitlements and does not prompt for a password. Store copy in the paywall switches between Google Play and the App Store. `ios/Runner/Products.storekit` lets Xcode test `pro_unlock` locally (play scheme, run from Xcode). `ios/Runner/PrivacyInfo.xcprivacy` declares no tracking and no collected data.
- **Editions (2026-11-01):** Google Play bans profanity in apps and listings, including in-app text, so the original "censored name, uncensored app" plan was dropped. One codebase, two Android flavors. `play`: "Corpo Dump", `com.corpodump.app`, clean copy, paid Pro. `uncut`: "F*ck Corpo", `com.fcorpo.fcorpo` (keeps existing sideloaded data), full-send copy, free Pro, distributed as a direct APK. All profanity lives in `core/edition.dart`; `test/edition_test.dart` fails if it appears elsewhere in `lib/` or `tool/`. Builds default to clean. No hidden toggle in the Play build, and the Play edition never links to the APK.
- **Design:** payslip/receipt parody. Off-white paper `#F4F1E8`, ink `#1A1A1A`, stamp red `#A32D2D`, Courier Prime (bundled, OFL). Screens are parody paperwork (intake form, receipts, W-2(ish)). Mascot is a pixel-art fat-cat CEO who gets angrier as earnings rise. Dark mode is "night shift" carbon copy, selectable in Perks (System / Paper / Night shift).
- **Social:** solo app, no accounts or backend. All data on device (drift/SQLite + shared_preferences). Shareable 1080x1350 receipt and Wrapped images via the system share sheet.
- **Money:** free core plus one-time Pro unlock ("promotion to Management"), placeholder price $2.99. Uses Google's `in_app_purchase` plugin (chosen over RevenueCat: one non-consumable product does not need a third-party account). Purchases are trusted client-side, no receipt server.
- **Pay math:** hourly = amount / 3600 per second. Salary = amount / (hours per week x 52 x 3600). Website calculator uses the same formula.
- **CEO comparison:** a hypothetical CEO on a $20M package paid around the clock. Framed as hypothetical on purpose, not a factual claim.
- **Hostile Takeovers (2026-10-25):** throne sessions can be "takeovers" of another business. The user types the company name and picks an industry; no location permission, so the "nothing collected" privacy promise stands. Clocking out produces a damages invoice (playful utility estimates in `core/takeover.dart`) billed to that company. Holdings list on the Ledger is free; industry breakdown and takeover achievements are Pro. No map (would need location). Throne-only for now; late paperwork cannot log takeovers yet.
- **Database:** schema v2 added nullable `business_name`, `business_category`, `damages` to `sessions`. Migration in `data/database.dart`, covered by a v1-to-v2 upgrade test. Any future column change needs a new schema version and migration step.

## App layout (`app/lib/`)

- `core/`: pay rate math, formatting, stats and streaks, Wrapped stats, achievements, receipt styles, theme, takeover (categories, damages), portfolio, edition (brand and profanity copy).
- `data/`: drift database (sessions), settings repository (prefs), CSV export, debug-only fake-year seeder.
- `state/providers.dart`: Riverpod providers (profile, active session, Pro, receipt style, theme mode).
- `features/`: onboarding (intake form), timer, receipt, ledger (+ late paperwork), share (card + capture), wrapped, pro (paywall, billing, perks).
- `copy/roasts.dart`: all jokes, CEO quotes, captions. Edit copy here.
- `tool/generate_store_assets_test.dart`: regenerates launcher icons and Play graphics from app widgets. Run with `flutter test tool/generate_store_assets_test.dart`. Raw emulator captures go in `store_assets/raw/`.

## Pro

- Product ID `pro_unlock` (non-consumable). Must be created in Play Console > Monetize > In-app products.
- Pro unlocks: Doomscroll, Fake Meeting, Coffee Run modes; 15 achievements; takeover stats by industry (Portfolio intel); Gold Receipt, CEO Memo, Strike Poster styles; unhinged roast pack; CSV export.
- Purchases restore automatically at launch. Pending, canceled, and failed purchases never unlock.
- The uncut edition has Pro free because Play billing cannot work outside Play. `--dart-define=UNLOCK_PRO=true` also grants Pro at compile time for test builds. Never use either for a Play upload.
- Debug builds show "DEBUG: promote without paying", "DEBUG: seed fake year", and "DEBUG: demote" buttons. Hidden in release.

## Commands

```bash
flutter test
flutter build appbundle --release
flutter build apk --release --flavor uncut --dart-define=EDITION=uncut
flutter build ios --simulator --debug
flutter build ipa --release
```

To upload to App Store Connect, pass `--export-options-plist` with `method` app-store-connect and `destination` upload (team `PGVTN7X3HQ`). Flutter 3.44 then crashes looking for `build/ios/ipa/`; the upload has already gone through. Bump the build number in `pubspec.yaml` (`1.0.0+2`, ...) before each new upload.

Run from `app/`. `play` is the default flavor (`default-flavor` in `pubspec.yaml`). The bundle is for Play upload, at `build/app/outputs/bundle/playRelease/app-play-release.aab`. The APK is the uncut edition and the user's phone build, last copied to `C:\dev\fuck-corpo-uncut.apk`, outside the repo.

## Release signing

`app/android/app/build.gradle.kts` signs release builds with the upload key from `app/android/key.properties` (keys: `storePassword`, `keyPassword`, `keyAlias`, `storeFile`). Both that file and `*.jks` are gitignored. Without it, release builds fall back to the debug key (local testing only). The user has not created the upload key yet.

## Website

- Plain static HTML/CSS/JS in `web/`, no build step. Vercel project `fuck_corpo_v2-web` (team "naperry2011's projects"), deploys from GitHub `naperry2011/Fuck_Corpo_V2` with root directory `web`.
- Pages: landing + calculator (`index.html`, `calc.js`), privacy policy (`privacy.html`, served at `/privacy`).
- Local preview: `.claude/launch.json` config "web" (serves `web/` on port 4317).
- Old V1 project `fuck-corpo` was deleted, so `fuck-corpo.vercel.app` is free to reassign.

## Store facts (verified 2026-10-05 and 2026-11-01)

- Icon 512x512 PNG, no transparency. Feature graphic 1024x500. Phone screenshots: long side at most 2x the short side (so 1080x1920, not raw 1080x2400 captures).
- New personal Play accounts need a closed test with 12 testers opted in for 14 consecutive days before production.
- Title is 30 characters or less. Google's policy bans profanity in apps and listings and asks for listings suitable for a general audience. "Poop" and "dump" contain no swear words, but a reviewer could still object.
- Play apps may not update themselves or download executable code from outside Play.
- The package name locks permanently at the first upload.

## Open items

1. Rename the Windows checkout away from `Fuck_Corpo_V2` (for example `C:\dev\corpo-dump`) before the final Play build. The Mac checkout already lives at `~/dev/corpo-dump` (moved 2026-11-02). Dart embeds the build path in `libapp.so`, so the word is in the binary even though users never see it.
2. Create upload keystore and `key.properties`.
3. Done 2026-11-02: `corpodump.com` (Namecheap) points at Vercel. Use https://www.corpodump.com/privacy as the privacy URL in both stores, never the old `vercel.app` address.
4. Clean up the website: clean privacy page, move uncensored material to a separate page, set absolute `og:image` URL, add sitemap. Then host the uncut APK and add the domain to share cards (Play edition must not link to the APK).
5. Done: `support@corpodump.com` is on the site and forwards through Namecheap email forwarding. Use it as the support contact in both stores.
6. Play Console: create the app (listing copy below), upload to internal testing (locks `com.corpodump.app`), create `pro_unlock`, add license testers, content rating questionnaire, data safety (no data collected). Test a real purchase.
7. Run the 12-tester / 14-day closed test.
8. Optional: retake screenshots (emulator shield icon in the status bar; faded status bar on Holdings).
9. Optional later: app icon variants (Pro).
10. Takeover follow-ups: allow takeovers in late paperwork; consider an opt-in location map (needs privacy policy and data safety updates).
11. iOS (2026-11-02): App Store Connect app "Corpo Dump: Get Paid to Poop" (Apple ID 6830046769, SKU `corpodump-ios`) created. `pro_unlock` non-consumable created at $2.99, all regions, still needs its paywall review screenshot. Build 1.0.0 (1) uploaded; TestFlight group "Internal" (auto-distribution) has the account holder. Listing filled 2026-11-02: subtitle "Your boss pays you to poop", Entertainment + Lifestyle, 13+ (frequent crude humor, infrequent tobacco), free app in 175 regions, privacy URL and "Data Not Collected" (saved, not yet published), description, keywords, support/marketing URL https://www.corpodump.com, 6.3-inch screenshots, review notes, build 1 attached. Left before submit: publish the privacy answers, App Review contact info, `pro_unlock` paywall review screenshot. The same account also sells "Paid to Operate" (live); watch for guideline 4.3 near-duplicate rejection.

## Play listing copy

- Title: Corpo Dump: Get Paid to Poop
- Short description: Your boss pays you to poop. Clock every dump, smoke break and lunch heist.
- Category: Entertainment.
- Full description: lead with the "Your boss pays you by the second" hook, then Hostile Takeovers, features, Management perks, and the satire line. Name no real companies and use no swear words. Screenshots use made-up companies from `data/dev_seed.dart`.

## Gotchas

- iOS screenshots: boot the iPhone 17 Pro Max simulator, set the status bar with `xcrun simctl status_bar booted override --time 9:41`, build with `--dart-define=SCREENSHOTS=true` (hides the debug buttons, since the simulator only runs debug builds), seed from the Ledger, capture with `xcrun simctl io booted screenshot` into `store_assets/raw_ios/`, then run the asset tool. It writes `store_assets/app_store/6.3/` (1206x2622, the size App Store Connect requires) and `6.9/` (optional). To preset settings, shut the simulator down and write the app container's `Library/Preferences/com.corpodump.app.plist` directly; `defaults write` gets overwritten by the prefs cache.
- Xcode 27's `lipo` rejects Flutter 3.44's two-architecture check, so simulator builds are arm64 only (`ARCHS[sdk=iphonesimulator*] = arm64`). Remove that once Flutter is upgraded.
- iOS builds fail inside `~/Documents` on the Mac: it is iCloud Drive, which adds file attributes that codesign rejects ("resource fork, Finder information, or similar detritus not allowed"). The Mac checkout lives at `~/dev/corpo-dump` for this reason; keep it out of `~/Documents` and `~/Desktop`.

- The Android emulator `emulator-5554` is shared with another project (`com.nickperry.afterword`). Check the foreground app before automating taps.
- `uiautomator dump` fails while the timer is ticking (screen never idles); tap by coordinates then.
- In Git Bash, set `MSYS_NO_PATHCONV=1` before adb commands that use `/sdcard/...` paths.
- Store screenshots: use the `play` flavor. Seed and promote in a debug build, then install the release build over it so debug buttons disappear and the data stays.
- A swear-word check of a built app: search `lib/arm64-v8a/libapp.so` inside the APK.
