/*
 * ============================================================================
 * INFINITUM WATER EJECT - ACHIEVEMENT SERVICE
 * ============================================================================
 * 
 * FILE: AchievementService.swift
 * PURPOSE: Manages achievement system, progress tracking, and notifications
 * AUTHOR: Kevin Doyle Jr.
 * CREATED: [1/15/2025]
 * LAST MODIFIED: [1/15/2025]
 *
 * DESCRIPTION:
 * This file contains the achievement service implementation for tracking
 * user progress, managing achievements, and providing gamification features.
 * 
 * ============================================================================
 */

import Foundation
import SwiftUI
import UserNotifications
import WidgetKit

// MARK: - Achievement Service Class
class AchievementService: ObservableObject {
    // MARK: - Singleton Instance
    static let shared = AchievementService()
    
    // MARK: - Published Properties
    @Published var achievements: [Achievement] = []
    @Published var progress: AchievementProgress = AchievementProgress()
    @Published var recentlyUnlocked: [AchievementType] = []
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let achievementKey = "userAchievements"
    private let progressKey = "achievementProgress"
    
    // MARK: - Initialization
    private init() {
        loadAchievements()
        loadProgress()
    }
    
    // MARK: - Achievement Management
    
    /// Updates achievement progress based on current sessions
    func updateProgress(sessions: [WaterEjectionSession], isPremium: Bool) {
        progress.updateProgress(for: sessions, isPremium: isPremium)
        
        // Check for newly unlocked achievements
        let newlyUnlocked = progress.getUnlockedAchievements()
        let previouslyUnlocked = Set(achievements.map { $0.type })
        
        for achievementType in newlyUnlocked {
            if !previouslyUnlocked.contains(achievementType) {
                unlockAchievement(achievementType)
            }
        }
        
        saveProgress()
    }
    
    /// Unlocks a specific achievement
    private func unlockAchievement(_ type: AchievementType) {
        let achievement = Achievement(type: type)
        achievements.append(achievement)
        recentlyUnlocked.append(type)
        
        // Show notification
        showAchievementNotification(achievement)
        
        // Save achievements
        saveAchievements()
        
        // Update widget data
        updateWidgetData()
        
        // Remove from recently unlocked after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.recentlyUnlocked.removeAll { $0 == type }
        }
    }
    
    /// Shows achievement unlock notification
    private func showAchievementNotification(_ achievement: Achievement) {
        let content = UNMutableNotificationContent()
        content.title = "🏆 Achievement Unlocked!"
        content.body = "\(achievement.type.title): \(achievement.type.description)"
        content.sound = .default
        content.badge = NSNumber(value: achievements.count)
        
        let request = UNNotificationRequest(
            identifier: "achievement-\(achievement.type.rawValue)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    /// Gets all achievements with their current progress
    func getAllAchievementsWithProgress() -> [(AchievementType, Double, Bool)] {
        return AchievementType.allCases.map { type in
            let progress = self.progress.getProgress(for: type)
            let isUnlocked = achievements.contains { $0.type == type }
            return (type, progress, isUnlocked)
        }
    }
    
    /// Gets achievements by rarity
    func getAchievementsByRarity() -> [AchievementRarity: [AchievementType]] {
        var grouped: [AchievementRarity: [AchievementType]] = [:]
        
        for rarity in AchievementRarity.allCases {
            grouped[rarity] = AchievementType.allCases.filter { $0.rarity == rarity }
        }
        
        return grouped
    }
    
    /// Gets user's achievement statistics
    func getAchievementStats() -> AchievementStats {
        let totalAchievements = AchievementType.allCases.count
        let unlockedCount = achievements.count
        let completionRate = totalAchievements > 0 ? Double(unlockedCount) / Double(totalAchievements) : 0
        
        let rarityStats = AchievementRarity.allCases.map { rarity in
            let rarityAchievements = AchievementType.allCases.filter { $0.rarity == rarity }
            let unlockedInRarity = achievements.filter { $0.type.rarity == rarity }.count
            return (rarity, unlockedInRarity, rarityAchievements.count)
        }
        
        return AchievementStats(
            totalAchievements: totalAchievements,
            unlockedCount: unlockedCount,
            completionRate: completionRate,
            rarityStats: rarityStats
        )
    }
    
    /// Marks watch user achievement as unlocked
    func unlockWatchUserAchievement() {
        if !progress.watchUser {
            progress.watchUser = true
            saveProgress()
            
            if !achievements.contains(where: { $0.type == .watchUser }) {
                unlockAchievement(.watchUser)
            }
        }
    }
    
    // MARK: - Data Persistence
    
    /// Saves achievements to UserDefaults
    private func saveAchievements() {
        if let data = try? JSONEncoder().encode(achievements) {
            userDefaults.set(data, forKey: achievementKey)
        }
    }
    
    /// Loads achievements from UserDefaults
    private func loadAchievements() {
        if let data = userDefaults.data(forKey: achievementKey),
           let loadedAchievements = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = loadedAchievements
        }
    }
    
    /// Saves progress to UserDefaults
    private func saveProgress() {
        if let data = try? JSONEncoder().encode(progress) {
            userDefaults.set(data, forKey: progressKey)
        }
    }
    
    /// Loads progress from UserDefaults
    private func loadProgress() {
        if let data = userDefaults.data(forKey: progressKey),
           let loadedProgress = try? JSONDecoder().decode(AchievementProgress.self, from: data) {
            progress = loadedProgress
        }
    }
    
    // MARK: - Widget Integration
    
    /// Updates widget data with achievement information
    private func updateWidgetData() {
        let userDefaults = UserDefaults(suiteName: "group.com.infinitumimagery.watereject")
        userDefaults?.set(achievements.count, forKey: "achievementCount")
        userDefaults?.set(progress.getUnlockedAchievements().count, forKey: "unlockedAchievements")
        
        // Update widget timeline
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    // MARK: - Reset Functionality
    
    /// Resets all achievements (for testing or user request)
    func resetAchievements() {
        achievements.removeAll()
        progress = AchievementProgress()
        recentlyUnlocked.removeAll()
        
        saveAchievements()
        saveProgress()
        updateWidgetData()
    }
}

// MARK: - Achievement Statistics
struct AchievementStats {
    let totalAchievements: Int
    let unlockedCount: Int
    let completionRate: Double
    let rarityStats: [(AchievementRarity, Int, Int)] // (rarity, unlocked, total)
    
    var completionPercentage: Int {
        return Int(completionRate * 100)
    }
    
    var nextAchievement: AchievementType? {
        // Return the next easiest achievement to unlock
        let unlockedTypes = Set(AchievementType.allCases.filter { _ in false }) // Placeholder
        return AchievementType.allCases.first { !unlockedTypes.contains($0) }
    }
} 