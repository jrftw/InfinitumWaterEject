import SwiftUI
import AppIntents

@main
@available(iOS 16.0, *)
struct Infinitum_Water_EjectApp: App {
    @StateObject private var appearance = ThemeManager.shared
    @StateObject private var themeService = ThemeService()
    init() { WaterEjectShortcuts.updateAppShortcutParameters() }
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(themeService)
                .environment(\.appTheme, themeService.currentTheme)
                .preferredColorScheme(appearance.currentTheme.colorScheme)
        }
    }
}
