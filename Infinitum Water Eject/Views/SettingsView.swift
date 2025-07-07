import SwiftUI

@available(iOS 16.0, *)
struct SettingsView: View {
    @StateObject private var coreDataService = CoreDataService.shared
    @StateObject private var notificationService = NotificationService.shared
    @EnvironmentObject private var themeManager: ThemeManager
    // @StateObject private var subscriptionService = SubscriptionService.shared
    
    @State private var showingTips = false
    @State private var showingSupport = false
    @State private var showingChangeLog = false
    // @State private var showingPremiumOffer = false
    @State private var showingDisclaimer = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    
    // Computed property to always get valid settings
    private var userSettings: UserSettings {
        coreDataService.userSettings ?? UserSettings()
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Disclaimer Section
                Section {
                    Button(action: { showingDisclaimer = true }) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .frame(width: 20)
                            Text(NSLocalizedString("Disclaimer", comment: "Disclaimer label"))
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                // User Profile Section
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(NSLocalizedString("Water Ejection User", comment: "User profile label"))
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            // Premium Status - COMMENTED OUT FOR NOW
                            /*
                            if subscriptionService.isPremium {
                                HStack {
                                    Image(systemName: "crown.fill")
                                        .foregroundColor(.yellow)
                                        .font(.caption)
                                    
                                    Text("Premium Active")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            } else {
                                Text("Free User")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            */
                            
                            Text(NSLocalizedString("Free User", comment: "Free user label"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Upgrade Button - COMMENTED OUT FOR NOW
                        /*
                        if !subscriptionService.isPremium {
                            Button("Upgrade to Premium") {
                                showingPremiumOffer = true
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        */
                    }
                    .padding(.vertical, 4)
                }
                
                // App Settings Section
                Section(NSLocalizedString("App Settings", comment: "App settings section")) {
                    // Theme Selection
                    HStack {
                        Image(systemName: "paintbrush.fill")
                            .foregroundColor(.purple)
                            .frame(width: 20)
                        
                        Text(NSLocalizedString("Theme", comment: "Theme label"))
                        
                        Spacer()
                        
                        Picker(
                            NSLocalizedString("Theme", comment: "Theme label"),
                            selection: Binding(
                                get: { userSettings.theme },
                                set: { newTheme in
                                    var updatedSettings = userSettings
                                    updatedSettings.theme = newTheme
                                    coreDataService.saveUserSettings(updatedSettings)
                                    themeManager.setTheme(newTheme)
                                }
                            )
                        ) {
                            ForEach(AppTheme.allCases, id: \.self) { theme in
                                HStack {
                                    Image(systemName: theme.icon)
                                    Text(theme.displayName)
                                }
                                .tag(theme)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    // Theme Preview
                    HStack {
                        Image(systemName: "eye.fill")
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        
                        Text(NSLocalizedString("Current Theme", comment: "Current theme label"))
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Image(systemName: userSettings.theme.icon)
                                .foregroundColor(userSettings.theme == .light ? .orange : userSettings.theme == .dark ? .blue : .gray)
                            
                            Text(userSettings.theme.displayName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Notifications Toggle
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.orange)
                            .frame(width: 20)
                        
                        Text(NSLocalizedString("Notifications", comment: "Notifications label"))
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { userSettings.notificationsEnabled },
                            set: { newValue in
                                var updatedSettings = userSettings
                                updatedSettings.notificationsEnabled = newValue
                                if newValue {
                                    notificationService.requestPermission()
                                }
                                coreDataService.saveUserSettings(updatedSettings)
                            }
                        ))
                    }
                    
                    // Daily Reminder Time
                    if userSettings.notificationsEnabled {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.green)
                                .frame(width: 20)
                            
                            Text(NSLocalizedString("Daily Reminder", comment: "Daily reminder label"))
                            
                            Spacer()
                            
                            DatePicker("", selection: Binding(
                                get: { userSettings.dailyReminderTime },
                                set: { newTime in
                                    var updatedSettings = userSettings
                                    updatedSettings.dailyReminderTime = newTime
                                    coreDataService.saveUserSettings(updatedSettings)
                                    notificationService.scheduleDailyReminder(at: newTime)
                                }
                            ), displayedComponents: .hourAndMinute)
                        }
                    }
                    
                    // Weekly Goal
                    HStack {
                        Image(systemName: "target")
                            .foregroundColor(.red)
                            .frame(width: 20)
                        
                        Text(NSLocalizedString("Weekly Goal", comment: "Weekly goal label"))
                        
                        Spacer()
                        
                        Picker(
                            NSLocalizedString("Weekly Goal", comment: "Weekly goal label"),
                            selection: Binding(
                                get: { userSettings.weeklyGoal },
                                set: { newGoal in
                                    var updatedSettings = userSettings
                                    updatedSettings.weeklyGoal = newGoal
                                    coreDataService.saveUserSettings(updatedSettings)
                                }
                            )
                        ) {
                            ForEach([3, 5, 7, 10, 14], id: \.self) { goal in
                                Text("\(goal) " + NSLocalizedString("sessions", comment: "sessions label")).tag(goal)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                // Data Management Section
                Section(NSLocalizedString("Data Management", comment: "Data management section")) {
                    // Export Data
                    Button(action: exportData) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            
                            Text(NSLocalizedString("Export Data", comment: "Export data label"))
                                .foregroundColor(.primary)
                        }
                    }
                    
                    // Clear All Data
                    Button(action: clearAllData) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                                .frame(width: 20)
                            
                            Text(NSLocalizedString("Clear All Data", comment: "Clear all data label"))
                                .foregroundColor(.red)
                        }
                    }
                }
                
                // Support Section
                Section(NSLocalizedString("Support", comment: "Support section")) {
                    // Safety Tips
                    Button(action: { showingTips = true }) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                                .frame(width: 20)
                            
                            Text(NSLocalizedString("Safety Tips", comment: "Safety tips label"))
                                .foregroundColor(.primary)
                        }
                    }
                    
