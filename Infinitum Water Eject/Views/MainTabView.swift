import SwiftUI

@available(iOS 16.0, *)
struct MainTabView: View {
    @StateObject private var subscriptionService = SubscriptionService.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MainEjectionView()
                .tabItem {
                    Image(systemName: "drop.fill")
                    Text("Eject")
                }
                .tag(0)
            
            HistoryView()
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("History")
                }
                .tag(1)
            
            AchievementsView()
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("Achievements")
                }
                .tag(2)
            
            AnalyticsDashboardView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Analytics")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(4)
        }
        .accentColor(.blue)
        .onAppear {
            // Request notification permissions on first launch
            NotificationService.shared.requestPermission()
        }
    }
}

#Preview {
    if #available(iOS 16.0, *) {
        MainTabView()
    } else {
        Text("Requires iOS 16.0 or newer")
    }
} 