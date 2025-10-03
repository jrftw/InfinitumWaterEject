import SwiftUI
import Foundation

class ThemeService: ObservableObject {
    @Published var themeManager: HolidayThemeManager
    @Published var isThemeSettingsVisible: Bool = false
    
    init() {
        self.themeManager = HolidayThemeManager()
        startThemeUpdateTimer()
    }
    
    // MARK: - Theme Update Timer
    private var themeUpdateTimer: Timer?
    
    private func startThemeUpdateTimer() {
        // Update theme every hour to check for date changes
        themeUpdateTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.themeManager.updateThemeIfAutomatic()
        }
    }
    
    deinit {
        themeUpdateTimer?.invalidate()
    }
    
    // MARK: - Theme Actions
    func setTheme(_ theme: HolidayTheme) {
        themeManager.setTheme(theme)
    }
    
    func enableAutomaticTheme() {
        themeManager.enableAutomaticTheme()
    }
    
    func toggleThemeSettings() {
        isThemeSettingsVisible.toggle()
    }
    
    // MARK: - Current Theme Properties
    var currentTheme: HolidayTheme {
        themeManager.currentTheme
    }
    
    var isAutomaticThemeEnabled: Bool {
        themeManager.isAutomaticThemeEnabled
    }
    
    var availableThemes: [HolidayTheme] {
        themeManager.availableThemes
    }
}

// MARK: - Theme View Modifiers
struct ThemedBackground: ViewModifier {
    let theme: HolidayTheme
    
    func body(content: Content) -> some View {
        content
            .background(theme.backgroundGradient)
    }
}

struct ThemedCard: ViewModifier {
    let theme: HolidayTheme
    
    func body(content: Content) -> some View {
        content
            .background(theme.surfaceColor)
            .cornerRadius(12)
            .shadow(color: theme.primaryColor.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct ThemedButton: ViewModifier {
    let theme: HolidayTheme
    let style: ButtonStyle
    
    enum ButtonStyle {
        case primary
        case secondary
        case accent
    }
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(buttonTextColor)
            .background(buttonBackground)
            .cornerRadius(8)
    }
    
    private var buttonTextColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return theme.primaryColor
        case .accent:
            return .white
        }
    }
    
    private var buttonBackground: some View {
        switch style {
        case .primary:
            return AnyView(theme.gradient)
        case .secondary:
            return AnyView(theme.surfaceColor)
        case .accent:
            return AnyView(theme.accentColor)
        }
    }
}

// MARK: - Theme Extensions
extension View {
    func themedBackground(_ theme: HolidayTheme) -> some View {
        self.modifier(ThemedBackground(theme: theme))
    }
    
    func themedCard(_ theme: HolidayTheme) -> some View {
        self.modifier(ThemedCard(theme: theme))
    }
    
    func themedButton(_ theme: HolidayTheme, style: ThemedButton.ButtonStyle = .primary) -> some View {
        self.modifier(ThemedButton(theme: theme, style: style))
    }
}

// MARK: - Theme Settings View
struct ThemeSettingsView: View {
    @ObservedObject var themeService: ThemeService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Automatic Themes") {
                    Toggle("Enable Automatic Holiday Themes", isOn: Binding(
                        get: { themeService.isAutomaticThemeEnabled },
                        set: { isEnabled in
                            if isEnabled {
                                themeService.enableAutomaticTheme()
                            }
                        }
                    ))
                    
                    if themeService.isAutomaticThemeEnabled {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(themeService.currentTheme.primaryColor)
                            VStack(alignment: .leading) {
                                Text("Current Theme")
                                    .font(.headline)
                                Text(themeService.currentTheme.name)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: themeService.currentTheme.icon)
                                .foregroundColor(themeService.currentTheme.primaryColor)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                if !themeService.isAutomaticThemeEnabled {
                    Section("Manual Theme Selection") {
                        ForEach(themeService.availableThemes, id: \.type) { theme in
                            ThemeRowView(
                                theme: theme,
                                isSelected: theme.type == themeService.currentTheme.type,
                                onTap: {
                                    themeService.setTheme(theme)
                                }
                            )
                        }
                    }
                }
                
                Section("Theme Information") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Holiday Themes")
                            .font(.headline)
                        
                        Text("The app automatically switches to holiday themes during special times:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HolidayInfoRow(holiday: "New Year", month: "January 1-7", theme: HolidayTheme.newYear)
                            HolidayInfoRow(holiday: "Valentine's Day", month: "February 10-16", theme: HolidayTheme.valentines)
                            HolidayInfoRow(holiday: "St. Patrick's Day", month: "March 15-21", theme: HolidayTheme.stPatricks)
                            HolidayInfoRow(holiday: "Easter", month: "April", theme: HolidayTheme.easter)
                            HolidayInfoRow(holiday: "Independence Day", month: "July 1-7", theme: HolidayTheme.independence)
                            HolidayInfoRow(holiday: "Halloween", month: "October 25-31", theme: HolidayTheme.halloween)
                            HolidayInfoRow(holiday: "Thanksgiving", month: "November 20-30", theme: HolidayTheme.thanksgiving)
                            HolidayInfoRow(holiday: "Christmas", month: "December 20-31", theme: HolidayTheme.christmas)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Themes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ThemeRowView: View {
    let theme: HolidayTheme
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: theme.icon)
                    .foregroundColor(theme.primaryColor)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(theme.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(theme.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(theme.primaryColor)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct HolidayInfoRow: View {
    let holiday: String
    let month: String
    let theme: HolidayTheme
    
    var body: some View {
        HStack {
            Image(systemName: theme.icon)
                .foregroundColor(theme.primaryColor)
                .frame(width: 16)
            
            Text(holiday)
                .font(.caption)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(month)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}
