import SwiftUI

struct SettingsView: View {
    @ObservedObject private var audio = WaterEjectionService.shared
    @ObservedObject private var data = CoreDataService.shared
    @ObservedObject private var ads = AdMobService.shared
    @ObservedObject private var purchases = SubscriptionService.shared
    @ObservedObject private var appearance = ThemeManager.shared
    @EnvironmentObject private var themeService: ThemeService
    @Environment(\.openURL) private var openURL
    @State private var showPremium = false
    @State private var showThemes = false
    @State private var confirmDelete = false
    @State private var updatingReminders = false
    @State private var message: String?
    @State private var customReminders: [Date] = []
    private var settings: UserSettings { data.userSettings ?? UserSettings() }
    private var version: String {
        "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.3") (\(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"))"
    }
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button { showPremium = true } label: {
                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(purchases.isPremium ? "Premium is active" : "Lifetime Premium").font(.headline)
                                Text(purchases.isPremium ? "Manage or restore your purchase" : "Remove ads and save custom speaker presets")
                                    .font(.subheadline).foregroundStyle(.secondary)
                            }.padding(.vertical, 4)
                        } icon: { Image(systemName: "crown.fill").foregroundStyle(.orange) }
                    }.buttonStyle(.plain)
                }
                Section("Appearance") {
                    Picker(selection: Binding(get: { appearance.currentTheme }, set: { appearance.setTheme($0) })) {
                        ForEach(AppTheme.allCases, id: \.self) { Text($0 == .auto ? "System" : $0.displayName).tag($0) }
                    } label: { Label("Appearance", systemImage: "circle.lefthalf.filled") }
                    Button { showThemes = true } label: {
                        HStack { Label("Seasonal theme", systemImage: "paintpalette"); Spacer(); Text(themeService.currentTheme.name).foregroundStyle(.secondary) }
                    }.buttonStyle(.plain)
                }
                Section {
                    Toggle("Optional reminders", isOn: Binding(get: { settings.notificationsEnabled }, set: changeReminders))
                    if settings.notificationsEnabled {
                        DatePicker("Daily time", selection: Binding(get: { settings.dailyReminderTime }, set: { time in
                            var updated = settings; updated.dailyReminderTime = time; data.saveUserSettings(updated); reschedule()
                        }), displayedComponents: .hourAndMinute)
                        ForEach(customReminders.indices, id: \.self) { index in
                            HStack {
                                DatePicker("Additional time", selection: Binding(
                                    get: { customReminders.indices.contains(index) ? customReminders[index] : settings.dailyReminderTime },
                                    set: { time in
                                        guard customReminders.indices.contains(index) else { return }
                                        customReminders[index] = time; saveCustomReminders(); reschedule()
                                    }), displayedComponents: .hourAndMinute)
                                Spacer()
                                Button(role: .destructive) {
                                    guard customReminders.indices.contains(index) else { return }
                                    customReminders.remove(at: index)
                                    saveCustomReminders(); reschedule()
                                } label: { Label("Remove reminder", systemImage: "minus.circle").labelStyle(.iconOnly) }
                            }
                        }
                        Button("Add another reminder") {
                            let next = Calendar.current.date(byAdding: .hour, value: customReminders.count + 1, to: settings.dailyReminderTime) ?? Date()
                            customReminders.append(next); saveCustomReminders(); reschedule()
                        }.disabled(customReminders.count >= 10)
                    }
                    if updatingReminders { ProgressView("Updating reminders…") }
                    Button("Open iOS notification settings") { openURL(URL(string: UIApplication.openSettingsURLString)!) }
                } header: { Text("Reminders") } footer: {
                    Text("Only use tones when needed. Reminders are optional and do not indicate that a device needs cleaning.")
                }.disabled(updatingReminders)
                Section("Your data") {
                    ShareLink(item: SessionHistoryDocument(csv: SessionHistoryExport.csv(data.getWaterEjectionSessions())), preview: SharePreview("Water Eject session history")) {
                        Label("Share session history", systemImage: "square.and.arrow.up")
                    }
                    NavigationLink { GrowthDiagnosticsView() } label: { Label("Local diagnostics", systemImage: "stethoscope") }
                    Button(role: .destructive) { confirmDelete = true } label: { Label("Delete session history", systemImage: "trash") }
                        .disabled(audio.isPlaying || data.getWaterEjectionSessions().isEmpty)
                }
                Section("Help & privacy") {
                    NavigationLink { TipsView(isPresentedAsSheet: false) } label: { Label("Safety tips", systemImage: "lightbulb") }
                    NavigationLink { SupportHelpView() } label: { Label("Help & contact", systemImage: "questionmark.circle") }
                    if ads.privacyOptionsRequired { Button("Advertising privacy choices") { ads.showPrivacyOptions() } }
                    NavigationLink("Privacy policy") { SupportView(title: "Privacy Policy", content: "") }
                    NavigationLink("Terms of service") { SupportView(title: "Terms of Service", content: "") }
                }
                Section {
                    NavigationLink { ChangeLogView() } label: {
                        HStack { Label("What’s New", systemImage: "sparkles"); Spacer(); Text(version).font(.caption).foregroundStyle(.secondary) }
                    }
                    NavigationLink { AchievementsView() } label: { Label("Achievements", systemImage: "medal") }
                } header: { Text("About Water Eject") } footer: { Text("Audio plays through this device. A tone cannot diagnose damage or confirm dryness.") }
            }.navigationTitle("Settings")
                .sheet(isPresented: $showPremium) { PremiumOfferView() }
                .sheet(isPresented: $showThemes) { ThemeSettingsView(themeService: themeService) }
                .confirmationDialog("Delete all session history?", isPresented: $confirmDelete, titleVisibility: .visible) {
                    Button("Delete session history", role: .destructive) {
                        do { try data.deleteSessionHistory() } catch { message = error.localizedDescription }
                    }
                } message: { Text("This removes the session history on this device. Your purchase, presets and appearance preferences are kept. This cannot be undone.") }
                .alert("Settings", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) {
                    Button("OK") { message = nil }
                } message: { Text(message ?? "") }
                .task {
                    customReminders = Array(Set((UserDefaults.standard.array(forKey: "customReminderTimes") as? [Date]) ?? [])).sorted()
                    if settings.notificationsEnabled, !(await NotificationService.shared.isAuthorized()) {
                        var updated = settings; updated.notificationsEnabled = false; data.saveUserSettings(updated)
                        NotificationService.shared.cancelAllNotifications()
                    }
                }
        }
    }
    private func saveCustomReminders() { UserDefaults.standard.set(customReminders, forKey: "customReminderTimes") }
    private func changeReminders(_ enabled: Bool) {
        guard !updatingReminders else { return }
        if !enabled {
            NotificationService.shared.cancelAllNotifications()
            var updated = settings; updated.notificationsEnabled = false; data.saveUserSettings(updated)
            return
        }
        updatingReminders = true
        Task { @MainActor in
            defer { updatingReminders = false }
            do {
                guard try await NotificationService.shared.requestPermission() else { throw NotificationService.ReminderError.permissionDenied }
                try await NotificationService.shared.replaceReminders(daily: settings.dailyReminderTime, custom: customReminders)
                var updated = settings; updated.notificationsEnabled = true; data.saveUserSettings(updated)
            } catch { message = error.localizedDescription }
        }
    }
    private func reschedule() {
        updatingReminders = true
        Task { @MainActor in
            defer { updatingReminders = false }
            do { try await NotificationService.shared.replaceReminders(daily: settings.dailyReminderTime, custom: customReminders) }
            catch {
                var updated = settings; updated.notificationsEnabled = false; data.saveUserSettings(updated)
                message = error.localizedDescription
            }
        }
    }
}
