/*
 * ============================================================================
 * INFINITUM WATER EJECT - ACHIEVEMENT SYSTEM
 * ============================================================================
 * 
 * FILE: Achievement.swift
 * PURPOSE: Defines achievement system models and tracking
 * AUTHOR: Kevin Doyle Jr.
 * CREATED: [1/15/2025]
 * LAST MODIFIED: [1/15/2025]
 *
 * DESCRIPTION:
 * This file contains the achievement system implementation for tracking
 * user accomplishments, badges, and gamification elements in the app.
 * 
 * ============================================================================
 */

import Foundation
import SwiftUI

// MARK: - Achievement Types
enum AchievementType: String, CaseIterable, Codable {
    case firstSession = "first_session"
    case weekWarrior = "week_warrior"
    case deviceMaster = "device_master"
    case emergencyHero = "emergency_hero"
    case streakMaster = "streak_master"
    case frequencyExplorer = "frequency_explorer"
    case watchUser = "watch_user"
    case premiumMember = "premium_member"
    case sessionMaster = "session_master"
    case deviceProtector = "device_protector"
    
    var title: String {
        switch self {
        case .firstSession: return "First Steps"
        case .weekWarrior: return "Week Warrior"
        case .deviceMaster: return "Device Master"
        case .emergencyHero: return "Emergency Hero"
        case .streakMaster: return "Streak Master"
        case .frequencyExplorer: return "Frequency Explorer"
        case .watchUser: return "Watch User"
        case .premiumMember: return "Premium Member"
        case .sessionMaster: return "Session Master"
        case .deviceProtector: return "Device Protector"
        }
    }
    
    var description: String {
        switch self {
        case .firstSession: return "Complete your first water ejection session"
        case .weekWarrior: return "Complete 7 sessions in a single week"
        case .deviceMaster: return "Use all 6 device types"
        case .emergencyHero: return "Complete 5 emergency intensity sessions"
        case .streakMaster: return "Maintain a 7-day streak"
        case .frequencyExplorer: return "Try all 5 intensity levels"
        case .watchUser: return "Complete a session on Apple Watch"
        case .premiumMember: return "Upgrade to Premium"
        case .sessionMaster: return "Complete 50 total sessions"
        case .deviceProtector: return "Complete 100 total sessions"
        }
    }
    
    var icon: String {
        switch self {
        case .firstSession: return "drop.fill"
        case .weekWarrior: return "calendar.badge.clock"
        case .deviceMaster: return "iphone.radiowaves.left.and.right"
        case .emergencyHero: return "exclamationmark.triangle.fill"
        case .streakMaster: return "flame.fill"
        case .frequencyExplorer: return "waveform.path.ecg"
        case .watchUser: return "applewatch"
        case .premiumMember: return "crown.fill"
        case .sessionMaster: return "trophy.fill"
        case .deviceProtector: return "shield.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .firstSession: return .blue
        case .weekWarrior: return .orange
        case .deviceMaster: return .purple
        case .emergencyHero: return .red
        case .streakMaster: return .yellow
        case .frequencyExplorer: return .cyan
        case .watchUser: return .green
        case .premiumMember: return .yellow
        case .sessionMaster: return .orange
        case .deviceProtector: return .blue
        }
    }
    
    var rarity: AchievementRarity {
        switch self {
        case .firstSession: return .common
        case .weekWarrior: return .uncommon
        case .deviceMaster: return .rare
        case .emergencyHero: return .epic
        case .streakMaster: return .rare
        case .frequencyExplorer: return .uncommon
        case .watchUser: return .uncommon
        case .premiumMember: return .epic
        case .sessionMaster: return .rare
        case .deviceProtector: return .legendary
        }
    }
}

// MARK: - Achievement Rarity
enum AchievementRarity: String, CaseIterable, Codable {
    case common = "common"
    case uncommon = "uncommon"
    case rare = "rare"
    case epic = "epic"
    case legendary = "legendary"
    
    var displayName: String {
        switch self {
        case .common: return "Common"
        case .uncommon: return "Uncommon"
        case .rare: return "Rare"
        case .epic: return "Epic"
        case .legendary: return "Legendary"
        }
    }
    
