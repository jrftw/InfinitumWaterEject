import SwiftUI
import UniformTypeIdentifiers

@available(iOS 16.0, *)
struct SettingsView: View {
    @StateObject private var coreDataService = CoreDataService.shared
    @StateObject private var notificationService = NotificationService.shared
    @StateObject private var subscriptionService = SubscriptionService.shared
    @EnvironmentObject private var themeService: ThemeService
    @Environment(\.appTheme) var theme: HolidayTheme
    
    @State private var showingTips = false
    @State private var showingSupport = false
    @State private var showingChangeLog = false
    @State private var showingPremiumOffer = false
    @State private var showingDisclaimer = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    @State private var customReminders: [Date] = []
    
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
                            Text(NSLocalizedString("Water & Dust Ejection User", comment: "User profile label"))
                                .font(.headline)
                                .fontWeight(.semibold)
                            
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
                        }
                        
                        Spacer()
                        
                        if !subscriptionService.isPremium {
                            Button("Upgrade to Premium") {
                                showingPremiumOffer = true
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // App Settings Section
                Section(NSLocalizedString("App Settings", comment: "App settings section")) {
                    // Holiday Theme Settings
                    Button(action: { themeService.toggleThemeSettings() }) {
                        HStack {
                            Image(systemName: "paintbrush.fill")
                                .foregroundColor(theme.primaryColor)
                                .frame(width: 20)
                            
                            Text(NSLocalizedString("Holiday Themes", comment: "Holiday themes label"))
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Image(systemName: theme.icon)
                                    .foregroundColor(theme.primaryColor)
                                
                                Text(theme.name)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Automatic Theme Toggle
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(theme.primaryColor)
                            .frame(width: 20)
                        
                        Text(NSLocalizedString("Automatic Holiday Themes", comment: "Automatic holiday themes label"))
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { themeService.isAutomaticThemeEnabled },
                            set: { isEnabled in
                                if isEnabled {
                                    themeService.enableAutomaticTheme()
                                }
                            }
                        ))
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
                        // Custom Notification Schedules
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Custom Reminders")
                                .font(.headline)
                            ForEach(customReminders.indices, id: \.self) { idx in
                                HStack {
                                    DatePicker("", selection: Binding(
                                        get: { customReminders[idx] },
                                        set: { newDate in
                                            customReminders[idx] = newDate
                                            scheduleCustomReminder(at: newDate)
                                        }
                                    ), displayedComponents: .hourAndMinute)
                                    Button(action: {
                                        removeCustomReminder(at: idx)
                                    }) {
                                        Image(systemName: "minus.circle.fill").foregroundColor(.red)
                                    }
                                }
                            }
                            Button(action: addCustomReminder) {
                                HStack {
                                    Image(systemName: "plus.circle.fill").foregroundColor(.green)
                                    Text("Add Reminder")
                                }
                            }
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
                
                // Banner Ad Section
                Section {
                    VStack(spacing: 0) {
                        ConditionalBannerAdView(adUnitId: AdMobService.shared.getBannerAdUnitId())
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
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
                    Text(NSLocalizedString("Infinitum Water Eject is for preventive measures only. It does not guarantee device repair. Use at your own risk. Severe water or dust damage should be handled by professionals.", comment: "Disclaimer text"))
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
        .sheet(isPresented: $showingPremiumOffer) {
            PremiumOfferView()
        }
        .sheet(isPresented: $themeService.isThemeSettingsVisible) {
            ThemeSettingsView(themeService: themeService)
        }
            // .sheet(isPresented: $showingPremiumOffer) {
            //     PremiumOfferView()
            // }
            .onAppear {
                // Theme is now managed by the new HolidayThemeManager
            }
        }
    }
    
    private func exportData() {
        let sessions = CoreDataService.shared.getWaterEjectionSessions()
        let csvString = generateCSV(from: sessions)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("WaterEjectionSessions.csv")
        do {
            try csvString.write(to: tempURL, atomically: true, encoding: .utf8)
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true, completion: nil)
            }
        } catch {
            print("Failed to export CSV: \(error)")
        }
    }

    private func generateCSV(from sessions: [WaterEjectionSession]) -> String {
        var csv = "Session ID,Device Type,Intensity,Duration (s),Start Time,End Time,Completed\n"
        let formatter = ISO8601DateFormatter()
        for session in sessions {
            let id = session.id.uuidString
            let device = session.deviceType.rawValue
            let intensity = session.intensityLevel.rawValue
            let duration = String(format: "%.1f", session.duration)
            let start = formatter.string(from: session.startTime)
            let end = session.endTime != nil ? formatter.string(from: session.endTime!) : ""
            let completed = session.isCompleted ? "Yes" : "No"
            csv += "\(id),\(device),\(intensity),\(duration),\(start),\(end),\(completed)\n"
        }
        return csv
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
    
    private func addCustomReminder() {
        let nextHour = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        customReminders.append(nextHour)
        scheduleCustomReminder(at: nextHour)
    }
    private func removeCustomReminder(at index: Int) {
        if customReminders.indices.contains(index) {
            let date = customReminders[index]
            customReminders.remove(at: index)
            notificationService.cancelCustomReminder(at: date)
        }
    }
    private func scheduleCustomReminder(at date: Date) {
        notificationService.scheduleCustomReminder(at: date)
    }
}

#Preview {
    if #available(iOS 16.0, *) {
        SettingsView()
    } else {
        Text("Requires iOS 16.0 or newer")
    }
} 
