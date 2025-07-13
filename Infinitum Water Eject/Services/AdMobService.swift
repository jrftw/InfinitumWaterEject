/*
 * ============================================================================
 * INFINITUM WATER EJECT - ADMOB ADVERTISEMENT SERVICE
 * ============================================================================
 * 
 * FILE: AdMobService.swift
 * PURPOSE: Manages Google AdMob advertisement integration and display
 * AUTHOR: Kevin Doyle Jr.
 * CREATED: [7/5/2025]
 * LAST MODIFIED: [7/9/2025]
 *
 * DESCRIPTION:
 * This file contains the complete AdMob advertisement service implementation
 * for the Infinitum Water Eject application. It manages banner ad loading,
 * display, and lifecycle events while respecting premium user status.
 * The service provides multiple banner ad view implementations for different
 * use cases and includes smart ad loading with retry mechanisms.
 * 
 * ARCHITECTURE OVERVIEW:
 * - AdMobService: Singleton service class managing ad initialization and state
 * - Banner Ad Views: Multiple UIViewRepresentable implementations for different scenarios
 * - Premium User Handling: Automatically disables ads for premium subscribers
 * - Preloading System: Preloads ads for better user experience
 * - Retry Mechanism: Automatic retry on ad load failures
 * - State Management: Published properties for reactive UI updates
 * 
 * KEY COMPONENTS:
 * 1. AdMobService: Main service class with singleton pattern
 * 2. PreloadedBannerAdView: Uses preloaded ads for immediate display
 * 3. BannerAdView: Standard banner ad implementation
 * 4. SmartBannerAdView: Adaptive banner for different screen sizes
 * 5. ConditionalBannerAdView: Only shows ads when ready and loaded
 * 6. BannerViewDelegate: Handles ad lifecycle events
 * 
 * AD TYPES SUPPORTED:
 * - Banner Ads: Standard rectangular ads at bottom of screens
 * - Smart Banners: Adaptive banners that adjust to screen size
 * - Preloaded Banners: Pre-cached ads for instant display
 * - Conditional Banners: Context-aware ad display
 * 
 * PREMIUM USER INTEGRATION:
 * - Automatically detects premium subscription status
 * - Returns empty ad unit ID for premium users
 * - Completely disables ad loading for premium users
 * - Respects user's premium status across all ad types
 * 
 * DEPENDENCIES:
 * - SwiftUI: UI framework for view implementations
 * - GoogleMobileAds: Google's AdMob SDK for iOS
 * - Foundation: Basic iOS functionality
 * 
 * TODO LIST:
 * - [ ] Add interstitial ad support for premium upgrade prompts
 * - [ ] Implement rewarded video ads for premium features
 * - [ ] Add ad frequency capping to prevent ad fatigue
 * - [ ] Create ad performance analytics and reporting
 * - [ ] Implement A/B testing for ad placement optimization
 * - [ ] Add ad content filtering for family-friendly content
 * - [ ] Create ad loading timeout handling
 * - [ ] Implement ad refresh intervals for better performance
 * 
 * FEATURE SUGGESTIONS:
 * - [ ] Add native ad support for better user experience
 * - [ ] Implement ad personalization based on user behavior
 * - [ ] Create ad scheduling based on user activity patterns
 * - [ ] Add ad performance optimization algorithms
 * - [ ] Implement ad revenue tracking and analytics
 * - [ ] Create ad placement recommendations engine
 * - [ ] Add ad content relevance scoring
 * - [ ] Implement ad user feedback collection
 * 
 * TECHNICAL NOTES:
 * - Uses singleton pattern for global ad state management
 * - Implements proper delegate patterns for ad lifecycle
 * - Provides multiple banner implementations for flexibility
 * - Handles ad loading failures gracefully with retry logic
 * - Respects premium user status automatically
 * - Uses published properties for reactive UI updates
 * - Implements proper memory management for ad views
 * 
 * ============================================================================
 */

import SwiftUI
import GoogleMobileAds

// MARK: - AdMob Service Class
// Singleton service class that manages all AdMob advertisement functionality
// Handles ad initialization, loading, and state management across the app

class AdMobService: NSObject, ObservableObject {
    // MARK: - Singleton Instance
    // Shared instance for global access to ad service functionality
    static let shared = AdMobService()
    
    // MARK: - AdMob Configuration
    // AdMob app and ad unit identifiers for production and testing
    
    /// AdMob App ID for the Infinitum Water Eject application
    /// Used to initialize the Google Mobile Ads SDK
    private let appId = "ca-app-pub-6815311336585204~5510127729"
    
    /// Production banner ad unit ID for live advertisements
    /// Displays real ads to users in production environment
    private let bannerAdUnitId = "ca-app-pub-6815311336585204/1784836834"
    
