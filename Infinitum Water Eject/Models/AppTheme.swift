import SwiftUI
import Foundation

// MARK: - Theme Types
enum AppThemeType: String, CaseIterable {
    case defaultTheme = "default"
    case halloween = "halloween"
    case christmas = "christmas"
    case valentines = "valentines"
    case stPatricks = "st_patricks"
    case easter = "easter"
    case independence = "independence"
    case thanksgiving = "thanksgiving"
    case newYear = "new_year"
    
    var displayName: String {
        switch self {
        case .defaultTheme: return "Default"
        case .halloween: return "Halloween"
        case .christmas: return "Christmas"
        case .valentines: return "Valentine's Day"
        case .stPatricks: return "St. Patrick's Day"
        case .easter: return "Easter"
        case .independence: return "Independence Day"
        case .thanksgiving: return "Thanksgiving"
        case .newYear: return "New Year"
        }
    }
    
    var icon: String {
        switch self {
        case .defaultTheme: return "drop.fill"
        case .halloween: return "moon.stars.fill"
        case .christmas: return "snowflake"
        case .valentines: return "heart.fill"
        case .stPatricks: return "leaf.fill"
        case .easter: return "sun.max.fill"
        case .independence: return "flag.fill"
        case .thanksgiving: return "leaf.arrow.circlepath"
        case .newYear: return "sparkles"
        }
    }
}

// MARK: - App Theme Model
struct HolidayTheme {
    let type: AppThemeType
    let name: String
    let primaryColor: Color
    let secondaryColor: Color
    let accentColor: Color
    let backgroundColor: Color
    let surfaceColor: Color
    let textColor: Color
    let secondaryTextColor: Color
    let successColor: Color
    let warningColor: Color
    let errorColor: Color
    let gradient: LinearGradient
    let backgroundGradient: LinearGradient
    let icon: String
    let description: String
    
