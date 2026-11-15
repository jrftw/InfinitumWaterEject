# Creator changelog

This is the owner/developer record. The app’s Settings → What’s New contains the shorter customer-facing history. Build entries describe repository work, not proof that every historical build was released by Apple. Dates are omitted where the public release date has not been verified.

## 1.0.3 (1) — next release, prepared locally

### Experience

- Four main tabs: Eject, Tools, Activity and Settings. Usage charts now live inside Activity rather than competing with history as a separate tab.
- Cycle names describe duration: Short, Standard, Long, Extended and Live tuning. Existing stored enum values and session history remain compatible.
- Compact home presentation, clearer native cycle controls, adaptive action layouts, organized settings and native help sections.
- Customer release notes cover versions 1.0.0 through 1.0.3, with the running version identified automatically.

### Fixes

- Replaced the nonfunctional Clear All Data placeholder with confirmed session-history deletion. Purchase entitlements, presets and appearance settings are retained.
- Native file sharing exports a real CSV and supports iPad presentation. Export derives end timestamps from recorded start times and durations, and uses stable decimal formatting and proper escaping.
- Activity observes persistence updates directly. “Last 30 days” now uses a rolling 30-day interval and excludes future sessions.
- Seasonal theme selection and automatic mode survive relaunch. Automatic mode can be disabled, and nested theme changes refresh the UI.
- Settings reads no longer save/publish during SwiftUI rendering. Isolated in-memory persistence is available to regression tests without modifying widget or achievement state.
- Reminder permission is confirmed before scheduling. Failed/denied scheduling turns the toggle off and explains the problem. Additional times are editable; duplicate clock times do not schedule multiple notifications. Re-enabling includes saved additional times.
- Opening cycle settings no longer overwrites custom preferences. Tone position zero is a valid saved setting. Live tuning starts from the actual audio value.
- Invalid or extreme persisted speaker-test frequencies are bounded before conversion to display integers or playback inputs.
- Email support falls back to a mailto link when the in-app composer is unavailable. Pushed help, safety and achievement pages keep the parent navigation; theme selection uses a single-column stack on iPad.

### Monetization and release scope

- Keeps the approved $7.99 US lifetime product, entitlement handling, banners, completed-cycle interstitial limits and opt-in rewarded preset access from 1.0.2.
- Keeps free eject cycles, speaker tests, widgets, Siri and Shortcuts.
- No App Store upload, submission, listing mutation or website publication is part of this preparation. Existing 1.0.2 release assets remain separate.
- Test and archive results are recorded in `release/1.0.3-readiness.md`.

## 1.0.2 (1) — monetization and speaker utilities

- Lifetime Premium removes ads and enables custom speaker-test preset saving; existing purchase identifiers remain supported for restoration.
- Free 10-second speaker tests from 50 to 2,000 Hz, with quick frequency choices. Presets can also be saved during an explicitly rewarded 30-minute unlock; saved presets remain usable afterward.
- Home Screen and Lock Screen widgets open the app. App Intents and Siri/Shortcuts start a 30-second cycle, stop audio or open speaker tools.
- Consent-aware AdMob banners, post-session interstitials and optional rewarded access. Full-screen ads do not interrupt active audio or block Start; completion eligibility uses actual elapsed session time.
- Fixed early audio completion, bounded persisted custom settings, interruption handling, purchase/refund/expiry handling, and local diagnostics.
- Refreshed store copy, screenshots, localization backups and website SEO/content, with accurate safety and device-support claims.
- Submission and publication details are preserved in the existing 1.0.2 release records; they are not assertions about its current live status.

## 1.0.1 — compatibility, themes and submission fixes

### Build 3

- Synchronized all target build numbers to 3 (`bc9864d`), following the tracking-permission update (`af23fda`).

### Build 2

- Corrected Apple Watch compilation and watch-icon validation (`bf65f2e`, `ba140d0`); Watch functionality was temporarily disabled rather than advertised as supported.
- Added the theme service and seasonal appearance model (`199450e`), with analytics/compilation fixes in this development period (`e7fa869`).

### Build 1

- Synchronized marketing versions and release metadata (`a8b9d85`).

## 1.0.0 — original app

### Build 2

- iOS 16 availability/compatibility fixes, mail handling, tab organization and Settings help navigation (`5ceb393`; historical in-app notes).

### Build 1

- Timed audio cycles, configurable settings, local session history/statistics, appearance, optional reminders and help.
- Removed CloudKit/iCloud entitlements and finalized App Store localization/compliance configuration (`b7f48a4`, `96bc495`).
- Older source/UI included claims for dust removal and remote Watch/AirPods/Mac support. Those claims are not carried forward as verified capabilities.
