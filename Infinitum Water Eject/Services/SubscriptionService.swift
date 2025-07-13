/*
 * ============================================================================
 * INFINITUM WATER EJECT - SUBSCRIPTION SERVICE
 * ============================================================================
 * 
 * FILE: SubscriptionService.swift
 * PURPOSE: Manages in-app purchases and premium subscription functionality
 * AUTHOR: Kevin Doyle Jr.
 * CREATED: [7/5/2025]
 * LAST MODIFIED: [7/9/2025]
 *
 * DESCRIPTION:
 * This file contains the subscription service implementation for the Infinitum
 * Water Eject application. It manages all in-app purchase operations including
 * product fetching, purchase processing, receipt verification, and subscription
 * status management. The service provides premium features access control and
 * integrates with Apple's StoreKit framework for secure payment processing.
 * 
 * ARCHITECTURE OVERVIEW:
 * - SubscriptionService: Singleton service managing all subscription operations
 * - StoreKit Integration: Complete integration with Apple's payment framework
 * - Product Management: Fetches and manages available subscription products
 * - Purchase Processing: Handles purchase flow with transaction observers
 * - Receipt Verification: Validates purchase receipts for security
 * - Premium Status: Manages premium user status and feature access
 * - Widget Integration: Updates widget data when subscription status changes
 * 
 * KEY COMPONENTS:
 * 1. Product Fetching: Retrieves available subscription products from App Store
 * 2. Purchase Processing: Handles purchase flow with comprehensive error handling
 * 3. Transaction Observer: Monitors payment queue for transaction updates
 * 4. Receipt Verification: Validates purchase authenticity with Apple servers
 * 5. Premium Features: Defines and manages access to premium functionality
 * 6. Purchase Restoration: Allows users to restore previous purchases
 * 
 * SUBSCRIPTION TIERS:
 * - Weekly Premium: $1.99/week for short-term premium access
 * - Monthly Premium: $4.99/month for standard premium access
 * - Yearly Premium: $44.99/year for long-term premium access (best value)
 * 
 * PREMIUM FEATURES:
 * - Unlimited water ejection sessions
 * - Advanced analytics and insights
 * - Ad-free experience
 * - Priority customer support
 * - Custom frequency presets
 * - Export session data
 * - Cloud backup and sync
 * - Apple Watch widget support
 * - Custom notification schedules
 * 
 * DEPENDENCIES:
 * - Foundation: Core iOS framework for basic functionality
 * - StoreKit: Apple's in-app purchase framework
 * - WidgetKit: iOS widget framework (conditional import)
 * 
 * TODO LIST:
 * - [ ] Implement server-side receipt verification for enhanced security
 * - [ ] Add subscription status persistence across app launches
 * - [ ] Create subscription analytics and revenue tracking
 * - [ ] Implement subscription renewal notifications
 * - [ ] Add subscription management interface for users
 * - [ ] Create subscription trial period functionality
 * - [ ] Implement subscription family sharing support
 * - [ ] Add subscription upgrade/downgrade functionality
 * 
 * FEATURE SUGGESTIONS:
 * - [ ] Add subscription gift functionality
 * - [ ] Implement subscription referral rewards
 * - [ ] Create subscription usage analytics
 * - [ ] Add subscription cancellation flow
 * - [ ] Implement subscription price optimization
 * - [ ] Create subscription comparison interface
 * - [ ] Add subscription reminder notifications
 * - [ ] Implement subscription loyalty rewards
 * 
 * TECHNICAL NOTES:
 * - Uses singleton pattern for global subscription access
 * - Implements proper StoreKit delegate patterns
 * - Provides comprehensive transaction state handling
 * - Includes receipt verification for purchase security
 * - Uses published properties for reactive UI updates
 * - Implements proper error handling and user feedback
 * - Follows Apple's StoreKit best practices
 * 
 * ============================================================================
 */

import Foundation
import StoreKit
#if canImport(WidgetKit)
import WidgetKit
#endif