    // MARK: - Default Theme
    static let defaultTheme = HolidayTheme(
        type: .defaultTheme,
        name: "Ocean Blue",
        primaryColor: Color.blue,
        secondaryColor: Color.cyan,
        accentColor: Color.blue.opacity(0.8),
        backgroundColor: Color(.systemBackground),
        surfaceColor: Color(.secondarySystemBackground),
        textColor: Color.primary,
        secondaryTextColor: Color.secondary,
        successColor: Color.green,
        warningColor: Color.orange,
        errorColor: Color.red,
        gradient: LinearGradient(
            colors: [Color.blue, Color.cyan],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        backgroundGradient: LinearGradient(
            colors: [Color(.systemBackground), Color(.systemBackground)],
            startPoint: .top,
            endPoint: .bottom
        ),
        icon: "drop.fill",
        description: "Clean and professional water-themed design"
    )
    
    // MARK: - Halloween Theme
    static let halloween = HolidayTheme(
        type: .halloween,
        name: "Spooky Night",
        primaryColor: Color.orange,
        secondaryColor: Color.purple,
        accentColor: Color.orange.opacity(0.8),
        backgroundColor: Color.black,
        surfaceColor: Color.gray.opacity(0.2),
        textColor: Color.orange,
        secondaryTextColor: Color.orange.opacity(0.7),
        successColor: Color.green,
        warningColor: Color.yellow,
        errorColor: Color.red,
        gradient: LinearGradient(
            colors: [Color.orange, Color.purple, Color.black],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        backgroundGradient: LinearGradient(
            colors: [Color.black, Color.purple.opacity(0.3)],
            startPoint: .top,
            endPoint: .bottom
        ),
        icon: "moon.stars.fill",
        description: "Spooky Halloween vibes with orange and purple"
    )
    
    // MARK: - Christmas Theme
    static let christmas = HolidayTheme(
        type: .christmas,
        name: "Winter Wonderland",
        primaryColor: Color.red,
        secondaryColor: Color.green,
        accentColor: Color.red.opacity(0.8),
        backgroundColor: Color.white,
        surfaceColor: Color.red.opacity(0.1),
        textColor: Color.red,
        secondaryTextColor: Color.green,
        successColor: Color.green,
        warningColor: Color.orange,
        errorColor: Color.red,
        gradient: LinearGradient(
            colors: [Color.red, Color.green, Color.white],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        backgroundGradient: LinearGradient(
            colors: [Color.white, Color.red.opacity(0.1)],
            startPoint: .top,
            endPoint: .bottom
        ),
        icon: "snowflake",
        description: "Festive Christmas colors with red and green"
    )
    
    // MARK: - Valentine's Day Theme
    static let valentines = HolidayTheme(
        type: .valentines,
        name: "Love & Hearts",
        primaryColor: Color.pink,
        secondaryColor: Color.red,
        accentColor: Color.pink.opacity(0.8),
        backgroundColor: Color.pink.opacity(0.05),
        surfaceColor: Color.pink.opacity(0.1),
        textColor: Color.pink,
        secondaryTextColor: Color.red,
        successColor: Color.green,
        warningColor: Color.orange,
        errorColor: Color.red,
        gradient: LinearGradient(
            colors: [Color.pink, Color.red, Color.pink.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        backgroundGradient: LinearGradient(
            colors: [Color.pink.opacity(0.1), Color.red.opacity(0.05)],
            startPoint: .top,
            endPoint: .bottom
        ),
        icon: "heart.fill",
        description: "Romantic pink and red Valentine's theme"
    )
    
    // MARK: - St. Patrick's Day Theme
    static let stPatricks = HolidayTheme(
        type: .stPatricks,
        name: "Lucky Green",
        primaryColor: Color.green,
        secondaryColor: Color.yellow,
        accentColor: Color.green.opacity(0.8),
        backgroundColor: Color.green.opacity(0.05),
        surfaceColor: Color.green.opacity(0.1),
        textColor: Color.green,
        secondaryTextColor: Color.yellow,
        successColor: Color.green,
        warningColor: Color.orange,
        errorColor: Color.red,
        gradient: LinearGradient(
            colors: [Color.green, Color.yellow, Color.green.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        backgroundGradient: LinearGradient(
            colors: [Color.green.opacity(0.1), Color.yellow.opacity(0.05)],
            startPoint: .top,
            endPoint: .bottom
        ),
        icon: "leaf.fill",
        description: "Lucky green for St. Patrick's Day"
    )
    
    // MARK: - Easter Theme
    static let easter = HolidayTheme(
        type: .easter,
        name: "Spring Pastels",
        primaryColor: Color.purple,
        secondaryColor: Color.pink,
        accentColor: Color.purple.opacity(0.8),
        backgroundColor: Color.purple.opacity(0.05),
        surfaceColor: Color.pink.opacity(0.1),
        textColor: Color.purple,
        secondaryTextColor: Color.pink,
        successColor: Color.green,
        warningColor: Color.orange,
        errorColor: Color.red,
        gradient: LinearGradient(
            colors: [Color.purple, Color.pink, Color.yellow.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        backgroundGradient: LinearGradient(
            colors: [Color.purple.opacity(0.1), Color.pink.opacity(0.05)],
            startPoint: .top,
            endPoint: .bottom
        ),
        icon: "sun.max.fill",
        description: "Bright spring colors for Easter"
    )
    
    // MARK: - Independence Day Theme
    static let independence = HolidayTheme(
        type: .independence,
        name: "Patriotic",
        primaryColor: Color.red,
        secondaryColor: Color.blue,
        accentColor: Color.red.opacity(0.8),
        backgroundColor: Color.blue.opacity(0.05),
        surfaceColor: Color.red.opacity(0.1),
        textColor: Color.red,
        secondaryTextColor: Color.blue,
        successColor: Color.green,
        warningColor: Color.orange,
        errorColor: Color.red,
        gradient: LinearGradient(
            colors: [Color.red, Color.white, Color.blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        backgroundGradient: LinearGradient(
            colors: [Color.red.opacity(0.1), Color.blue.opacity(0.05)],
            startPoint: .top,
            endPoint: .bottom
        ),
        icon: "flag.fill",
        description: "Patriotic red, white, and blue theme"
    )
    
    // MARK: - Thanksgiving Theme
    static let thanksgiving = HolidayTheme(
        type: .thanksgiving,
        name: "Autumn Harvest",
        primaryColor: Color.orange,
        secondaryColor: Color.brown,
        accentColor: Color.orange.opacity(0.8),
        backgroundColor: Color.orange.opacity(0.05),
        surfaceColor: Color.brown.opacity(0.1),
        textColor: Color.orange,
        secondaryTextColor: Color.brown,
        successColor: Color.green,
        warningColor: Color.orange,
        errorColor: Color.red,
        gradient: LinearGradient(
            colors: [Color.orange, Color.brown, Color.yellow.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        backgroundGradient: LinearGradient(
            colors: [Color.orange.opacity(0.1), Color.brown.opacity(0.05)],
            startPoint: .top,
            endPoint: .bottom
        ),
        icon: "leaf.arrow.circlepath",
        description: "Warm autumn colors for Thanksgiving"
    )
    
    // MARK: - New Year Theme
    static let newYear = HolidayTheme(
        type: .newYear,
        name: "Celebration",
        primaryColor: Color.purple,
        secondaryColor: Color.blue,
        accentColor: Color.purple.opacity(0.8),
        backgroundColor: Color.black,
        surfaceColor: Color.purple.opacity(0.2),
        textColor: Color.white,
        secondaryTextColor: Color.purple,
        successColor: Color.green,
        warningColor: Color.orange,
        errorColor: Color.red,
        gradient: LinearGradient(
            colors: [Color.purple, Color.blue, Color.pink],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        backgroundGradient: LinearGradient(
            colors: [Color.black, Color.purple.opacity(0.3)],
            startPoint: .top,
            endPoint: .bottom
        ),
        icon: "sparkles",
        description: "Sparkling celebration theme for New Year"
    )
}

// MARK: - Holiday Theme Manager
class HolidayThemeManager: ObservableObject {
    @Published var currentTheme: HolidayTheme
    @Published var isAutomaticThemeEnabled: Bool = true
    
    init() {
        self.currentTheme = Self.getAutomaticTheme()
    }
    
    // MARK: - Automatic Theme Detection
    static func getAutomaticTheme() -> HolidayTheme {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: Date())
        let day = calendar.component(.day, from: Date())
        
        switch month {
        case 1: // January
            if day <= 7 {
                return HolidayTheme.newYear
            }
            return HolidayTheme.defaultTheme
            
        case 2: // February
            if day >= 10 && day <= 16 {
                return HolidayTheme.valentines
            }
            return HolidayTheme.defaultTheme
            
        case 3: // March
            if day >= 15 && day <= 21 {
                return HolidayTheme.stPatricks
            }
            return HolidayTheme.defaultTheme
            
        case 4: // April
            // Easter calculation (simplified - first Sunday after first full moon after March 21)
            if day >= 1 && day <= 30 {
                return HolidayTheme.easter
            }
            return HolidayTheme.defaultTheme
            
        case 7: // July
            if day >= 1 && day <= 7 {
                return HolidayTheme.independence
            }
            return HolidayTheme.defaultTheme
            
        case 10: // October
            if day >= 25 && day <= 31 {
                return HolidayTheme.halloween
            }
            return HolidayTheme.defaultTheme
            
        case 11: // November
            if day >= 20 && day <= 30 {
                return HolidayTheme.thanksgiving
            }
            return HolidayTheme.defaultTheme
            
        case 12: // December
            if day >= 20 && day <= 31 {
                return HolidayTheme.christmas
            }
            return HolidayTheme.defaultTheme
            
        default:
            return HolidayTheme.defaultTheme
        }
    }
    
    // MARK: - Manual Theme Setting
    func setTheme(_ theme: HolidayTheme) {
        currentTheme = theme
        isAutomaticThemeEnabled = false
    }
    
    // MARK: - Enable Automatic Theme
    func enableAutomaticTheme() {
        isAutomaticThemeEnabled = true
        currentTheme = Self.getAutomaticTheme()
    }
    
    // MARK: - Update Theme Based on Date
    func updateThemeIfAutomatic() {
        if isAutomaticThemeEnabled {
            let newTheme = Self.getAutomaticTheme()
            if newTheme.type != currentTheme.type {
                currentTheme = newTheme
            }
        }
    }
    
    // MARK: - Available Themes
    var availableThemes: [HolidayTheme] {
        return [
            HolidayTheme.defaultTheme,
            HolidayTheme.halloween,
            HolidayTheme.christmas,
            HolidayTheme.valentines,
            HolidayTheme.stPatricks,
            HolidayTheme.easter,
            HolidayTheme.independence,
            HolidayTheme.thanksgiving,
            HolidayTheme.newYear
        ]
    }
}

// MARK: - Theme Environment
struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue: HolidayTheme = HolidayTheme.defaultTheme
}

extension EnvironmentValues {
    var appTheme: HolidayTheme {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}
