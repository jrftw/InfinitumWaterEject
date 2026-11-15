import SwiftUI
import GoogleMobileAds
import UserMessagingPlatform
import Combine

@MainActor
final class AdMobService: NSObject, ObservableObject, FullScreenContentDelegate {
    static let shared = AdMobService()
    @Published private(set) var isAdMobInitialized = false
    @Published private(set) var privacyOptionsRequired = false
    @Published private(set) var rewardedReady = false
    @Published private(set) var isPresenting = false
    @Published private(set) var toolsUnlockedUntil: Date? = UserDefaults.standard.object(forKey: "toolsUnlockedUntil") as? Date
    @Published private(set) var consentRevision = 0
    @Published var message: String?
    private var consentRequested = false
    private var starting = false
    private var interstitial: InterstitialAd?
    private var rewarded: RewardedAd?
    private var activeInterstitial: InterstitialAd?
    private var activeRewarded: RewardedAd?
    private var interstitialLoadedAt: Date?
    private var rewardedLoadedAt: Date?
    private var loadingFullScreen = false
    private var retryAttempts = 0
    private var retryWork: DispatchWorkItem?
    private var subscriptions = Set<AnyCancellable>()
    private let launchedAt = Date()

    private override init() {
        super.init()
        SubscriptionService.shared.$isPremium.combineLatest(SubscriptionService.shared.$entitlementChecked)
            .receive(on: DispatchQueue.main).sink { [weak self] premium, checked in
                guard let self, checked else { return }
                if premium {
                    self.interstitial = nil; self.rewarded = nil; self.rewardedReady = false
                    self.retryWork?.cancel()
                }
                else { self.startIfPermitted() }
            }.store(in: &subscriptions)
    }
    var canRequestAds: Bool {
        SubscriptionService.shared.entitlementChecked && !SubscriptionService.shared.isPremium &&
        ConsentInformation.shared.canRequestAds && UIApplication.shared.applicationState == .active
    }
    var toolsUnlocked: Bool { toolsUnlockedUntil.map { $0 > Date() } ?? false }
    private func unit(_ key: String, test: String) -> String {
        #if DEBUG
        return test
        #else
        return Bundle.main.object(forInfoDictionaryKey: key) as? String ?? ""
        #endif
    }
    func getBannerAdUnitId() -> String {
        guard canRequestAds, isAdMobInitialized else { return "" }
        #if DEBUG
        return "ca-app-pub-3940256099942544/2934735716"
        #else
        return "ca-app-pub-6815311336585204/1784836834"
        #endif
    }
    func prepare() {
        guard !consentRequested, let controller = Self.presenter, !WaterEjectionService.shared.isPlaying else { return }
        consentRequested = true
        ConsentInformation.shared.requestConsentInfoUpdate(with: RequestParameters()) { [weak self] error in
            Task { @MainActor in
                guard let self else { return }
                self.privacyOptionsRequired = ConsentInformation.shared.privacyOptionsRequirementStatus == .required
                if error == nil {
                    do { try await ConsentForm.loadAndPresentIfRequired(from: controller) }
                    catch { GrowthMetrics.shared.record("consent_form_failed") }
                    self.privacyOptionsRequired = ConsentInformation.shared.privacyOptionsRequirementStatus == .required
                    self.consentRevision += 1
                    self.startIfPermitted()
                } else {
                    GrowthMetrics.shared.record("consent_update_failed")
                    self.startIfPermitted()
                }
            }
        }
    }
    func showPrivacyOptions() {
        guard let controller = Self.presenter, !isPresenting else { return }
        ConsentForm.presentPrivacyOptionsForm(from: controller) { [weak self] error in
            Task { @MainActor in
                if let error { self?.message = error.localizedDescription }
                self?.interstitial = nil; self?.rewarded = nil; self?.rewardedReady = false
                self?.consentRevision += 1
                self?.startIfPermitted()
            }
        }
    }
    private func startIfPermitted() {
        guard canRequestAds else { return }
        if isAdMobInitialized { preloadFullScreen(); return }
        guard !starting else { return }
        starting = true
        MobileAds.shared.requestConfiguration.maxAdContentRating = GADMaxAdContentRating.general
        MobileAds.shared.start { [weak self] _ in
            Task { @MainActor in
                self?.starting = false
                self?.isAdMobInitialized = true
                self?.preloadFullScreen()
            }
        }
    }
    func preloadFullScreen() {
        guard canRequestAds, isAdMobInitialized, !loadingFullScreen else { return }
        loadingFullScreen = true
        retryWork?.cancel()
        Task {
            defer {
                loadingFullScreen = false
                if canRequestAds, (interstitial == nil || rewarded == nil), retryAttempts < 3 {
                    retryAttempts += 1
                    let work = DispatchWorkItem { AdMobService.shared.preloadFullScreen() }
                    retryWork = work
                    DispatchQueue.main.asyncAfter(deadline: .now() + 15 * pow(2, Double(retryAttempts - 1)), execute: work)
                } else if interstitial != nil, rewarded != nil { retryAttempts = 0 }
            }
            let interstitialID = unit("AdMobInterstitialUnitID", test: "ca-app-pub-3940256099942544/4411468910")
            let rewardedID = unit("AdMobRewardedUnitID", test: "ca-app-pub-3940256099942544/1712485313")
            if interstitial == nil, !interstitialID.isEmpty {
                do {
                    GrowthMetrics.shared.record("interstitial_requested")
                    let ad = try await InterstitialAd.load(with: interstitialID, request: Request())
                    if canRequestAds {
                        interstitial = ad; interstitialLoadedAt = Date(); configure(ad)
                        GrowthMetrics.shared.record("interstitial_loaded")
                    }
                } catch { GrowthMetrics.shared.record("interstitial_load_failed") }
            }
            if rewarded == nil, !rewardedID.isEmpty, canRequestAds {
                do {
                    GrowthMetrics.shared.record("rewarded_requested")
                    let ad = try await RewardedAd.load(with: rewardedID, request: Request())
                    if canRequestAds {
                        rewarded = ad; rewardedLoadedAt = Date(); rewardedReady = true
                        ad.fullScreenContentDelegate = self
                        ad.paidEventHandler = { value in
                            GrowthMetrics.shared.recordRevenue(value: value.value.decimalValue, currency: value.currencyCode, precision: value.precision.rawValue)
                        }
                        GrowthMetrics.shared.record("rewarded_loaded")
                    }
                } catch { GrowthMetrics.shared.record("rewarded_load_failed") }
            }
        }
    }
    private func configure(_ ad: InterstitialAd) {
        ad.fullScreenContentDelegate = self
        ad.paidEventHandler = { value in
            GrowthMetrics.shared.recordRevenue(value: value.value.decimalValue, currency: value.currencyCode, precision: value.precision.rawValue)
        }
    }
    /// Called only immediately after a real cycle finishes. Never queue an ad for later navigation.
    func sessionCompleted() {
        let defaults = UserDefaults.standard
        let count = defaults.integer(forKey: "adCompletedSessions") + 1
        defaults.set(count, forKey: "adCompletedSessions")
        let today = Calendar.current.startOfDay(for: Date())
        if defaults.object(forKey: "adDay") as? Date != today {
            defaults.set(today, forKey: "adDay"); defaults.set(0, forKey: "adsShownToday")
        }
        guard canRequestAds, !isPresenting, !WaterEjectionService.shared.isPlaying,
              AppNavigation.shared.selectedTab == 0,
              Date().timeIntervalSince(launchedAt) >= 60,
              GrowthMetrics.shared.cohort == "post_session",
              AdPlacementPolicy.allows(completed: count, shownToday: defaults.integer(forKey: "adsShownToday"),
                  lastShown: defaults.object(forKey: "lastFullScreenAd") as? Date, now: Date()),
              let controller = Self.presenter, controller.presentedViewController == nil,
              let ad = interstitial, let loaded = interstitialLoadedAt, Date().timeIntervalSince(loaded) < 3500 else {
            if interstitialLoadedAt.map({ Date().timeIntervalSince($0) >= 3500 }) == true { interstitial = nil }
            preloadFullScreen(); return
        }
        do { try ad.canPresent(from: controller) } catch { interstitial = nil; return }
        activeInterstitial = ad
        interstitial = nil
        isPresenting = true
        defaults.set(Date(), forKey: "lastFullScreenAd")
        defaults.set(defaults.integer(forKey: "adsShownToday") + 1, forKey: "adsShownToday")
        ad.present(from: controller)
    }
    func unlockToolsWithReward() {
        guard canRequestAds, !isPresenting, !WaterEjectionService.shared.isPlaying,
              let ad = rewarded, let loaded = rewardedLoadedAt, Date().timeIntervalSince(loaded) < 3500,
              let controller = Self.presenter, controller.presentedViewController == nil else {
            message = "No video is available right now. Basic speaker tests are always free."
            rewarded = nil; rewardedReady = false; preloadFullScreen(); return
        }
        do { try ad.canPresent(from: controller) } catch { message = error.localizedDescription; return }
        activeRewarded = ad
        rewarded = nil; rewardedReady = false; isPresenting = true
        ad.present(from: controller) { [weak self] in
            Task { @MainActor in
                let expiry = Date().addingTimeInterval(1800)
                self?.toolsUnlockedUntil = expiry
                UserDefaults.standard.set(expiry, forKey: "toolsUnlockedUntil")
                GrowthMetrics.shared.record("reward_earned")
            }
        }
    }
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        activeInterstitial = nil; activeRewarded = nil
        isPresenting = false; preloadFullScreen()
    }
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        activeInterstitial = nil; activeRewarded = nil
        isPresenting = false; message = "The ad could not be displayed. Please continue."
        GrowthMetrics.shared.record("full_screen_present_failed")
    }
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) { GrowthMetrics.shared.record("full_screen_impression") }
    static var presenter: UIViewController? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return scenes.first(where: { $0.activationState == .foregroundActive })?.windows.first(where: \.isKeyWindow)?.rootViewController
    }
}

