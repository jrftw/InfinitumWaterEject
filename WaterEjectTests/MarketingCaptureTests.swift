import XCTest
import SwiftUI
import StoreKitTest
@testable import Infinitum_Water_Eject

@MainActor
final class MarketingCaptureTests: XCTestCase {
    func testCaptureActualPremiumScreen() async throws {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "WaterEject", withExtension: "storekit"))
        let session = try SKTestSession(contentsOf: url)
        session.disableDialogs = true
        session.clearTransactions()
        defer { session.clearTransactions() }
        await SubscriptionService.shared.refreshEntitlements()
        while SubscriptionService.shared.isLoading { try await Task.sleep(nanoseconds: 100_000_000) }
        await SubscriptionService.shared.loadProducts()
        XCTAssertEqual(SubscriptionService.shared.products.first?.id, SubscriptionService.lifetimeID)
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let window = UIWindow(windowScene: scene)
        window.rootViewController = UIHostingController(rootView: PremiumOfferView())
        window.overrideUserInterfaceStyle = .light
        window.makeKeyAndVisible()
        defer { window.isHidden = true }
        try await Task.sleep(nanoseconds: 1_000_000_000)
        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        let image = renderer.image { _ in window.drawHierarchy(in: window.bounds, afterScreenUpdates: true) }
        let output = FileManager.default.temporaryDirectory.appendingPathComponent("premium-review.png")
        try XCTUnwrap(image.pngData()).write(to: output)
        print("PREMIUM_CAPTURE", output.path)
        let attachment = XCTAttachment(image: image)
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    func testCapturePolishedNavigationAndAccessibility() async throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let theme = ThemeService()
        let screens: [(String, AnyView)] = [
            ("home-light", AnyView(MainTabView().environmentObject(theme))),
            ("history-light", AnyView(MainTabView().environmentObject(theme))),
            ("home-accessibility", AnyView(MainTabView().environmentObject(theme).dynamicTypeSize(.accessibility3))),
            ("cycle-settings", AnyView(IntensityPickerView(selectedIntensity: .constant(.medium)))),
            ("help-light", AnyView(NavigationStack { SupportHelpView() })),
            ("tools-light", AnyView(MainTabView().environmentObject(theme))),
            ("settings-light", AnyView(MainTabView().environmentObject(theme))),
            ("changelog-dark", AnyView(NavigationStack { ChangeLogView() }.preferredColorScheme(.dark))),
            ("settings-accessibility", AnyView(MainTabView().environmentObject(theme).dynamicTypeSize(.accessibility3))),
            ("tools-accessibility", AnyView(MainTabView().environmentObject(theme).dynamicTypeSize(.accessibility3)))
        ]
        for (name, screen) in screens {
            AppNavigation.shared.selectedTab = name.hasPrefix("tools") ? 1 : name.hasPrefix("settings") ? 4 : name.hasPrefix("history") ? 2 : 0
            let window = UIWindow(windowScene: scene)
            window.rootViewController = UIHostingController(rootView: screen)
            window.overrideUserInterfaceStyle = name.contains("dark") ? .dark : .light
            window.makeKeyAndVisible()
            try await Task.sleep(nanoseconds: 100_000_000)
            AppNavigation.shared.selectedTab = name.hasPrefix("tools") ? 1 : name.hasPrefix("settings") ? 4 : name.hasPrefix("history") ? 2 : 0
            try await Task.sleep(nanoseconds: 600_000_000)
            let image = UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
                window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
            }
            let output = FileManager.default.temporaryDirectory.appendingPathComponent("polish-" + name + ".png")
            try XCTUnwrap(image.pngData()).write(to: output)
            print("POLISH_CAPTURE", output.path)
            let attachment = XCTAttachment(image: image); attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
            window.isHidden = true
        }
    }

}
