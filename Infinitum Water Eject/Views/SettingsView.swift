import SwiftUI

struct SettingsView: View {
    @StateObject private var coreDataService = CoreDataService.shared
    @StateObject private var notificationService = NotificationService.shared
    @EnvironmentObject private var themeManager: ThemeManager
    // @StateObject private var subscriptionService = SubscriptionService.shared
    
    @State private var showingTips = false
    @State private var showingSupport = false
    @State private var showingChangeLog = false
    // @State private var showingPremiumOffer = false
    
    // Computed property to always get valid settings
    private var userSettings: UserSettings {
        coreDataService.userSettings ?? UserSettings()
    }
    
    var body: some View {
        NavigationView {
            List {
                // User Profile Section
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Water Ejection User")
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
                            
                            Text("Free User")
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
                Section("App Settings") {
                    // Theme Selection
                    HStack {
                        Image(systemName: "paintbrush.fill")
                            .foregroundColor(.purple)
                            .frame(width: 20)
                        
                        Text("Theme")
                        
                        Spacer()
                        
                        Picker("Theme", selection: Binding(
                            get: { userSettings.theme },
                            set: { newTheme in
                                var updatedSettings = userSettings
                                updatedSettings.theme = newTheme
                                coreDataService.saveUserSettings(updatedSettings)
                                themeManager.setTheme(newTheme)
                            }
                        )) {
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
                        
                        Text("Current Theme")
                        
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
                        
                        Text("Notifications")
                        
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
                            
                            Text("Daily Reminder")
                            
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
                        
                        Text("Weekly Goal")
                        
                        Spacer()
                        
                        Picker("Weekly Goal", selection: Binding(
                            get: { userSettings.weeklyGoal },
                            set: { newGoal in
                                var updatedSettings = userSettings
                                updatedSettings.weeklyGoal = newGoal
                                coreDataService.saveUserSettings(updatedSettings)
                            }
                        )) {
                            ForEach([3, 5, 7, 10, 14], id: \.self) { goal in
                                Text("\(goal) sessions").tag(goal)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                // Data Management Section
                Section("Data Management") {
                    // Export Data
                    Button(action: exportData) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            
                            Text("Export Data")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    // Clear All Data
                    Button(action: clearAllData) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                                .frame(width: 20)
                            
                            Text("Clear All Data")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                // Support Section
                Section("Support") {
                    // Safety Tips
                    Button(action: { showingTips = true }) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                                .frame(width: 20)
                            
                            Text("Safety Tips")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    // Support & Help
                    Button(action: { showingSupport = true }) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            
                            Text("Support & Help")
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                // About Section
                Section("About") {
                    // Version
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.gray)
                            .frame(width: 20)
                        
                        Text("Version")
                        
                        Spacer()
                        
                        Button("1.0.0") {
                            showingChangeLog = true
                        }
                        .foregroundColor(.blue)
                    }
                    
                    // Privacy Policy
                    Button(action: openPrivacyPolicy) {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(.green)
                                .frame(width: 20)
                            
                            Text("Privacy Policy")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    // Terms of Service
                    Button(action: openTermsOfService) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.purple)
                                .frame(width: 20)
                            
                            Text("Terms of Service")
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingTips) {
                TipsView()
            }
            .sheet(isPresented: $showingSupport) {
                SupportView(title: "Support & Help", content: "Get help and support for Infinitum Water Eject")
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
}

#Preview {
    SettingsView()
} 
