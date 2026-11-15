import AppIntents
import SwiftUI

@available(iOS 16.0, *)
@MainActor
final class AppNavigation: ObservableObject {
    static let shared = AppNavigation()
    @Published var selectedTab = 0
    private var pendingAction: String?
    func route(_ action: String) {
        guard ["start", "stop", "tools", "eject", "history"].contains(action) else { return }
        pendingAction = action
        consumePendingAction()
    }
    func consumePendingAction(whenActive: Bool? = nil) {
        guard whenActive ?? (UIApplication.shared.applicationState == .active), let action = pendingAction else { return }
        pendingAction = nil
        switch action {
        case "start":
            selectedTab = 0
            guard !AdMobService.shared.isPresenting, AdMobService.presenter?.presentedViewController == nil else { return }
            WaterEjectionService.shared.startEjection(device: UIDevice.current.userInterfaceIdiom == .pad ? .ipad : .iphone,
                intensity: .low, useSavedSettings: false)
        case "stop": WaterEjectionService.shared.stopEjection()
        case "tools": selectedTab = 1
        case "history": selectedTab = 2
        default: selectedTab = 0
        }
    }
    func handle(_ url: URL) {
        guard url.scheme?.lowercased() == "infinitumwatereject", let action = url.host?.lowercased(),
              url.user == nil, url.password == nil else { return }
        GrowthMetrics.shared.record("deep_link_\(action)")
        route(action)
    }
}

@available(iOS 16.0, *)
struct StartWaterEjectionIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Water Ejection"
    static var description = IntentDescription("Open the app and play a 30-second tone through this device’s speaker.")
    static var openAppWhenRun = true
    @MainActor func perform() async throws -> some IntentResult {
        AppNavigation.shared.route("start")
        return .result()
    }
}
@available(iOS 16.0, *)
struct StopWaterEjectionIntent: AppIntent {
    static var title: LocalizedStringResource = "Stop Audio"
    static var openAppWhenRun = true
    @MainActor func perform() async throws -> some IntentResult {
        AppNavigation.shared.route("stop")
        return .result()
    }
}
@available(iOS 16.0, *)
struct OpenSpeakerToolsIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Speaker Tools"
    static var openAppWhenRun = true
    @MainActor func perform() async throws -> some IntentResult {
        AppNavigation.shared.route("tools")
        return .result()
    }
}
@available(iOS 16.0, *)
struct WaterEjectShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: StartWaterEjectionIntent(), phrases: ["Start water ejection with \(.applicationName)", "Eject water with \(.applicationName)"], shortTitle: "Start Water Ejection", systemImageName: "drop.fill")
        AppShortcut(intent: StopWaterEjectionIntent(), phrases: ["Stop audio in \(.applicationName)"], shortTitle: "Stop Audio", systemImageName: "stop.fill")
        AppShortcut(intent: OpenSpeakerToolsIntent(), phrases: ["Open speaker tools in \(.applicationName)"], shortTitle: "Speaker Tools", systemImageName: "waveform")
    }
}
