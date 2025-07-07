import Foundation
import CoreData
import SwiftUI

// Core Data model - this will be generated from the .xcdatamodeld file
// For now, we'll use a simple struct that can be converted to/from Core Data

struct UserSettings: Codable {
    var theme: AppTheme
    var isPremium: Bool
    var notificationsEnabled: Bool
    var dailyReminderTime: Date
    var weeklyGoal: Int
    
    init(theme: AppTheme = .auto, isPremium: Bool = false, notificationsEnabled: Bool = true, dailyReminderTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date(), weeklyGoal: Int = 7) {
        self.theme = theme
        self.isPremium = isPremium
        self.notificationsEnabled = notificationsEnabled
        self.dailyReminderTime = dailyReminderTime
        self.weeklyGoal = weeklyGoal
    }
}

enum AppTheme: String, CaseIterable, Codable {
    case light = "light"
    case dark = "dark"
    case auto = "auto"
    
    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .auto: return "Auto"
        }
    }
    
    var icon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .auto: return "gear"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .auto: return nil // nil means follow system
        }
    }
} 