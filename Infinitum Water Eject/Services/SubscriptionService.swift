import Foundation
import StoreKit
#if canImport(WidgetKit)
import WidgetKit
#endif

class SubscriptionService: NSObject, ObservableObject {
    static let shared = SubscriptionService()
    
    @Published var isPremium = false
    @Published var products: [SKProduct] = []
    @Published var isLoading = false
    @Published var purchaseInProgress = false
    
    // Subscription Product IDs
    private let weeklyProductId = "com.infinitumimagery.watereject.premium.weekly" // $1.99/week
    private let monthlyProductId = "com.infinitumimagery.watereject.premium.monthly" // $4.99/month
    private let yearlyProductId = "com.infinitumimagery.watereject.premium.yearly" // $44.99/year
    
    override init() {
        super.init()
        loadSubscriptionStatus()
        fetchProducts()
        setupTransactionObserver()
    }
    
    func fetchProducts() {
        isLoading = true
        let productIds = Set([weeklyProductId, monthlyProductId, yearlyProductId])
        let request = SKProductsRequest(productIdentifiers: productIds)
        request.delegate = self
        request.start()
    }
    
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
    
    func purchasePremium(productId: String, completion: @escaping (Bool, String?) -> Void) {
        guard !isPremium else {
            completion(true, nil)
            return
        }
        
        guard let product = products.first(where: { $0.productIdentifier == productId }) else {
            completion(false, "Product not available")
            return
        }
        
        purchaseInProgress = true
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        
        // Store completion handler for later use
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // This will be handled in the transaction observer
            self.purchaseInProgress = false
        }
    }
    
    func restorePurchases() {
        isLoading = true
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    private func setupTransactionObserver() {
        SKPaymentQueue.default().add(self)
    }
    
    private func loadSubscriptionStatus() {
        isPremium = UserDefaults.standard.bool(forKey: "isPremium")
        updateWidgetData()
    }
    
    private func updateSubscriptionStatus(_ isPremium: Bool) {
        self.isPremium = isPremium
        UserDefaults.standard.set(isPremium, forKey: "isPremium")
        updateWidgetData()
    }
    
    private func updateWidgetData() {
        // Update widget data when subscription status changes
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
}

// MARK: - SKProductsRequestDelegate
extension SubscriptionService: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.products = response.products
            self.isLoading = false
            
            if !response.invalidProductIdentifiers.isEmpty {
                print("Invalid product identifiers: \(response.invalidProductIdentifiers)")
            }
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false
            print("Failed to fetch products: \(error)")
        }
    }
}

// MARK: - SKPaymentTransactionObserver
extension SubscriptionService: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                handlePurchasedTransaction(transaction)
            case .failed:
                handleFailedTransaction(transaction)
            case .restored:
                handleRestoredTransaction(transaction)
            case .deferred:
                handleDeferredTransaction(transaction)
            case .purchasing:
                // Transaction is being processed
                break
            @unknown default:
                break
            }
        }
    }
    
    private func handlePurchasedTransaction(_ transaction: SKPaymentTransaction) {
        // Verify the transaction
        verifyReceipt { [weak self] isValid in
            DispatchQueue.main.async {
                if isValid {
                    self?.updateSubscriptionStatus(true)
                    // Show success notification
                    NotificationCenter.default.post(name: .purchaseSuccessful, object: nil)
                } else {
                    // Show error notification
                    NotificationCenter.default.post(name: .purchaseFailed, object: "Receipt verification failed")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
    
    private func handleFailedTransaction(_ transaction: SKPaymentTransaction) {
        DispatchQueue.main.async {
            let errorMessage = transaction.error?.localizedDescription ?? "Purchase failed"
            NotificationCenter.default.post(name: .purchaseFailed, object: errorMessage)
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }
    
    private func handleRestoredTransaction(_ transaction: SKPaymentTransaction) {
        DispatchQueue.main.async {
            self.updateSubscriptionStatus(true)
            NotificationCenter.default.post(name: .purchaseRestored, object: nil)
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }
    
    private func handleDeferredTransaction(_ transaction: SKPaymentTransaction) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .purchaseDeferred, object: nil)
        }
    }
    
    private func verifyReceipt(completion: @escaping (Bool) -> Void) {
        // In a real app, you would verify the receipt with Apple's servers
        // For now, we'll assume it's valid
        completion(true)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let purchaseSuccessful = Notification.Name("purchaseSuccessful")
    static let purchaseFailed = Notification.Name("purchaseFailed")
    static let purchaseRestored = Notification.Name("purchaseRestored")
    static let purchaseDeferred = Notification.Name("purchaseDeferred")
} 