import SwiftUI

@available(iOS 16.0, *)
struct MainTabView: View {
    @StateObject private var navigation = AppNavigation.shared
    @EnvironmentObject var themeService: ThemeService
    @Environment(\.appTheme) var theme: HolidayTheme
    @State private var appliedSnapshotRoute = false
    @Environment(\.scenePhase) private var phase
    var body: some View {
        TabView(selection: $navigation.selectedTab) {
            MainEjectionView().tabItem { Label("Eject", systemImage: "drop.fill") }.tag(0)
            SpeakerToolsView().tabItem { Label("Tools", systemImage: "waveform") }.tag(1)
            HistoryView().tabItem { Label("History", systemImage: "clock.arrow.circlepath") }.tag(2)
            AnalyticsDashboardView().tabItem { Label("Analytics", systemImage: "chart.bar.fill") }.tag(3)
            SettingsView().tabItem { Label("Settings", systemImage: "gear") }.tag(4)
        }
        .tint(theme.primaryColor).themedBackground(theme)
        .onOpenURL { navigation.handle($0) }
        .onAppear { activate() }
        .onChange(of: phase) { if $0 == .active { activate() } }
    }
    private func activate() {
        #if DEBUG
        if !appliedSnapshotRoute,
           let index = ProcessInfo.processInfo.arguments.firstIndex(of: "--snapshot-route"),
           ProcessInfo.processInfo.arguments.indices.contains(index + 1) {
            let route = ProcessInfo.processInfo.arguments[index + 1]
            if ["tools", "eject", "history"].contains(route) { navigation.route(route) }
            appliedSnapshotRoute = true
        }
        #endif
        navigation.consumePendingAction()
        GrowthMetrics.shared.recordVisit()
        Task { await SubscriptionService.shared.refreshEntitlements() }
        #if DEBUG
        if !ProcessInfo.processInfo.arguments.contains("--snapshot-route") { AdMobService.shared.prepare() }
        #else
        AdMobService.shared.prepare()
        #endif
    }
}
