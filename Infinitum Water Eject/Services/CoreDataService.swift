/*
 * ============================================================================
 * INFINITUM WATER EJECT - CORE DATA SERVICE
 * ============================================================================
 * 
 * FILE: CoreDataService.swift
 * PURPOSE: Manages Core Data persistence and data operations for the app
 * AUTHOR: Kevin Doyle Jr.
 * CREATED: [7/5/2025]
 * LAST MODIFIED: [7/9/2025]
 *
 * DESCRIPTION:
 * This file contains the Core Data service implementation for the Infinitum Water
 * Eject application. It manages persistent data storage for user settings,
 * water ejection sessions, and provides data synchronization with widgets.
 * The service includes a ThemeManager for app-wide theme management and
 * comprehensive data operations with error handling and widget updates.
 * 
 * ARCHITECTURE OVERVIEW:
 * - CoreDataService: Singleton service managing Core Data operations
 * - ThemeManager: Separate singleton for theme state management
 * - Persistent Container: Core Data stack with automatic error handling
 * - Widget Integration: Data sharing with iOS widgets via UserDefaults
 * - Data Operations: CRUD operations for settings and sessions
 * - Error Handling: Comprehensive error handling with fallbacks
 * 
 * KEY COMPONENTS:
 * 1. CoreDataService: Main data persistence service with singleton pattern
 * 2. ThemeManager: App-wide theme management with UserDefaults persistence
 * 3. User Settings Management: Complete CRUD operations for user preferences
 * 4. Session Management: Water ejection session storage and retrieval
 * 5. Widget Data Sync: Automatic widget data updates and timeline refresh
 * 6. Error Recovery: Graceful error handling with default value fallbacks
 * 
 * DATA ENTITIES:
 * - UserSettingsEntity: Stores user preferences and app configuration
 * - SessionEntity: Stores water ejection session data and statistics
 * - Widget Data: Shared data for iOS widget display and updates
 * 
 * WIDGET INTEGRATION:
 * - Total sessions count for widget display
 * - Weekly session statistics for progress tracking
 * - Completion rate calculation for success metrics
 * - Average duration for performance insights
 * - Last session date for recent activity display
 * 
 * DEPENDENCIES:
 * - Foundation: Core iOS framework for basic functionality
 * - CoreData: Apple's data persistence framework
 * - SwiftUI: UI framework for theme integration
 * - WidgetKit: iOS widget framework (conditional import)
 * 
 * TODO LIST:
 * - [ ] Add data migration support for schema updates
 * - [ ] Implement data backup and restore functionality
 * - [ ] Add data export capabilities (CSV, JSON)
 * - [ ] Create data analytics and reporting features
 * - [ ] Implement data synchronization across devices (iCloud)
 * - [ ] Add data validation and integrity checks
 * - [ ] Create data cleanup and maintenance routines
 * - [ ] Implement data compression for large datasets
 * 
 * FEATURE SUGGESTIONS:
 * - [ ] Add data visualization and chart generation
 * - [ ] Implement data-driven insights and recommendations
 * - [ ] Create data comparison and trend analysis
 * - [ ] Add data sharing between users
 * - [ ] Implement data privacy and GDPR compliance
 * - [ ] Create data archiving for long-term storage
 * - [ ] Add data search and filtering capabilities
 * - [ ] Implement data versioning and history tracking
 * 
 * TECHNICAL NOTES:
 * - Uses singleton pattern for global data access
 * - Implements proper Core Data error handling
 * - Provides automatic widget data synchronization
 * - Uses UserDefaults for theme persistence
 * - Implements graceful fallbacks for data errors
 * - Supports conditional widget framework import
 * - Follows Core Data best practices and patterns
 * 
 * ============================================================================
 */

import Foundation
import CoreData
import SwiftUI
#if canImport(WidgetKit)
import WidgetKit
#endif

// MARK: - Core Data Service Class
// Singleton service class that manages all Core Data operations and persistence
// Handles user settings, session data, and widget synchronization

class CoreDataService: ObservableObject {
    // MARK: - Singleton Instance
    // Shared instance for global access to Core Data functionality
    static let shared = CoreDataService()
    
    // MARK: - Core Data Container
    // Persistent container that manages the Core Data stack
    