    var color: Color {
        switch self {
        case .common: return .gray
        case .uncommon: return .green
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
}

// MARK: - Achievement Model
struct Achievement: Identifiable, Codable {
    let id: UUID
    let type: AchievementType
    let unlockedAt: Date
    let progress: Double // 0.0 to 1.0
    let isUnlocked: Bool
    
    init(type: AchievementType, unlockedAt: Date = Date(), progress: Double = 1.0, isUnlocked: Bool = true) {
        self.id = UUID()
        self.type = type
        self.unlockedAt = unlockedAt
        self.progress = min(max(progress, 0.0), 1.0)
        self.isUnlocked = isUnlocked
    }
}

// MARK: - Achievement Progress
struct AchievementProgress: Codable {
    var firstSession: Bool = false
    var weekWarrior: Int = 0 // sessions this week
    var deviceMaster: Set<String> = [] // device types used
    var emergencyHero: Int = 0 // emergency sessions completed
    var streakMaster: Int = 0 // current streak days
    var frequencyExplorer: Set<String> = [] // intensity levels used
    var watchUser: Bool = false
    var premiumMember: Bool = false
    var sessionMaster: Int = 0 // total sessions
    var deviceProtector: Int = 0 // total sessions
    
    mutating func updateProgress(for sessions: [WaterEjectionSession], isPremium: Bool) {
        // First Session
        if !firstSession && !sessions.isEmpty {
            firstSession = true
        }
        
        // Week Warrior
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        weekWarrior = sessions.filter { $0.startTime >= weekAgo }.count
        
        // Device Master
        deviceMaster = Set(sessions.map { $0.deviceType.rawValue })
        
        // Emergency Hero
        emergencyHero = sessions.filter { $0.intensityLevel == .emergency }.count
        
        // Frequency Explorer
        frequencyExplorer = Set(sessions.map { $0.intensityLevel.rawValue })
        
        // Watch User (would need to be set from Watch App)
        // This will be updated when Watch App completes a session
        
        // Premium Member
        premiumMember = isPremium
        
        // Session Master & Device Protector
        sessionMaster = sessions.count
        deviceProtector = sessions.count
        
        // Streak Master (simplified - would need more complex logic for actual streaks)
        streakMaster = calculateCurrentStreak(sessions: sessions)
    }
    
    private func calculateCurrentStreak(sessions: [WaterEjectionSession]) -> Int {
        let calendar = Calendar.current
        let today = Date()
        var streak = 0
        var currentDate = today
        
        while true {
            let hasSessionToday = sessions.contains { session in
                calendar.isDate(session.startTime, inSameDayAs: currentDate)
            }
            
            if hasSessionToday {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
    
    func getUnlockedAchievements() -> [AchievementType] {
        var unlocked: [AchievementType] = []
        
        if firstSession { unlocked.append(.firstSession) }
        if weekWarrior >= 7 { unlocked.append(.weekWarrior) }
        if deviceMaster.count >= 6 { unlocked.append(.deviceMaster) }
        if emergencyHero >= 5 { unlocked.append(.emergencyHero) }
        if streakMaster >= 7 { unlocked.append(.streakMaster) }
        if frequencyExplorer.count >= 5 { unlocked.append(.frequencyExplorer) }
        if watchUser { unlocked.append(.watchUser) }
        if premiumMember { unlocked.append(.premiumMember) }
        if sessionMaster >= 50 { unlocked.append(.sessionMaster) }
        if deviceProtector >= 100 { unlocked.append(.deviceProtector) }
        
        return unlocked
    }
    
    func getProgress(for type: AchievementType) -> Double {
        switch type {
        case .firstSession:
            return firstSession ? 1.0 : 0.0
        case .weekWarrior:
            return min(Double(weekWarrior) / 7.0, 1.0)
        case .deviceMaster:
            return min(Double(deviceMaster.count) / 6.0, 1.0)
        case .emergencyHero:
            return min(Double(emergencyHero) / 5.0, 1.0)
        case .streakMaster:
            return min(Double(streakMaster) / 7.0, 1.0)
        case .frequencyExplorer:
            return min(Double(frequencyExplorer.count) / 5.0, 1.0)
        case .watchUser:
            return watchUser ? 1.0 : 0.0
        case .premiumMember:
            return premiumMember ? 1.0 : 0.0
        case .sessionMaster:
            return min(Double(sessionMaster) / 50.0, 1.0)
        case .deviceProtector:
            return min(Double(deviceProtector) / 100.0, 1.0)
        }
    }
} 