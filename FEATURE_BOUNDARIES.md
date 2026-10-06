# Feature Boundaries

Generated: 2026-10-05 | commit be5fb09 | by /code-map

## Core (app/lib/core)

Owns: pay rate math, formatting, stats/streaks, Wrapped aggregates, achievements, mode and receipt-style enums, theme palette.
Does NOT Own: persistence, widgets (except theme data), state.
Communicates With: data/database.dart (Session type only).
Isolation Level: Strong

## Data (app/lib/data)

Owns: drift schema and queries, preferences keys, CSV serialization, debug seeding.
Does NOT Own: business rules, UI, Riverpod state.
Communicates With: core (BreakMode, rate), drift, shared_preferences.
Isolation Level: Strong

## State (app/lib/state/providers.dart)

Owns: app-wide providers (prefs, settings, db, sessions, profile, active session, Pro, receipt style, theme mode).
Does NOT Own: billing, UI.
Communicates With: data, core.
Isolation Level: Moderate

## Onboarding

Owns: intake form, pay profile entry and edits.
Does NOT Own: rate math, storage.
Communicates With: profileProvider.
Isolation Level: Strong

## Timer

Owns: clock in/out UI, live ticker, mode selection, today panel.
Does NOT Own: session persistence, receipts, stats math.
Communicates With: activeSessionProvider, sessionsProvider, receipt, ledger (ReceiptRow), paywall.
Isolation Level: Moderate

## Receipt and Share

Owns: receipt screen, share card rendering (ReceiptFrame), PNG capture and share-sheet handoff.
Does NOT Own: session data, receipt style selection.
Communicates With: profileProvider, proProvider, receiptStyleProvider, share_plus.
Isolation Level: Moderate

## Ledger

Owns: period stats view, receipt list, void, late paperwork form, debug seed button.
Does NOT Own: stats math, Wrapped.
Communicates With: sessionsProvider, databaseProvider, receipt, wrapped, paywall.
Isolation Level: Moderate

## Wrapped

Owns: year-in-review slides, story navigation, slide sharing.
Does NOT Own: aggregation math (core/wrapped.dart), frame visuals (share_card.dart).
Communicates With: sessionsProvider, receiptStyleProvider, share_service.
Isolation Level: Moderate

## Pro

Owns: Play Billing connection, purchase handling, paywall, Perks tab (achievements, styles, theme, export, licenses).
Does NOT Own: the Pro flag storage (ProNotifier in providers.dart), gated features' implementations.
Communicates With: in_app_purchase, proProvider, receiptStyleProvider, themeModeProvider, sessionsProvider.
Isolation Level: Moderate

## Store Asset Tool

Owns: generated launcher icons and Play graphics.
Does NOT Own: app runtime behavior.
Communicates With: app widgets (read-only render), filesystem.
Isolation Level: Strong

## Website

Owns: landing page, calculator, privacy policy, hosting config.
Does NOT Own: anything in app/ (pay formula duplicated in web/calc.js, not shared).
Communicates With: Vercel only.
Isolation Level: Strong