    /// Core Data persistent container for data storage
    /// Manages the data model and persistent store coordination
    private let container: NSPersistentContainer
    
    // MARK: - Initialization
    // Private initializer for singleton pattern with Core Data setup
    
    /// Initializes the Core Data service with persistent container setup
    /// Loads the data model and configures error handling
    init() {
        // MARK: - Persistent Container Setup
        // Create persistent container with the app's data model name
        container = NSPersistentContainer(name: "WaterEjectDataModel")
        
        // MARK: - Store Loading
        // Load persistent stores with error handling
        // Prints error messages for debugging but continues operation
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Managed Object Context
    // Provides access to the main managed object context for data operations
    
    /// Main managed object context for Core Data operations
    /// Used for all data reading, writing, and manipulation
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    // MARK: - Context Saving
    // Saves changes to the managed object context with error handling
    
    /// Saves the managed object context if there are unsaved changes
    /// Includes error handling and logging for debugging
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    // MARK: - User Settings Management
    // Complete CRUD operations for user settings and preferences
    
    /// Saves user settings to Core Data storage
    /// Creates new entity or updates existing one based on availability
    func saveUserSettings(_ settings: UserSettings) {
        // MARK: - Fetch Request Setup
        // Create fetch request to find existing user settings entity
        let request: NSFetchRequest<UserSettingsEntity> = UserSettingsEntity.fetchRequest()
        
        do {
            // MARK: - Entity Retrieval
            // Fetch existing settings or create new entity
            let results = try context.fetch(request)
            let entity: UserSettingsEntity
            
            if let existingEntity = results.first {
                entity = existingEntity  // Use existing entity for updates
            } else {
                entity = UserSettingsEntity(context: context)  // Create new entity
            }
            
            // MARK: - Settings Assignment using Core Data integration
            // Use the new Core Data integration extension
            entity.update(from: settings)
            
            save()  // Persist changes to Core Data
        } catch {
            print("Error saving user settings: \(error)")
        }
    }
    
    // MARK: - User Settings Retrieval
    // Retrieves user settings with fallback to default values
    
    /// Retrieves user settings from Core Data with default fallback
    /// Creates default settings if none exist or on error
    var userSettings: UserSettings? {
        // MARK: - Fetch Request Setup
        // Create fetch request for user settings entity
        let request: NSFetchRequest<UserSettingsEntity> = UserSettingsEntity.fetchRequest()
        
        do {
            // MARK: - Settings Retrieval using Core Data integration
            // Fetch and convert Core Data entity to UserSettings model
            let results = try context.fetch(request)
            if let entity = results.first {
                return entity.toUserSettings
            } else {
                // MARK: - Default Settings Creation
                // Create and save default settings if none exist
                let defaultSettings = UserSettings()
                saveUserSettings(defaultSettings)
                return defaultSettings
            }
        } catch {
            print("Error fetching user settings: \(error)")
            // MARK: - Error Fallback
            // Return default settings on error for graceful degradation
            let defaultSettings = UserSettings()
            return defaultSettings
        }
    }
    
    // MARK: - Water Ejection Session Management
    // Complete CRUD operations for water ejection sessions
    
    /// Saves a water ejection session to Core Data storage
    /// Creates new session entity and triggers widget data update
    func saveWaterEjectionSession(_ session: WaterEjectionSession) {
        // MARK: - Session Entity Creation
        // Create new session entity and populate with session data
        let entity = SessionEntity(context: context)
        
        // MARK: - Session Assignment using Core Data integration
        // Use the new Core Data integration extension
        entity.update(from: session)
        
        save()  // Persist session to Core Data
        
        // MARK: - Widget Data Update
        // Update widget data after session save
        updateWidgetData()
    }
    
    // MARK: - Widget Data Synchronization
    // Calculates and updates widget data for iOS widget display
    
    /// Updates widget data with current session statistics
    /// Calculates various metrics and triggers widget refresh
    private func updateWidgetData() {
        // MARK: - Session Data Retrieval
        // Get all sessions for statistics calculation
        let sessions = getWaterEjectionSessions()
        let totalSessions = sessions.count
        let completedSessions = sessions.filter { $0.isCompleted }.count
        
        // MARK: - Weekly Statistics Calculation
        // Calculate sessions from the last 7 days
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let weeklySessions = sessions.filter { $0.startTime >= weekAgo }.count
        
        // MARK: - Performance Metrics
        // Calculate completion rate and average duration
        let completionRate = totalSessions > 0 ? (Double(completedSessions) / Double(totalSessions)) * 100 : 0
        let totalDuration = sessions.reduce(0) { $0 + $1.duration }
        let averageDuration = totalSessions > 0 ? totalDuration / Double(totalSessions) : 0
        
        // MARK: - Recent Activity
        // Get last session date for recent activity display
        let lastSession = sessions.first?.startTime ?? Date()
        
        // MARK: - Widget Data Storage
        // Save calculated statistics to shared UserDefaults for widget access
        let userDefaults = UserDefaults(suiteName: "group.com.infinitumimagery.watereject")
        userDefaults?.set(totalSessions, forKey: "totalSessions")
        userDefaults?.set(weeklySessions, forKey: "weeklySessions")
        userDefaults?.set(completionRate, forKey: "completionRate")
        userDefaults?.set(averageDuration, forKey: "averageDuration")
        userDefaults?.set(lastSession, forKey: "lastSessionDate")
        
        // MARK: - Widget Timeline Refresh
        // Trigger widget refresh to display updated data
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    // MARK: - Session Retrieval
    // Retrieves all water ejection sessions with sorting
    
    /// Retrieves all water ejection sessions sorted by timestamp
    /// Converts Core Data entities to WaterEjectionSession models
    func getWaterEjectionSessions() -> [WaterEjectionSession] {
        // MARK: - Fetch Request Setup
        // Create fetch request with timestamp sorting (newest first)
        let request: NSFetchRequest<SessionEntity> = SessionEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SessionEntity.timestamp, ascending: false)]
        
        do {
            // MARK: - Entity to Model Conversion using Core Data integration
            // Fetch entities and convert to WaterEjectionSession models
            let entities = try context.fetch(request)
            return entities.map { $0.toWaterEjectionSession }
        } catch {
            print("Error fetching sessions: \(error)")
            return []  // Return empty array on error
        }
    }
    
