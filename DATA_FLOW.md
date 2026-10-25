# Data Flow

Generated: 2026-10-25 | commit dc30960 | by /code-map

No server. All app data stays on the device.

## Pay Profile

Source: IntakeFormScreen
Transport: ProfileNotifier (state/providers.dart)
Processor: SettingsRepository
Storage: shared_preferences
Downstream Consumers: TimerScreen, ReceiptScreen, ManualLogScreen, Ledger, Wrapped (rate + currency + boss name)

## Live Session (Clock In / Out)

Source: TimerScreen
Transport: ActiveSessionNotifier
Processor: core/rate.dart (earnings), SettingsRepository (active session survives app kill)
Storage: shared_preferences (in-progress), drift `sessions` table (on clock out)
Downstream Consumers: ReceiptScreen, sessionsProvider

## Hostile Takeover

Source: TimerScreen -> TakeoverSheet (typed company + category)
Transport: ActiveSessionNotifier.start(target)
Processor: core/takeover.dart Damages (on clock out)
Storage: shared_preferences (in-progress target), drift `sessions` columns business_name, business_category, damages
Downstream Consumers: InvoiceCard (ReceiptScreen), core/portfolio.dart -> HoldingsSection, Wrapped takeover slide, takeover achievements, CSV export

## Manual Log

Source: ManualLogScreen
Transport: AppDatabase.addSession
Processor: core/rate.dart
Storage: drift `sessions` table
Downstream Consumers: sessionsProvider

## Session Reads

Source: drift `sessions` table
Transport: sessionsProvider (watch stream)
Processor: core/stats.dart, core/wrapped.dart, core/achievements.dart
Storage: none (derived)
Downstream Consumers: LedgerScreen, TimerScreen today panel, WrappedScreen, PerksScreen

## Share Image

Source: ShareCard / Wrapped slide (RepaintBoundary)
Transport: share_service.captureCard -> PNG in temp dir
Processor: none
Storage: app cache
Downstream Consumers: Android share sheet (share_plus) -> user-chosen app

## CSV Export

Source: sessionsProvider
Transport: data/csv_export.dart -> temp file
Storage: app cache
Downstream Consumers: Android share sheet

## Pro Purchase

Source: PaywallScreen
Transport: BillingNotifier -> in_app_purchase -> Google Play Billing
Processor: BillingNotifier.handlePurchases (purchaseStream)
Storage: shared_preferences `pro_unlocked` (via ProNotifier)
Downstream Consumers: proProvider -> modes, styles, roasts, achievements, CSV

## Preferences

Source: PerksScreen
Transport: ReceiptStyleNotifier, ThemeModeNotifier
Storage: shared_preferences
Downstream Consumers: ShareCard, Wrapped slides, MaterialApp themeMode

## Website Calculator

Source: form inputs in web/index.html
Transport: DOM input events
Processor: web/calc.js
Storage: none (nothing leaves the browser)
Downstream Consumers: result rows on the page
