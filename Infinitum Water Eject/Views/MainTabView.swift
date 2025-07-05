import SwiftUI

struct MainTabView: View {
    // @StateObject private var subscriptionService = SubscriptionService.shared
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
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(2)
        }
        .accentColor(.blue)
        .onAppear {
            // Request notification permissions on first launch
            NotificationService.shared.requestPermission()
        }
    }
}

#Preview {
    MainTabView()
} 