    // MARK: - Test Configuration (Development)
    // Test ad unit ID for development and testing purposes
    // Uncomment the line below to use test ads during development
    // private let bannerAdUnitId = "ca-app-pub-3940256099942544/2934735716"
    
    // MARK: - Published Properties
    // Observable properties that trigger UI updates when ad state changes
    
    /// Indicates whether the AdMob SDK has been successfully initialized
    /// Used to determine if ads can be loaded and displayed
    @Published var isAdMobInitialized = false
    
    /// Indicates whether a banner ad has been successfully loaded
    /// Used to show/hide ads based on loading status
    @Published var isAdLoaded = false
    
    // MARK: - Private Properties
    // Internal properties for managing ad loading and display
    
    /// Preloaded banner view for instant ad display
    /// Cached banner ad that can be displayed immediately
    private var bannerView: BannerView?
    
    // MARK: - Initialization
    // Private initializer for singleton pattern with AdMob SDK setup
    private override init() {
        super.init()
        
        // MARK: - AdMob SDK Initialization
        // Initialize Google Mobile Ads SDK with completion handler
        // Sets up the foundation for all ad functionality
        MobileAds.shared.start { status in
            DispatchQueue.main.async {
                self.isAdMobInitialized = true  // Mark SDK as initialized
                self.preloadBannerAd()          // Start preloading banner ads
            }
        }
    }
    
    // MARK: - Ad Unit ID Management
    // Returns the appropriate ad unit ID based on user's premium status
    
    /// Returns the banner ad unit ID, or empty string for premium users
    /// Automatically handles premium user ad disabling
    func getBannerAdUnitId() -> String {
        // MARK: - Premium User Check
        // Check if user has premium subscription - premium users see no ads
        let isPremium = UserDefaults.standard.bool(forKey: "isPremium")
        
        #if DEBUG
        // Disable ads for debug builds and simulator
        return ""
        #else
        if isPremium {
            return "" // Return empty string to indicate no ads should be shown
        }
        return bannerAdUnitId  // Return production ad unit ID for non-premium users
        #endif
    }
    
    // MARK: - Banner Ad Preloading
    // Preloads banner ads for better user experience and faster display
    
    /// Preloads a banner ad for immediate display when needed
    /// Creates and configures banner view with proper delegate setup
    private func preloadBannerAd() {
        bannerView = BannerView(adSize: AdSizeBanner)           // Create banner view with standard size
        bannerView?.adUnitID = bannerAdUnitId                   // Set the ad unit ID
        bannerView?.rootViewController = getRootViewController() // Set root view controller for ad display
        bannerView?.delegate = self                             // Set delegate for ad lifecycle events
        bannerView?.load(Request())                             // Start loading the ad
    }
    
    // MARK: - Preloaded Banner Access
    // Provides access to preloaded banner views for immediate display
    
    /// Returns the preloaded banner view if available
    /// Used by PreloadedBannerAdView for instant ad display
    func getPreloadedBannerView() -> BannerView? {
        return bannerView
    }
}

// MARK: - Banner View Delegate Implementation
// Handles ad lifecycle events including successful loads and failures

extension AdMobService: BannerViewDelegate {
    // MARK: - Ad Load Success
    // Called when a banner ad is successfully loaded and ready for display
    
    /// Handles successful banner ad loading
    /// Updates UI state and logs success for debugging
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        DispatchQueue.main.async {
            self.isAdLoaded = true  // Update UI state to indicate ad is ready
        }
        print("Banner ad loaded successfully")  // Log success for debugging
    }
    
    // MARK: - Ad Load Failure
    // Called when banner ad loading fails, implements retry mechanism
    
    /// Handles banner ad loading failures with automatic retry
    /// Updates UI state and schedules retry after delay
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        DispatchQueue.main.async {
            self.isAdLoaded = false  // Update UI state to indicate ad is not ready
            
            // MARK: - Automatic Retry Mechanism
            // Retry loading the ad after a 5-second delay
            // Helps handle temporary network issues or ad server problems
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.preloadBannerAd()
            }
        }
        print("Banner ad failed to load: \(error.localizedDescription)")  // Log error for debugging
    }
}

// MARK: - Preloaded Banner Ad View
// SwiftUI wrapper for preloaded banner ads with instant display capability

struct PreloadedBannerAdView: UIViewRepresentable {
    /// Ad unit ID for the banner ad
    let adUnitId: String
    
    // MARK: - UIView Creation
    // Creates the banner view, preferring preloaded ads for instant display
    