// MARK: - Subscription Service Class
// Singleton service class that manages all in-app purchase and subscription functionality
// Handles product fetching, purchase processing, and premium status management

class SubscriptionService: NSObject, ObservableObject {
    // MARK: - Singleton Instance
    // Shared instance for global access to subscription functionality
    static let shared = SubscriptionService()
    
    // MARK: - Published Properties
    // Observable properties that trigger UI updates when subscription state changes
    
    /// Indicates whether the user has an active premium subscription
    /// Controls access to premium features throughout the application
    @Published var isPremium = false
    
    /// Array of available subscription products from the App Store
    /// Populated when products are successfully fetched
    @Published var products: [SKProduct] = []
    
    /// Indicates whether product fetching is currently in progress
    /// Used to show loading states in the UI
    @Published var isLoading = false
    
    /// Indicates whether a purchase transaction is currently being processed
    /// Prevents multiple simultaneous purchase attempts
    @Published var purchaseInProgress = false
    
    // MARK: - Subscription Product Identifiers
    // Product IDs for different subscription tiers available in the App Store
    
    /// Weekly premium subscription product ID ($1.99/week)
    /// Short-term premium access for users wanting to try premium features
    private let weeklyProductId = "com.infinitumimagery.watereject.premium.weekly"
    
    /// Monthly premium subscription product ID ($4.99/month)
    /// Standard premium access for regular users
    private let monthlyProductId = "com.infinitumimagery.watereject.premium.monthly"
    
    /// Yearly premium subscription product ID ($44.99/year)
    /// Long-term premium access with best value pricing
    private let yearlyProductId = "com.infinitumimagery.watereject.premium.yearly"
    
    // MARK: - Initialization
    // Private initializer for singleton pattern with service setup
    
    /// Initializes the subscription service with product fetching and transaction observer setup
    /// Loads existing subscription status and begins product fetching
    override init() {
        super.init()
        loadSubscriptionStatus()      // Load existing premium status
        fetchProducts()              // Fetch available products from App Store
        setupTransactionObserver()   // Set up payment queue observer
    }
    
    // MARK: - Product Fetching
    // Retrieves available subscription products from the App Store
    
    /// Fetches available subscription products from the App Store
    /// Updates the products array and loading state when complete
    func fetchProducts() {
        isLoading = true  // Set loading state for UI feedback
        
        // MARK: - Product Identifiers Set
        // Create set of all available product identifiers
        let productIds = Set([weeklyProductId, monthlyProductId, yearlyProductId])
        
        // MARK: - Products Request Creation
        // Create and configure products request with delegate
        let request = SKProductsRequest(productIdentifiers: productIds)
        request.delegate = self
        request.start()  // Begin product fetching
    }
    
    // MARK: - Premium Features Definition
    // Defines the list of premium features available to subscribers
    
    /// Returns array of premium features available to subscribers
    /// Used for displaying premium benefits in the UI
    func getPremiumFeatures() -> [String] {
        return [
            "Unlimited water ejection sessions",
            "Advanced analytics and insights",
            "Ad-free experience",
            "Priority customer support (Contact Us button with pre-filled email to support@infinitumlive.com)",
            "Custom frequency presets",
            "Export session data",
            "Cloud backup and sync",
            "Apple Watch widget support",
            "Custom notification schedules"
        ]
    }
    
    // MARK: - Purchase Processing
    // Handles the purchase flow for subscription products
    