/// Each placement owns its view. Never attach one cached UIKit banner to multiple screens.
struct BannerAdView: UIViewRepresentable {
    let adUnitId: String
    func makeCoordinator() -> Coordinator { Coordinator() }
    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = adUnitId
        banner.rootViewController = AdMobService.presenter
        banner.delegate = context.coordinator
        banner.paidEventHandler = { value in
            GrowthMetrics.shared.recordRevenue(value: value.value.decimalValue, currency: value.currencyCode, precision: value.precision.rawValue)
        }
        context.coordinator.load(banner)
        return banner
    }
    func updateUIView(_ uiView: BannerView, context: Context) {}
    static func dismantleUIView(_ uiView: BannerView, coordinator: Coordinator) {
        coordinator.retry?.cancel(); uiView.delegate = nil
    }
    @MainActor
    final class Coordinator: NSObject, BannerViewDelegate {
        var attempts = 0
        var retry: DispatchWorkItem?
        func load(_ banner: BannerView) {
            guard AdMobService.shared.canRequestAds else { return }
            GrowthMetrics.shared.record("banner_requested"); banner.load(Request())
        }
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            attempts = 0; GrowthMetrics.shared.record("banner_loaded")
        }
        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            GrowthMetrics.shared.record("banner_load_failed_\((error as NSError).code)")
            guard attempts < 3 else { return }
            attempts += 1
            let work = DispatchWorkItem { [weak self, weak bannerView] in
                guard let self, let bannerView, bannerView.window != nil else { return }
                self.load(bannerView)
            }
            retry = work
            DispatchQueue.main.asyncAfter(deadline: .now() + min(120, 15 * pow(2, Double(attempts - 1))), execute: work)
        }
        func bannerViewDidRecordImpression(_ bannerView: BannerView) { GrowthMetrics.shared.record("banner_impression") }
    }
}

struct ConditionalBannerAdView: View {
    let adUnitId: String
    @ObservedObject private var ads = AdMobService.shared
    @ObservedObject private var purchases = SubscriptionService.shared
    @ObservedObject private var audio = WaterEjectionService.shared
    @Environment(\.scenePhase) private var phase
    var body: some View {
        if !purchases.isPremium, purchases.entitlementChecked, ads.isAdMobInitialized,
           !audio.isPlaying, phase == .active, !ads.getBannerAdUnitId().isEmpty {
            VStack(spacing: 4) {
                Text("Advertisement").font(.caption2).foregroundStyle(.secondary)
                BannerAdView(adUnitId: ads.getBannerAdUnitId()).frame(width: 320, height: 50)
            }.frame(maxWidth: .infinity).padding(.vertical, 8)
        }
    }
}
