import SwiftUI
import GoogleMobileAds

class AdMobService: NSObject, ObservableObject {
    static let shared = AdMobService()
    
    // AdMob IDs
    private let appId = "ca-app-pub-6815311336585204~5510127729"
    private let bannerAdUnitId = "ca-app-pub-6815311336585204/1784836834"
    
    // Test IDs for development (uncomment for testing)
    // private let bannerAdUnitId = "ca-app-pub-3940256099942544/2934735716"
    
    @Published var isAdMobInitialized = false
    @Published var isAdLoaded = false
    
    private var bannerView: BannerView?
    
    private override init() {
        super.init()
        // Initialize Google Mobile Ads SDK
        MobileAds.shared.start { status in
            DispatchQueue.main.async {
                self.isAdMobInitialized = true
                self.preloadBannerAd()
            }
        }
    }
    
    func getBannerAdUnitId() -> String {
        // Check if user is premium - don't show ads for premium users
        let isPremium = UserDefaults.standard.bool(forKey: "isPremium")
        if isPremium {
            return "" // Return empty string to indicate no ads should be shown
        }
        return bannerAdUnitId
    }
    
    private func preloadBannerAd() {
        bannerView = BannerView(adSize: AdSizeBanner)
        bannerView?.adUnitID = bannerAdUnitId
        bannerView?.rootViewController = getRootViewController()
        bannerView?.delegate = self
        bannerView?.load(Request())
    }
    
    func getPreloadedBannerView() -> BannerView? {
        return bannerView
    }
}

// MARK: - GADBannerViewDelegate
extension AdMobService: BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        DispatchQueue.main.async {
            self.isAdLoaded = true
        }
        print("Banner ad loaded successfully")
    }
    
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        DispatchQueue.main.async {
            self.isAdLoaded = false
            // Retry loading after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.preloadBannerAd()
            }
        }
        print("Banner ad failed to load: \(error.localizedDescription)")
    }
}

// Pre-loaded Banner Ad View
struct PreloadedBannerAdView: UIViewRepresentable {
    let adUnitId: String
    
    func makeUIView(context: Context) -> BannerView {
        if let preloadedBanner = AdMobService.shared.getPreloadedBannerView() {
            return preloadedBanner
        } else {
            // Fallback: create new banner if preloaded one is not available
            let bannerView = BannerView(adSize: AdSizeBanner)
            bannerView.adUnitID = adUnitId
            bannerView.rootViewController = getRootViewController()
            bannerView.load(Request())
            return bannerView
        }
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {
        // No updates needed
    }
}

// Banner Ad View using UIViewRepresentable (for new ads)
struct BannerAdView: UIViewRepresentable {
    let adUnitId: String
    
    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = adUnitId
        bannerView.rootViewController = getRootViewController()
        bannerView.delegate = context.coordinator
        bannerView.load(Request())
        return bannerView
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, BannerViewDelegate {
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            print("Banner ad loaded successfully")
        }
        
        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("Banner ad failed to load: \(error.localizedDescription)")
        }
    }
}

// Smart Banner Ad View that adapts to screen size
struct SmartBannerAdView: UIViewRepresentable {
    let adUnitId: String
    
    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = adUnitId
        bannerView.rootViewController = getRootViewController()
        bannerView.delegate = context.coordinator
        bannerView.load(Request())
        return bannerView
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, BannerViewDelegate {
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            print("Smart banner ad loaded successfully")
        }
        
        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("Smart banner ad failed to load: \(error.localizedDescription)")
        }
    }
}

// Conditional Banner Ad View that only shows when AdMob is initialized and ad is loaded
struct ConditionalBannerAdView: View {
    let adUnitId: String
    
    var body: some View {
        if AdMobService.shared.isAdMobInitialized && AdMobService.shared.isAdLoaded {
            PreloadedBannerAdView(adUnitId: adUnitId)
                .frame(height: 50)
        } else {
            // Show nothing instead of loading placeholder
            EmptyView()
        }
    }
}

// Helper function to get root view controller
private func getRootViewController() -> UIViewController? {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = windowScene.windows.first {
        return window.rootViewController
    }
    return nil
} 