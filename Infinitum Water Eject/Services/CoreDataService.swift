import Foundation
import CoreData
import SwiftUI
#if canImport(WidgetKit)
import WidgetKit
#endif

class CoreDataService: ObservableObject {
    static let shared = CoreDataService()
    
    private let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "WaterEjectDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    // MARK: - User Settings
    func saveUserSettings(_ settings: UserSettings) {
        let request: NSFetchRequest<UserSettingsEntity> = UserSettingsEntity.fetchRequest()
        
        do {
            let results = try context.fetch(request)
            let entity: UserSettingsEntity
            
            if let existingEntity = results.first {
                entity = existingEntity
            } else {
                entity = UserSettingsEntity(context: context)
            }
            
            entity.theme = settings.theme.rawValue
            entity.isPremium = settings.isPremium
            entity.notificationsEnabled = settings.notificationsEnabled
            entity.dailyReminderTime = settings.dailyReminderTime
            entity.weeklyGoal = Int32(settings.weeklyGoal)
            
            save()
        } catch {
            print("Error saving user settings: \(error)")
        }
    }
    
    var userSettings: UserSettings? {
        let request: NSFetchRequest<UserSettingsEntity> = UserSettingsEntity.fetchRequest()
        
        do {
            let results = try context.fetch(request)
            if let entity = results.first {
                return UserSettings(
                    theme: AppTheme(rawValue: entity.theme ?? "auto") ?? .auto,
                    isPremium: entity.isPremium,
                    notificationsEnabled: entity.notificationsEnabled,
                    dailyReminderTime: entity.dailyReminderTime ?? Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date(),
                    weeklyGoal: Int(entity.weeklyGoal)
                )
            } else {
                // Create default settings if none exist
                let defaultSettings = UserSettings()
                saveUserSettings(defaultSettings)
                return defaultSettings
            }
        } catch {
            print("Error fetching user settings: \(error)")
            // Return default settings on error
            let defaultSettings = UserSettings()
            return defaultSettings
        }
    }
    
    // MARK: - Water Ejection Sessions
    func saveWaterEjectionSession(_ session: WaterEjectionSession) {
        let entity = SessionEntity(context: context)
        entity.id = session.id
        entity.deviceType = session.deviceType.rawValue
        entity.intensity = session.intensityLevel.rawValue
        entity.duration = session.duration
        entity.timestamp = session.startTime
        entity.isCompleted = session.isCompleted
        
        save()
        
        // Update widget data
        updateWidgetData()
    }
    
    private func updateWidgetData() {
        let sessions = getWaterEjectionSessions()
        let totalSessions = sessions.count
        let completedSessions = sessions.filter { $0.isCompleted }.count
        
        // Calculate weekly sessions
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let weeklySessions = sessions.filter { $0.startTime >= weekAgo }.count
        
        // Calculate completion rate
        let completionRate = totalSessions > 0 ? (Double(completedSessions) / Double(totalSessions)) * 100 : 0
        
        // Calculate average duration
        let totalDuration = sessions.reduce(0) { $0 + $1.duration }
        let averageDuration = totalSessions > 0 ? totalDuration / Double(totalSessions) : 0
        
        // Get last session date
        let lastSession = sessions.first?.startTime ?? Date()
        
        // Save to UserDefaults for widget
        let userDefaults = UserDefaults(suiteName: "group.com.infinitumimagery.watereject")
        userDefaults?.set(totalSessions, forKey: "totalSessions")
        userDefaults?.set(weeklySessions, forKey: "weeklySessions")
        userDefaults?.set(completionRate, forKey: "completionRate")
        userDefaults?.set(averageDuration, forKey: "averageDuration")
        userDefaults?.set(lastSession, forKey: "lastSessionDate")
        
        // Trigger widget refresh
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    func getWaterEjectionSessions() -> [WaterEjectionSession] {
        let request: NSFetchRequest<SessionEntity> = SessionEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SessionEntity.timestamp, ascending: false)]
        
        do {
            let entities = try context.fetch(request)
            return entities.map { entity in
                WaterEjectionSession(
                    id: entity.id ?? UUID(),
                    deviceType: DeviceType(rawValue: entity.deviceType ?? "iPhone") ?? .iphone,
                    intensityLevel: IntensityLevel(rawValue: entity.intensity ?? "Medium") ?? .medium,
                    duration: entity.duration,
                    startTime: entity.timestamp ?? Date(),
                    endTime: nil,
                    isCompleted: entity.isCompleted
                )
            }
        } catch {
            print("Error fetching sessions: \(error)")
            return []
        }
    }
    
    func deleteWaterEjectionSession(_ session: WaterEjectionSession) {
        let request: NSFetchRequest<SessionEntity> = SessionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", session.id as CVarArg)
        
        do {
            let entities = try context.fetch(request)
            entities.forEach { context.delete($0) }
            save()
        } catch {
            print("Error deleting session: \(error)")
        }
    }
}

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: AppTheme = .auto {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "selectedTheme")
        }
    }
    
    private init() {
        // Load saved theme from UserDefaults
        if let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = AppTheme(rawValue: savedTheme) {
            currentTheme = theme
        } else {
            currentTheme = .auto
        }
    }
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
    }
    
    var colorScheme: ColorScheme? {
        return currentTheme.colorScheme
    }
} 