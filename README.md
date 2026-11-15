# Infinitum Water Eject

Native SwiftUI iPhone/iPad utility. This branch prepares **1.0.2 (1)** for iOS 16+.

## Current features

- Timed eject tones, custom cycle settings and realtime frequency adjustment.
- Free 50–2,000 Hz speaker tests; custom saved presets with lifetime Premium or optional 30-minute rewarded access.
- Home Screen small/medium and Lock Screen circular/rectangular widgets. Widget links open the app before playing audio.
- App Intents for Start Water Ejection (30 seconds), Stop Audio, and Open Speaker Tools, with Siri phrases and Shortcuts discovery.
- Existing local session history and achievements retained. Completion counts measure usage, not water removal or repair success.
- Verified StoreKit 2 entitlements; lifetime purchase, refunds, restores, and existing subscription identifiers supported. New purchase UI offers lifetime only. Prices come from Apple.
- Consent-gated AdMob banners and post-session interstitials; Debug uses Google's sample units. No ad interrupts audio or blocks Start.
- Optional on-device diagnostics for session/purchase/ad events, currency-separated ad revenue estimates, and active days. No automatic analytics upload.

## Build and test

Open `Infinitum Water Eject.xcodeproj` in Xcode. Select the `Infinitum Water Eject` scheme. Use your Apple Developer team for device signing and enable the existing `group.com.infinitumimagery.watereject` App Group for both app and widget extension.

```sh
xcodebuild -project 'Infinitum Water Eject.xcodeproj' \
  -scheme 'Infinitum Water Eject' -destination 'platform=iOS Simulator,name=iPhone 18 Pro' \
  CODE_SIGNING_ALLOWED=NO test
```

`WaterEjectTests` runs native audio/history, placement-cap, lifetime purchase/refund, and accelerated subscription-expiry regression checks. StoreKit tests use a local configuration and do not charge real money. The test target requires iOS 17+ with the installed Xcode; the app and widget deployment target remains iOS 16.

For screenshot capture, Debug accepts `--snapshot-route eject`, `--snapshot-route tools` or `--snapshot-route history`. These arguments only select a screen and suppress ad-consent UI for captures; they do not grant Premium or start audio. Release does not include this path.

## Release configuration

App ID: `6748260343`. Bundle ID: `Infinitum-Imagery-LLC.Infinitum-Water-Eject`.

Lifetime non-consumable: `com.infinitumimagery.watereject.premium.lifetime`. Approved starting price from the owner: **US $7.99**; Apple supplies localized prices.

Production ad units are in the app's Info.plist:

- Existing banner: `ca-app-pub-6815311336585204/1784836834`
- Completed-cycle interstitial: `ca-app-pub-6815311336585204/9270556090`
- Optional rewarded preset saving: `ca-app-pub-6815311336585204/7957474425`

Interstitial eligibility: after any completed eject cycle lasting at least 25 seconds, once at least 25 seconds have elapsed in the app, at least 3 minutes apart, at most 3 per local day. Every free installation is eligible; no banner-only holdout is applied. Banners adapt to the available layout width. The AdMob unit also caps interstitial impressions to 3 per 24 hours. Rewarded ads are shown only after explicit opt-in and grant access only through the SDK reward callback.

`release/store-localizations.json` backs up the 10 store descriptions/promotional texts/keywords/release notes prepared for the next version. `release/website-content.html` backs up the published article at https://infinitumlive.com/infinitum-water-eject/. The page has a focused SEO title and meta description, the existing canonical URL, SoftwareApplication structured data, FAQs, accurate advertising/privacy copy, and app-specific social artwork. It identifies 1.0.2 features as forthcoming until App Review approval and release.

Water Eject-specific European and US privacy messages are published in AdMob, and the existing published IDFA explainer now includes this app. UMP completes the consent flow before any ad request. Info.plist includes the ATT explanation and 50 SKAdNetwork identifiers from Google’s official integration guide. App Store privacy labels declare the pinned Google SDK data categories, linkage, purposes, and optional device-ID tracking. The lifetime purchase and actual paywall screenshot have been added to the draft review submission. Fresh iPhone and iPad screenshots are uploaded.

Fourteen regression/StoreKit/capture tests pass, and the signed 1.0.2 (1) archive and App Store distribution export succeed. A signed physical-device acceptance pass remains unverified. The public website’s old ad-free/repair claims have been replaced. The app and lifetime non-consumable were submitted together and are Waiting for Review. Automatic release after approval is enabled. The app’s trader status uses the verified developer business contact information, with the owner’s explicit approval. Apple approval and production revenue improvement remain unverified.

For population revenue, conversion and retention, use AdMob and App Store Connect reporting. Local diagnostic exports are scoped to one installation and must not be presented as aggregate business metrics. A centralized analytics backend is not configured in this branch.

Historical `*_GUIDE.md` and `*_SUMMARY.md` files predate this branch and contain proposals or old implementation claims; use current source and verified builds as the authority.
