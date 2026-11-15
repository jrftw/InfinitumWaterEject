import XCTest
import StoreKit
import StoreKitTest
@testable import Infinitum_Water_Eject

@MainActor
final class PurchaseRegressionTests: XCTestCase {
    func testLifetimeEntitlementAndRefund() async throws {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "WaterEject", withExtension: "storekit"))
        let session = try SKTestSession(contentsOf: url)
        session.disableDialogs = true
        session.clearTransactions()
        defer { session.clearTransactions() }
        let service = SubscriptionService.shared
        await service.refreshEntitlements()
        XCTAssertFalse(service.isPremium, "A cached or debug flag must never grant premium")
        let transaction = try await session.buyProduct(identifier: SubscriptionService.lifetimeID)
        for _ in 0..<20 {
            await service.refreshEntitlements()
            if service.isPremium { break }
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        XCTAssertTrue(service.isPremium)
        XCTAssertTrue(service.entitlementChecked)
        XCTAssertEqual(AdMobService.shared.getBannerAdUnitId(), "", "Verified premium must disable ad requests")
        try session.refundTransaction(identifier: UInt(transaction.id))
        for _ in 0..<20 {
            await service.refreshEntitlements()
            if !service.isPremium { break }
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        XCTAssertFalse(service.isPremium, "Refunded purchases must not retain premium access")
    }
    func testExpiredLegacySubscriptionDoesNotGrantPremium() async throws {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "WaterEject", withExtension: "storekit"))
        let session = try SKTestSession(contentsOf: url)
        session.disableDialogs = true
        session.clearTransactions()
        session.timeRate = .oneRenewalEveryTenSeconds
        defer { session.clearTransactions() }
        let subscription = try await session.buyProduct(identifier: "com.infinitumimagery.watereject.premium.monthly")
        try session.disableAutoRenewForTransaction(identifier: UInt(subscription.id))
        await subscription.finish()
        let service = SubscriptionService.shared
        for _ in 0..<20 {
            await service.refreshEntitlements()
            if service.isPremium { break }
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        XCTAssertTrue(service.isPremium)
        try await Task.sleep(nanoseconds: 11_000_000_000)
        await service.refreshEntitlements()
        XCTAssertFalse(service.isPremium, "Expired legacy subscriptions cannot permanently unlock paid access")
    }
}