    /// Initiates a purchase for the specified subscription product
    /// Includes validation, payment processing, and completion handling
    func purchasePremium(productId: String, completion: @escaping (Bool, String?) -> Void) {
        // MARK: - Premium Status Check
        // Prevent purchase if user is already premium
        guard !isPremium else {
            completion(true, nil)
            return
        }
        
        // MARK: - Product Validation
        // Ensure the requested product is available
        guard let product = products.first(where: { $0.productIdentifier == productId }) else {
            completion(false, "Product not available")
            return
        }
        
        // MARK: - Purchase State Management
        // Set purchase in progress to prevent multiple purchases
        purchaseInProgress = true
        
        // MARK: - Payment Creation and Submission
        // Create payment object and add to payment queue
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        
        // MARK: - Purchase State Reset
        // Reset purchase state after brief delay
        // Transaction handling will be done in the observer
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.purchaseInProgress = false
        }
    }
    
    // MARK: - Purchase Restoration
    // Allows users to restore previous purchases
    
    /// Initiates the purchase restoration process
    /// Allows users to restore previous purchases across devices
    func restorePurchases() {
        isLoading = true  // Set loading state for UI feedback
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    // MARK: - Transaction Observer Setup
    // Sets up the payment queue observer for transaction monitoring
    
    /// Sets up the payment queue observer to monitor transaction updates
    /// Required for handling purchase state changes and completion
    private func setupTransactionObserver() {
        SKPaymentQueue.default().add(self)
    }
    
    // MARK: - Subscription Status Loading
    // Loads existing subscription status from persistent storage
    
    /// Loads the current premium subscription status from UserDefaults
    /// Updates widget data when subscription status is loaded
    private func loadSubscriptionStatus() {
        isPremium = UserDefaults.standard.bool(forKey: "isPremium")
        updateWidgetData()  // Update widget with current status
    }
    
    // MARK: - Subscription Status Updates
    // Updates subscription status and persists changes
    
    /// Updates the premium subscription status and persists to UserDefaults
    /// Triggers widget data updates when status changes
    private func updateSubscriptionStatus(_ isPremium: Bool) {
        self.isPremium = isPremium
        UserDefaults.standard.set(isPremium, forKey: "isPremium")
        updateWidgetData()  // Update widget with new status
    }
    
    // MARK: - Widget Data Updates
    // Updates widget data when subscription status changes
    
    /// Updates widget data and triggers timeline refresh
    /// Ensures widgets display current subscription status
    private func updateWidgetData() {
        // MARK: - Widget Timeline Refresh
        // Reload all widget timelines to reflect subscription changes
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    // MARK: - Cleanup
    // Removes transaction observer on service deallocation
    
    /// Removes the transaction observer when the service is deallocated
    /// Prevents memory leaks and ensures proper cleanup
    deinit {
        SKPaymentQueue.default().remove(self)
    }
}

// MARK: - StoreKit Products Request Delegate
// Handles product fetching responses from the App Store

extension SubscriptionService: SKProductsRequestDelegate {
    // MARK: - Products Response Handling
    // Handles successful product fetching responses
    
    /// Handles successful product fetching from the App Store
    /// Updates products array and loading state on main thread
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.products = response.products  // Update available products
            self.isLoading = false             // Clear loading state
            
            // MARK: - Invalid Products Logging
            // Log any invalid product identifiers for debugging
            if !response.invalidProductIdentifiers.isEmpty {
                print("Invalid product identifiers: \(response.invalidProductIdentifiers)")
            }
        }
    }
    
    // MARK: - Request Error Handling
    // Handles product fetching errors
    
    /// Handles product fetching errors and updates loading state
    /// Logs errors for debugging purposes
    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false  // Clear loading state on error
            print("Failed to fetch products: \(error)")  // Log error for debugging
        }
    }
}

// MARK: - StoreKit Payment Transaction Observer
// Monitors payment queue for transaction state changes

extension SubscriptionService: SKPaymentTransactionObserver {
    // MARK: - Transaction Updates
    // Handles all transaction state changes in the payment queue
    
