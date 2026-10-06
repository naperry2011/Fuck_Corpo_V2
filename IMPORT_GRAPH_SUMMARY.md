# Import Graph Summary

Generated: 2026-10-05 | commit be5fb09 | by /code-map

Scope: app/lib. web/ has no module graph (one script).

## Core Dependency Nodes

* app/lib/state/providers.dart (imported by every screen and by billing.dart)
* app/lib/data/database.dart (Session type used by core/stats, core/wrapped, core/achievements, csv_export, share, ledger, receipt)
* app/lib/core/break_mode.dart (modes used across core, data, and all session UIs)
* app/lib/core/format.dart (money/duration formatting, most UIs)
* app/lib/widgets/payslip_parts.dart (shared UI parts, nearly every screen)
* app/lib/core/theme.dart (Payslip palette; theme, share card, store tool)

## Broadly Reused Utilities

* app/lib/widgets/pixel_ceo.dart (timer, share card, wrapped, store tool)
* app/lib/copy/roasts.dart (timer, receipt, wrapped, share captions)
* app/lib/features/share/share_card.dart (ReceiptFrame reused by wrapped slides)

## Cross-Feature Imports

* features/timer -> features/ledger (ReceiptRow), features/receipt, features/pro (paywall), features/onboarding
* features/ledger -> features/receipt, features/wrapped, features/pro (paywall)
* features/pro/perks_screen -> features/onboarding
* features/wrapped -> features/share
* main.dart -> features/pro/billing.dart

## Circular Dependencies

* None at file level observed. features/pro/billing.dart imports state/providers.dart; providers.dart does not import billing.

## Potential Refactor Risk Areas

* app/lib/state/providers.dart (single file holds all app-wide state; high fan-in)
* app/lib/core/* importing data/database.dart (domain logic depends on the generated drift Session type)
* app/lib/features/ledger/ledger_screen.dart (exports ReceiptRow used by timer)