    // MARK: - Session Deletion
    // Deletes a specific water ejection session
    
    /// Deletes a water ejection session from Core Data storage
    /// Uses session ID for precise deletion targeting
    func deleteWaterEjectionSession(_ session: WaterEjectionSession) {
        // MARK: - Fetch Request with Predicate
        // Create fetch request with ID predicate for precise deletion
        let request: NSFetchRequest<SessionEntity> = SessionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", session.id as CVarArg)
        
        do {
            // MARK: - Entity Deletion
            // Fetch and delete matching entities
            let entities = try context.fetch(request)
            entities.forEach { context.delete($0) }
            save()  // Persist deletion to Core Data
        } catch {
            print("Error deleting session: \(error)")
        }
    }
}

// MARK: - Theme Manager Class
// Singleton class for app-wide theme management and persistence

class ThemeManager: ObservableObject {
    // MARK: - Singleton Instance
    // Shared instance for global theme access
    static let shared = ThemeManager()
    
    // MARK: - Published Theme Property
    // Observable theme property that triggers UI updates
    
    /// Current app theme with automatic UserDefaults persistence
    /// Triggers UI updates when changed and saves to UserDefaults
    @Published var currentTheme: AppTheme = .auto {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "selectedTheme")
        }
    }
    
    // MARK: - Private Initialization
    // Private initializer for singleton pattern with theme loading
    
    /// Private initializer that loads saved theme from UserDefaults
    /// Falls back to auto theme if no saved theme exists
    private init() {
        // MARK: - Theme Loading
        // Load saved theme from UserDefaults with fallback
        if let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = AppTheme(rawValue: savedTheme) {
            currentTheme = theme  // Use saved theme
        } else {
            currentTheme = .auto  // Fallback to auto theme
        }
    }
    
    // MARK: - Theme Setting
    // Public method for changing the app theme
    
    /// Sets the current app theme and triggers UI updates
    /// Automatically saves to UserDefaults via property observer
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
    }
    
    // MARK: - Color Scheme Access
    // Computed property for SwiftUI color scheme integration
    
    /// Returns SwiftUI ColorScheme for the current theme
    /// Used by SwiftUI's preferredColorScheme modifier
    var colorScheme: ColorScheme? {
        return currentTheme.colorScheme
    }
} 