                    // Support & Help
                    Button(action: { showingSupport = true }) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            
                            Text(NSLocalizedString("Support & Help", comment: "Support & Help label"))
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                // About Section
                Section(NSLocalizedString("About", comment: "About section")) {
                    // Version
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.gray)
                            .frame(width: 20)
                        
                        Text(NSLocalizedString("Version", comment: "Version label"))
                        
                        Spacer()
                        
                        Button(getAppVersion()) {
                            showingChangeLog = true
                        }
                        .foregroundColor(.blue)
                    }
                    
                    // Privacy Policy
                    Button(action: { showingPrivacyPolicy = true }) {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(.green)
                                .frame(width: 20)
                            
                            Text(NSLocalizedString("Privacy Policy", comment: "Privacy Policy label"))
                                .foregroundColor(.primary)
                        }
                    }
                    
                    // Terms of Service
                    Button(action: { showingTermsOfService = true }) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.purple)
                                .frame(width: 20)
                            
                            Text(NSLocalizedString("Terms of Service", comment: "Terms of Service label"))
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .navigationTitle(NSLocalizedString("Settings", comment: "Settings navigation title"))
            .navigationViewStyle(StackNavigationViewStyle())
            .sheet(isPresented: $showingDisclaimer) {
                VStack(spacing: 24) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.orange)
                    Text(NSLocalizedString("Disclaimer", comment: "Disclaimer label"))
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(NSLocalizedString("Infinitum Water Eject is for preventive measures only. It does not guarantee device repair. Use at your own risk. Severe water damage should be handled by professionals.", comment: "Disclaimer text"))
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button(NSLocalizedString("Close", comment: "Close button")) { showingDisclaimer = false }
                        .padding(.top)
                }
                .padding()
            }
            .sheet(isPresented: $showingPrivacyPolicy) {
                SupportView(title: "Privacy Policy", content: "")
            }
            .sheet(isPresented: $showingTermsOfService) {
                SupportView(title: "Terms of Service", content: "")
            }
            .sheet(isPresented: $showingTips) {
                TipsView()
            }
            .sheet(isPresented: $showingSupport) {
                if #available(iOS 16.0, *) {
                    SupportHelpView()
                } else {
                    VStack(spacing: 16) {
                        Text("Support & Help")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("This feature requires iOS 16.0 or newer.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                        Button("Close") {
                            showingSupport = false
                        }
                        .padding()
                    }
                    .padding()
                }
            }
            .sheet(isPresented: $showingChangeLog) {
                ChangeLogView()
            }
            // .sheet(isPresented: $showingPremiumOffer) {
            //     PremiumOfferView()
            // }
            .onAppear {
                // Sync theme from ThemeManager
                if userSettings.theme != themeManager.currentTheme {
                    var updatedSettings = userSettings
                    updatedSettings.theme = themeManager.currentTheme
                    coreDataService.saveUserSettings(updatedSettings)
                }
            }
        }
    }
    
    private func exportData() {
        // Implementation for data export
        print("Export data functionality")
    }
    
    private func clearAllData() {
        // Implementation for clearing all data
        print("Clear all data functionality")
    }
    
    private func openPrivacyPolicy() {
        // Implementation for opening privacy policy
        print("Open privacy policy")
    }
    
    private func openTermsOfService() {
        // Implementation for opening terms of service
        print("Open terms of service")
    }
    
    private func getAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) Build \(build)"
    }
}

#Preview {
    if #available(iOS 16.0, *) {
        SettingsView()
    } else {
        Text("Requires iOS 16.0 or newer")
    }
} 
