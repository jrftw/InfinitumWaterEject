import Foundation
import StoreKit
import WidgetKit

/// StoreKit is the source of truth. A cached boolean never grants paid access.
@MainActor
final class SubscriptionService: ObservableObject {
    static let shared = SubscriptionService()
    static let lifetimeID = "com.infinitumimagery.watereject.premium.lifetime"
    static let productIDs: Set<String> = [lifetimeID,
        "com.infinitumimagery.watereject.premium.weekly",
        "com.infinitumimagery.watereject.premium.monthly",
        "com.infinitumimagery.watereject.premium.yearly"]
    @Published private(set) var isPremium = false
    @Published private(set) var entitlementChecked = false
    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoading = false
    @Published private(set) var purchaseInProgress = false
    @Published var statusMessage: String?
    private var entitlementGeneration = 0
    private var updates: Task<Void, Never>?

    private init() {
        updates = Task { [weak self] in
            for await result in Transaction.updates {
                guard let self, case .verified(let transaction) = result,
                      Self.productIDs.contains(transaction.productID) else { continue }
                await self.refreshEntitlements()
                await transaction.finish()
            }
        }
        Task { await refreshEntitlements(); await loadProducts() }
    }

    func refreshEntitlements() async {
        entitlementGeneration += 1
        let generation = entitlementGeneration
        var entitled = false
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result,
                  Self.productIDs.contains(transaction.productID),
                  transaction.revocationDate == nil,
                  !transaction.isUpgraded,
                  transaction.expirationDate.map({ $0 > Date() }) ?? true else { continue }
            entitled = true
        }
        guard generation == entitlementGeneration else { return }
        isPremium = entitled
        entitlementChecked = true
        UserDefaults.standard.set(entitled, forKey: "isPremium")
        UserDefaults(suiteName: "group.com.infinitumimagery.watereject")?.set(entitled, forKey: "isPremium")
        WidgetCenter.shared.reloadAllTimelines()
    }

    func fetchProducts() { Task { await loadProducts() } }
    func loadProducts() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let available = try await Product.products(for: Self.productIDs)
            // Offer lifetime first; keep legacy subscriptions available only for entitlement recognition.
            products = available.filter { $0.id == Self.lifetimeID && $0.type == .nonConsumable }
            statusMessage = products.isEmpty ? "The lifetime upgrade is not available yet. Please try again later." : nil
        } catch { statusMessage = error.localizedDescription }
    }

    func purchasePremium(productId: String, completion: @escaping (Bool, String?) -> Void) {
        guard !purchaseInProgress, let product = products.first(where: { $0.id == productId }) else {
            completion(false, "This purchase is currently unavailable."); return
        }
        purchaseInProgress = true
        GrowthMetrics.shared.record("purchase_started")
        Task {
            defer { purchaseInProgress = false }
            do {
                switch try await product.purchase() {
                case .success(let result):
                    guard case .verified(let transaction) = result else {
                        completion(false, "Apple could not verify this purchase."); return
                    }
                    await refreshEntitlements()
                    await transaction.finish()
                    GrowthMetrics.shared.record("purchase_verified")
                    completion(isPremium, isPremium ? nil : "The purchase does not currently grant access.")
                case .pending:
                    statusMessage = "Purchase pending approval. Access updates automatically after approval."
                    completion(false, statusMessage)
                case .userCancelled: completion(false, nil)
                @unknown default: completion(false, "Please try again.")
                }
            } catch { completion(false, error.localizedDescription) }
        }
    }

    func restorePurchases() {
        guard !isLoading, !purchaseInProgress else { return }
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                try await AppStore.sync()
                await refreshEntitlements()
                statusMessage = isPremium ? "Your purchases have been restored." : "No active purchases were found for this Apple Account."
            } catch { statusMessage = error.localizedDescription }
        }
    }

    func getPremiumFeatures() -> [String] {
        ["Ad-free experience", "Save custom speaker test presets", "All existing premium screens"]
    }
}