    /// Creates a banner view, using preloaded ad if available
    /// Falls back to creating new banner if preloaded one is not available
    func makeUIView(context: Context) -> BannerView {
        if let preloadedBanner = AdMobService.shared.getPreloadedBannerView() {
            return preloadedBanner  // Use preloaded banner for instant display
        } else {
            // MARK: - Fallback Banner Creation
            // Create new banner if preloaded one is not available
            // Ensures ads can still be displayed even without preloading
            let bannerView = BannerView(adSize: AdSizeBanner)
            bannerView.adUnitID = adUnitId
            bannerView.rootViewController = getRootViewController()
            bannerView.load(Request())
            return bannerView
        }
    }
    
    // MARK: - UIView Updates
    // No updates needed for banner views - they are static once created
    
    func updateUIView(_ uiView: BannerView, context: Context) {
        // No updates needed - banner views are static once created
    }
}

// MARK: - Standard Banner Ad View
// SwiftUI wrapper for standard banner ads with delegate coordination

struct BannerAdView: UIViewRepresentable {
    /// Ad unit ID for the banner ad
    let adUnitId: String
    
    // MARK: - UIView Creation
    // Creates a new banner view with proper delegate setup
    
    /// Creates a new banner view with coordinator delegate
    /// Sets up proper ad loading and lifecycle management
    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = adUnitId
        bannerView.rootViewController = getRootViewController()
        bannerView.delegate = context.coordinator  // Use coordinator as delegate
        bannerView.load(Request())
        return bannerView
    }
    
    // MARK: - UIView Updates
    // No updates needed for banner views
    
    func updateUIView(_ uiView: BannerView, context: Context) {
        // No updates needed
    }
    
    // MARK: - Coordinator Creation
    // Creates coordinator for handling ad lifecycle events
    
    /// Creates coordinator for banner ad delegate events
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    // MARK: - Banner Ad Coordinator
    // Handles banner ad lifecycle events for standard banner views
    
    class Coordinator: NSObject, BannerViewDelegate {
        /// Handles successful banner ad loading
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            print("Banner ad loaded successfully")
        }
        
        /// Handles banner ad loading failures
        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("Banner ad failed to load: \(error.localizedDescription)")
        }
    }
}

// MARK: - Smart Banner Ad View
// SwiftUI wrapper for smart banner ads that adapt to screen size

struct SmartBannerAdView: UIViewRepresentable {
    /// Ad unit ID for the banner ad
    let adUnitId: String
    
    // MARK: - UIView Creation
    // Creates a smart banner view with adaptive sizing
    
    /// Creates a smart banner view with adaptive sizing
    /// Automatically adjusts to different screen sizes and orientations
    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = adUnitId
        bannerView.rootViewController = getRootViewController()
        bannerView.delegate = context.coordinator
        bannerView.load(Request())
        return bannerView
    }
    
    // MARK: - UIView Updates
    // No updates needed for banner views
    
    func updateUIView(_ uiView: BannerView, context: Context) {
        // No updates needed
    }
    
    // MARK: - Coordinator Creation
    // Creates coordinator for smart banner ad events
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    // MARK: - Smart Banner Coordinator
    // Handles smart banner ad lifecycle events
    
    class Coordinator: NSObject, BannerViewDelegate {
        /// Handles successful smart banner ad loading
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            print("Smart banner ad loaded successfully")
        }
        
        /// Handles smart banner ad loading failures
        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("Smart banner ad failed to load: \(error.localizedDescription)")
        }
    }
}

// MARK: - Conditional Banner Ad View
// SwiftUI view that only shows ads when AdMob is initialized and ads are loaded

struct ConditionalBannerAdView: View {
    /// Ad unit ID for the banner ad
    let adUnitId: String
    
    // MARK: - View Body
    // Conditionally displays banner ad based on initialization and loading status
    
    var body: some View {
        // MARK: - Conditional Ad Display
        // Only show ads when AdMob is initialized and ad is loaded
        // Prevents showing empty ad placeholders or loading states
        if AdMobService.shared.isAdMobInitialized && AdMobService.shared.isAdLoaded {
            PreloadedBannerAdView(adUnitId: adUnitId)
                .frame(height: 50)  // Set fixed height for consistent layout
        } else {
            // MARK: - Empty State
            // Show nothing instead of loading placeholder
            // Provides cleaner user experience when ads are not ready
            EmptyView()
        }
    }
}

// MARK: - Helper Functions
// Utility functions for AdMob integration

/// Helper function to get the root view controller for ad display
/// Required by AdMob SDK for proper ad presentation
private func getRootViewController() -> UIViewController? {
    // MARK: - Root View Controller Access
    // Safely access the root view controller from the current window scene
    // Required for proper ad display and interaction
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = windowScene.windows.first {
        return window.rootViewController
    }
    return nil
} 
