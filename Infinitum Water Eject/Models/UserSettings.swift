/*
 * ============================================================================
 * INFINITUM WATER EJECT - USER SETTINGS MODEL
 * ============================================================================
 * 
 * FILE: UserSettings.swift
 * PURPOSE: Defines user preferences and app configuration data models
 * AUTHOR: Kevin Doyle Jr.
 * CREATED: [7/5/2025]
 * LAST MODIFIED: [7/9/2025]
 *
 * DESCRIPTION:
 * This file contains the core data models for user settings and preferences
 * in the Infinitum Water Eject application. It defines the UserSettings struct
 * and AppTheme enum that manage user customization options including theme
 * preferences, premium status, notification settings, and water consumption goals.
 * 
 * ARCHITECTURE OVERVIEW:
 * - UserSettings struct: Codable model for user preferences and app state
 * - AppTheme enum: Manages theme selection with display properties
 * - Core Data Integration: Full integration with Core Data persistence
 * - Codable Protocol: Enables JSON serialization for data persistence
 * - Default Values: Provides sensible defaults for new users
 * 
 * KEY COMPONENTS:
 * 1. UserSettings: Main data structure containing all user preferences
 * 2. AppTheme: Enumeration of available theme options (light, dark, auto)
 * 3. Theme Properties: Display names, icons, and ColorScheme mappings
 * 4. Core Data Extensions: Integration with UserSettingsEntity
 * 5. Initialization: Custom initializer with default values for new users
 * 
 * DATA FIELDS:
 * - theme: User's preferred app theme (light/dark/auto)
 * - isPremium: Boolean indicating premium subscription status
 * - notificationsEnabled: User's notification preference setting
 * - dailyReminderTime: Time for daily water consumption reminders
 * - weeklyGoal: Target number of water ejection sessions per week
 * 
 * DEPENDENCIES:
 * - Foundation: Core iOS framework for basic functionality
 * - CoreData: Data persistence framework (fully integrated)
 * - SwiftUI: UI framework for ColorScheme integration
 * 
 * TODO LIST:
 * - [x] Implement Core Data integration for persistent storage
 * - [ ] Add data validation for weekly goal ranges
 * - [ ] Create migration strategy for settings updates
 * - [ ] Add user preferences backup/restore functionality
 * - [ ] Implement settings sync across devices (iCloud)
 * - [ ] Add analytics tracking for user preference changes
 * - [ ] Create settings import/export functionality
 * 
 * FEATURE SUGGESTIONS:
 * - [ ] Add custom theme color selection
 * - [ ] Implement seasonal theme variations
 * - [ ] Add accessibility theme options for colorblind users
 * - [ ] Create theme preview functionality in settings
 * - [ ] Add user preference profiles for different contexts
 * - [ ] Implement smart theme switching based on time of day
 * - [ ] Add theme sharing between users
 * 
 * TECHNICAL NOTES:
 * - Uses Codable protocol for easy serialization
 * - Fully integrated with Core Data entities
 * - Provides computed properties for UI integration
 * - Follows Swift naming conventions and best practices
 * - Implements proper default values for new user experience
 * - Includes Core Data entity extensions for seamless integration
 * 
 * ============================================================================
 */

import Foundation
import CoreData
import SwiftUI

// MARK: - User Settings Data Model
// Main data structure containing all user preferences and app configuration
// Implements Codable for easy serialization and persistence
struct UserSettings: Codable {
    // MARK: - User Preference Properties
    // These properties define the user's customization options and app state
    
    /// User's preferred app theme (light, dark, or auto-follow system)
    /// Affects the overall visual appearance of the application
    var theme: AppTheme
    
    /// Indicates whether the user has an active premium subscription
    /// Controls access to premium features and removes advertisements
    var isPremium: Bool
    
    /// User's preference for receiving push notifications
    /// Controls daily reminders and other notification types
    var notificationsEnabled: Bool
    
    /// Time of day when daily water consumption reminders should be sent
    /// Stored as a Date object but only time components are used
    var dailyReminderTime: Date
    
    /// Target number of water and dust ejection sessions the user aims to complete per week
    /// Used for goal tracking and progress visualization
    var weeklyGoal: Int
    
    // MARK: - Initialization
    // Custom initializer with sensible default values for new users
    // Ensures all users have a consistent starting experience
    init(theme: AppTheme = .auto, 
         isPremium: Bool = false, 
         notificationsEnabled: Bool = true, 
         dailyReminderTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date(), 
         weeklyGoal: Int = 7) {
        self.theme = theme
        self.isPremium = isPremium
        self.notificationsEnabled = notificationsEnabled
        self.dailyReminderTime = dailyReminderTime
        self.weeklyGoal = weeklyGoal
    }
}

// MARK: - Core Data Integration Extensions

extension UserSettings {
    /// Creates a UserSettings instance from a Core Data entity
    init(from entity: UserSettingsEntity) {
        self.theme = AppTheme(rawValue: entity.theme ?? "auto") ?? .auto
        self.isPremium = entity.isPremium
        self.notificationsEnabled = entity.notificationsEnabled
        self.dailyReminderTime = entity.dailyReminderTime ?? Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
        self.weeklyGoal = Int(entity.weeklyGoal)
    }
    
    /// Updates a Core Data entity with the current UserSettings values
    func updateEntity(_ entity: UserSettingsEntity) {
        entity.theme = self.theme.rawValue
        entity.isPremium = self.isPremium
        entity.notificationsEnabled = self.notificationsEnabled
        entity.dailyReminderTime = self.dailyReminderTime
        entity.weeklyGoal = Int32(self.weeklyGoal)
    }
}

extension UserSettingsEntity {
    /// Creates a UserSettings instance from this entity
    var toUserSettings: UserSettings {
        return UserSettings(from: self)
    }
    
    /// Updates this entity with UserSettings values
    func update(from settings: UserSettings) {
        settings.updateEntity(self)
    }
}

// MARK: - App Theme Enumeration
// Defines available theme options with associated display properties
// Provides easy integration with SwiftUI's ColorScheme system
enum AppTheme: String, CaseIterable, Codable {
    // MARK: - Theme Cases
    // Three main theme options with string raw values for persistence
    
    /// Light theme - bright background with dark text
    case light = "light"
    
    /// Dark theme - dark background with light text
    case dark = "dark"
    
    /// Auto theme - follows system appearance setting
    case auto = "auto"
    
    // MARK: - Computed Properties
    // These properties provide UI-friendly values for each theme option
    
    /// Human-readable display name for the theme
    /// Used in settings UI and user-facing text
    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .auto: return "Auto"
        }
    }
    
    /// SF Symbol icon name for the theme
    /// Used in theme selection UI and settings displays
    var icon: String {
        switch self {
        case .light: return "sun.max.fill"  // Sun icon for light theme
        case .dark: return "moon.fill"      // Moon icon for dark theme
        case .auto: return "gear"           // Gear icon for auto theme
        }
    }
    
    /// SwiftUI ColorScheme value for the theme
    /// Returns nil for auto theme to follow system setting
    /// Used by SwiftUI's preferredColorScheme modifier
    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .auto: return nil // nil means follow system setting
        }
    }
} 