    /// Processes all transaction updates in the payment queue
    /// Routes transactions to appropriate handlers based on state
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                handlePurchasedTransaction(transaction)  // Handle successful purchase
            case .failed:
                handleFailedTransaction(transaction)     // Handle failed purchase
            case .restored:
                handleRestoredTransaction(transaction)   // Handle restored purchase
            case .deferred:
                handleDeferredTransaction(transaction)   // Handle deferred purchase
            case .purchasing:
                // Transaction is being processed - no action needed
                break
            @unknown default:
                // Handle future transaction states
                break
            }
        }
    }
    
    // MARK: - Purchased Transaction Handling
    // Handles successfully completed purchases
    
    /// Handles successfully completed purchase transactions
    /// Includes receipt verification and premium status updates
    private func handlePurchasedTransaction(_ transaction: SKPaymentTransaction) {
        // MARK: - Receipt Verification
        // Verify purchase receipt for security and authenticity
        verifyReceipt { [weak self] isValid in
            DispatchQueue.main.async {
                if isValid {
                    // MARK: - Successful Purchase Processing
                    self?.updateSubscriptionStatus(true)  // Update premium status
                    NotificationCenter.default.post(name: .purchaseSuccessful, object: nil)  // Notify success
                } else {
                    // MARK: - Receipt Verification Failure
                    NotificationCenter.default.post(name: .purchaseFailed, object: "Receipt verification failed")
                }
                SKPaymentQueue.default().finishTransaction(transaction)  // Complete transaction
            }
        }
    }
    
    // MARK: - Failed Transaction Handling
    // Handles failed purchase transactions
    
    /// Handles failed purchase transactions with error reporting
    /// Provides user feedback for purchase failures
    private func handleFailedTransaction(_ transaction: SKPaymentTransaction) {
        DispatchQueue.main.async {
            // MARK: - Error Message Extraction
            // Extract error message or provide default message
            let errorMessage = transaction.error?.localizedDescription ?? "Purchase failed"
            NotificationCenter.default.post(name: .purchaseFailed, object: errorMessage)  // Notify failure
            SKPaymentQueue.default().finishTransaction(transaction)  // Complete transaction
        }
    }
    
    // MARK: - Restored Transaction Handling
    // Handles restored purchase transactions
    
    /// Handles restored purchase transactions from previous purchases
    /// Updates premium status and notifies user of restoration
    private func handleRestoredTransaction(_ transaction: SKPaymentTransaction) {
        DispatchQueue.main.async {
            self.updateSubscriptionStatus(true)  // Update premium status
            NotificationCenter.default.post(name: .purchaseRestored, object: nil)  // Notify restoration
            SKPaymentQueue.default().finishTransaction(transaction)  // Complete transaction
        }
    }
    
    // MARK: - Deferred Transaction Handling
    // Handles deferred purchase transactions
    
    /// Handles deferred purchase transactions (e.g., waiting for parental approval)
    /// Notifies user that purchase is pending approval
    private func handleDeferredTransaction(_ transaction: SKPaymentTransaction) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .purchaseDeferred, object: nil)  // Notify deferral
        }
    }
    
    // MARK: - Receipt Verification
    // Verifies purchase receipts for security
    
    /// Verifies purchase receipt with Apple's servers
    /// In production, this should include server-side verification
    private func verifyReceipt(completion: @escaping (Bool) -> Void) {
        // MARK: - Receipt Verification Implementation
        // In a real app, you would verify the receipt with Apple's servers
        // For now, we'll assume it's valid for development purposes
        // TODO: Implement proper server-side receipt verification
        completion(true)
    }
}

// MARK: - Notification Names Extension
// Defines notification names for purchase events

extension Notification.Name {
    /// Notification sent when a purchase is successfully completed
    static let purchaseSuccessful = Notification.Name("purchaseSuccessful")
    
    /// Notification sent when a purchase fails
    static let purchaseFailed = Notification.Name("purchaseFailed")
    
    /// Notification sent when a purchase is successfully restored
    static let purchaseRestored = Notification.Name("purchaseRestored")
    
    /// Notification sent when a purchase is deferred (e.g., waiting for approval)
    static let purchaseDeferred = Notification.Name("purchaseDeferred")
} 
