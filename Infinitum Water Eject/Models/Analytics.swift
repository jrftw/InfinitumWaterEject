/*
 * ============================================================================
 * INFINITUM WATER EJECT - ANALYTICS MODELS
 * ============================================================================
 * 
 * FILE: Analytics.swift
 * PURPOSE: Defines analytics models for detailed insights and statistics
 * AUTHOR: Kevin Doyle Jr.
 * CREATED: [1/15/2025]
 * LAST MODIFIED: [1/15/2025]
 *
 * DESCRIPTION:
 * This file contains analytics models for tracking detailed user behavior,
 * session patterns, and providing insights for the enhanced analytics dashboard.
 * 
 * ============================================================================
 */

import Foundation
import SwiftUI

// MARK: - Analytics Data Models

/// Comprehensive analytics data for the user
struct AnalyticsData {
    let sessionStats: SessionStatistics
    let deviceStats: DeviceStatistics
    let intensityStats: IntensityStatistics
    let timeStats: TimeStatistics
    let trends: TrendAnalysis
    let insights: [AnalyticsInsight]
    let recommendations: [AnalyticsRecommendation]
}

/// Session-related statistics
struct SessionStatistics {
    let totalSessions: Int
    let completedSessions: Int
    let averageDuration: TimeInterval
    let totalDuration: TimeInterval
    let completionRate: Double
    let weeklyAverage: Double
    let monthlyAverage: Double
    let longestStreak: Int
    let currentStreak: Int
    let bestWeek: Int
    let bestMonth: Int
}

/// Device usage statistics
struct DeviceStatistics {
    let deviceUsage: [DeviceType: Int]
    let mostUsedDevice: DeviceType?
    let leastUsedDevice: DeviceType?
    let deviceSuccessRates: [DeviceType: Double]
    let deviceAverageDurations: [DeviceType: TimeInterval]
}

/// Intensity level statistics
struct IntensityStatistics {
    let intensityUsage: [IntensityLevel: Int]
    let mostUsedIntensity: IntensityLevel?
    let leastUsedIntensity: IntensityLevel?
    let intensitySuccessRates: [IntensityLevel: Double]
    let intensityAverageDurations: [IntensityLevel: TimeInterval]
}

/// Time-based statistics
struct TimeStatistics {
    let hourlyDistribution: [Int: Int]
    let dailyDistribution: [Int: Int]
    let weeklyDistribution: [Int: Int]
    let monthlyDistribution: [Int: Int]
    let peakHour: Int?
    let peakDay: Int?
    let averageSessionsPerDay: Double
    let averageSessionsPerWeek: Double
}

/// Trend analysis data
struct TrendAnalysis {
    let weeklyTrend: [Date: Int]
    let monthlyTrend: [Date: Int]
    let completionRateTrend: [Date: Double]
    let durationTrend: [Date: TimeInterval]
    let isImproving: Bool
    let improvementRate: Double
}

/// Individual analytics insight
struct AnalyticsInsight: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let type: InsightType
    let value: String
    let icon: String
    let color: Color
    let priority: InsightPriority
}

/// Insight types
enum InsightType {
    case positive
    case negative
    case neutral
    case improvement
    case milestone
}

/// Insight priority levels
enum InsightPriority {
    case low
    case medium
    case high
    case critical
}

/// Analytics recommendation
struct AnalyticsRecommendation: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let action: String
    let benefit: String
    let icon: String
    let color: Color
    let priority: RecommendationPriority
}

/// Recommendation priority levels
enum RecommendationPriority {
    case low
    case medium
    case high
    case urgent
}

// MARK: - Analytics Service Helper

/// Helper class for calculating analytics data
class AnalyticsCalculator {
    
    /// Calculates comprehensive analytics from session data
    static func calculateAnalytics(from sessions: [WaterEjectionSession]) -> AnalyticsData {
        let sessionStats = calculateSessionStatistics(from: sessions)
        let deviceStats = calculateDeviceStatistics(from: sessions)
        let intensityStats = calculateIntensityStatistics(from: sessions)
        let timeStats = calculateTimeStatistics(from: sessions)
        let trends = calculateTrends(from: sessions)
        let insights = generateInsights(from: sessions, stats: sessionStats)
        let recommendations = generateRecommendations(from: sessions, stats: sessionStats)
        
        return AnalyticsData(
            sessionStats: sessionStats,
            deviceStats: deviceStats,
            intensityStats: intensityStats,
            timeStats: timeStats,
            trends: trends,
            insights: insights,
            recommendations: recommendations
        )
    }
    
    /// Calculates session statistics
    private static func calculateSessionStatistics(from sessions: [WaterEjectionSession]) -> SessionStatistics {
        let totalSessions = sessions.count
        let completedSessions = sessions.filter { $0.isCompleted }.count
        let completionRate = totalSessions > 0 ? Double(completedSessions) / Double(totalSessions) : 0
        
        let totalDuration = sessions.reduce(0) { $0 + $1.duration }
        let averageDuration = totalSessions > 0 ? totalDuration / Double(totalSessions) : 0
        
        // Weekly and monthly averages
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        
        let weeklySessions = sessions.filter { $0.startTime >= weekAgo }.count
        let monthlySessions = sessions.filter { $0.startTime >= monthAgo }.count
        
        let weeklyAverage = Double(weeklySessions)
        let monthlyAverage = Double(monthlySessions)
        
        // Streak calculation
        let currentStreak = calculateCurrentStreak(from: sessions)
        let longestStreak = calculateLongestStreak(from: sessions)
        
        // Best periods
        let bestWeek = calculateBestWeek(from: sessions)
        let bestMonth = calculateBestMonth(from: sessions)
        
        return SessionStatistics(
            totalSessions: totalSessions,
            completedSessions: completedSessions,
            averageDuration: averageDuration,
            totalDuration: totalDuration,
            completionRate: completionRate,
            weeklyAverage: weeklyAverage,
            monthlyAverage: monthlyAverage,
            longestStreak: longestStreak,
            currentStreak: currentStreak,
            bestWeek: bestWeek,
            bestMonth: bestMonth
        )
    }
    
    /// Calculates device statistics
    private static func calculateDeviceStatistics(from sessions: [WaterEjectionSession]) -> DeviceStatistics {
        let deviceUsage = Dictionary(grouping: sessions, by: { $0.deviceType })
            .mapValues { $0.count }
        
        let mostUsedDevice = deviceUsage.max(by: { $0.value < $1.value })?.key
        let leastUsedDevice = deviceUsage.min(by: { $0.value < $1.value })?.key
        
        let deviceSuccessRates = Dictionary(grouping: sessions, by: { $0.deviceType })
            .mapValues { sessions in
                let completed = sessions.filter { $0.isCompleted }.count
                return sessions.count > 0 ? Double(completed) / Double(sessions.count) : 0
            }
        
        let deviceAverageDurations = Dictionary(grouping: sessions, by: { $0.deviceType })
            .mapValues { sessions in
                let totalDuration = sessions.reduce(0) { $0 + $1.duration }
                return sessions.count > 0 ? totalDuration / Double(sessions.count) : 0
            }
        
        return DeviceStatistics(
            deviceUsage: deviceUsage,
            mostUsedDevice: mostUsedDevice,
            leastUsedDevice: leastUsedDevice,
            deviceSuccessRates: deviceSuccessRates,
            deviceAverageDurations: deviceAverageDurations
        )
    }
    
    /// Calculates intensity statistics
    private static func calculateIntensityStatistics(from sessions: [WaterEjectionSession]) -> IntensityStatistics {
        let intensityUsage = Dictionary(grouping: sessions, by: { $0.intensityLevel })
            .mapValues { $0.count }
        
        let mostUsedIntensity = intensityUsage.max(by: { $0.value < $1.value })?.key
        let leastUsedIntensity = intensityUsage.min(by: { $0.value < $1.value })?.key
        
        let intensitySuccessRates = Dictionary(grouping: sessions, by: { $0.intensityLevel })
            .mapValues { sessions in
                let completed = sessions.filter { $0.isCompleted }.count
                return sessions.count > 0 ? Double(completed) / Double(sessions.count) : 0
            }
        
        let intensityAverageDurations = Dictionary(grouping: sessions, by: { $0.intensityLevel })
            .mapValues { sessions in
                let totalDuration = sessions.reduce(0) { $0 + $1.duration }
                return sessions.count > 0 ? totalDuration / Double(sessions.count) : 0
            }
        
        return IntensityStatistics(
            intensityUsage: intensityUsage,
            mostUsedIntensity: mostUsedIntensity,
            leastUsedIntensity: leastUsedIntensity,
            intensitySuccessRates: intensitySuccessRates,
            intensityAverageDurations: intensityAverageDurations
        )
    }
    
    /// Calculates time-based statistics
    private static func calculateTimeStatistics(from sessions: [WaterEjectionSession]) -> TimeStatistics {
        let calendar = Calendar.current
        
        // Hourly distribution
        var hourlyDistribution: [Int: Int] = [:]
        for hour in 0..<24 {
            hourlyDistribution[hour] = sessions.filter { session in
                calendar.component(.hour, from: session.startTime) == hour
            }.count
        }
        
        // Daily distribution
        var dailyDistribution: [Int: Int] = [:]
        for day in 1...7 {
            dailyDistribution[day] = sessions.filter { session in
                calendar.component(.weekday, from: session.startTime) == day
            }.count
        }
        
        // Weekly and monthly distribution
        var weeklyDistribution: [Int: Int] = [:]
        var monthlyDistribution: [Int: Int] = [:]
        
        for session in sessions {
            let weekOfYear = calendar.component(.weekOfYear, from: session.startTime)
            let month = calendar.component(.month, from: session.startTime)
            
            weeklyDistribution[weekOfYear, default: 0] += 1
            monthlyDistribution[month, default: 0] += 1
        }
        
        let peakHour = hourlyDistribution.max(by: { $0.value < $1.value })?.key
        let peakDay = dailyDistribution.max(by: { $0.value < $1.value })?.key
        
        let totalDays = calendar.dateInterval(of: .day, for: Date())?.duration ?? 1
        let averageSessionsPerDay = totalDays > 0 ? Double(sessions.count) / totalDays : 0
        let averageSessionsPerWeek = averageSessionsPerDay * 7
        
        return TimeStatistics(
            hourlyDistribution: hourlyDistribution,
            dailyDistribution: dailyDistribution,
            weeklyDistribution: weeklyDistribution,
            monthlyDistribution: monthlyDistribution,
            peakHour: peakHour,
            peakDay: peakDay,
            averageSessionsPerDay: averageSessionsPerDay,
            averageSessionsPerWeek: averageSessionsPerWeek
        )
    }
    
    /// Calculates trends
    private static func calculateTrends(from sessions: [WaterEjectionSession]) -> TrendAnalysis {
        // Simplified trend calculation - would need more sophisticated analysis for real trends
        let calendar = Calendar.current
        let now = Date()
        
        var weeklyTrend: [Date: Int] = [:]
        let monthlyTrend: [Date: Int] = [:]
        var completionRateTrend: [Date: Double] = [:]
        var durationTrend: [Date: TimeInterval] = [:]
        
        // Calculate trends for the last 12 weeks
        for weekOffset in 0..<12 {
            if let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: now) {
                let weekEnd = calendar.date(byAdding: .weekOfYear, value: 1, to: weekStart) ?? weekStart
                let weekSessions = sessions.filter { $0.startTime >= weekStart && $0.startTime < weekEnd }
                
                weeklyTrend[weekStart] = weekSessions.count
                
                let completed = weekSessions.filter { $0.isCompleted }.count
                let rate = weekSessions.count > 0 ? Double(completed) / Double(weekSessions.count) : 0
                completionRateTrend[weekStart] = rate
                
                let avgDuration = weekSessions.count > 0 ? weekSessions.reduce(0) { $0 + $1.duration } / Double(weekSessions.count) : 0
                durationTrend[weekStart] = avgDuration
            }
        }
        
        // Calculate improvement rate (simplified)
        let recentWeeks = Array(weeklyTrend.values.prefix(4))
        let olderWeeks = Array(weeklyTrend.values.suffix(4))
        
        let recentAverage = recentWeeks.isEmpty ? 0 : Double(recentWeeks.reduce(0, +)) / Double(recentWeeks.count)
        let olderAverage = olderWeeks.isEmpty ? 0 : Double(olderWeeks.reduce(0, +)) / Double(olderWeeks.count)
        
        let isImproving = recentAverage > olderAverage
        let improvementRate = olderAverage > 0 ? (recentAverage - olderAverage) / olderAverage : 0
        
        return TrendAnalysis(
            weeklyTrend: weeklyTrend,
            monthlyTrend: monthlyTrend,
            completionRateTrend: completionRateTrend,
            durationTrend: durationTrend,
            isImproving: isImproving,
            improvementRate: improvementRate
        )
    }
    
    /// Generates insights
    private static func generateInsights(from sessions: [WaterEjectionSession], stats: SessionStatistics) -> [AnalyticsInsight] {
        var insights: [AnalyticsInsight] = []
        
        // Completion rate insight
        if stats.completionRate >= 0.9 {
            insights.append(AnalyticsInsight(
                title: "Excellent Completion Rate",
                description: "You're completing almost all your sessions!",
                type: .positive,
                value: "\(Int(stats.completionRate * 100))%",
                icon: "checkmark.circle.fill",
                color: .green,
                priority: .high
            ))
        } else if stats.completionRate < 0.7 {
            insights.append(AnalyticsInsight(
                title: "Low Completion Rate",
                description: "Try to complete more sessions for better results",
                type: .negative,
                value: "\(Int(stats.completionRate * 100))%",
                icon: "exclamationmark.triangle.fill",
                color: .orange,
                priority: .high
            ))
        }
        
        // Streak insight
        if stats.currentStreak >= 7 {
            insights.append(AnalyticsInsight(
                title: "Amazing Streak!",
                description: "You've maintained a \(stats.currentStreak)-day streak",
                type: .milestone,
                value: "\(stats.currentStreak) days",
                icon: "flame.fill",
                color: .orange,
                priority: .medium
            ))
        }
        
        // Session count milestone
        if stats.totalSessions >= 50 {
            insights.append(AnalyticsInsight(
                title: "Session Master",
                description: "You've completed \(stats.totalSessions) sessions!",
                type: .milestone,
                value: "\(stats.totalSessions)",
                icon: "trophy.fill",
                color: .yellow,
                priority: .medium
            ))
        }
        
        return insights
    }
    
    /// Generates recommendations
    private static func generateRecommendations(from sessions: [WaterEjectionSession], stats: SessionStatistics) -> [AnalyticsRecommendation] {
        var recommendations: [AnalyticsRecommendation] = []
        
        // Low completion rate recommendation
        if stats.completionRate < 0.8 {
            recommendations.append(AnalyticsRecommendation(
                title: "Improve Completion Rate",
                description: "Try to complete more sessions for better device protection",
                action: "Focus on completing sessions",
                benefit: "Better device protection and more accurate tracking",
                icon: "target",
                color: .blue,
                priority: .high
            ))
        }
        
        // Low activity recommendation
        if stats.weeklyAverage < 3 {
            recommendations.append(AnalyticsRecommendation(
                title: "Increase Activity",
                description: "Consider more frequent sessions for optimal device protection",
                action: "Aim for 3-5 sessions per week",
                benefit: "Better device protection and habit formation",
                icon: "chart.line.uptrend.xyaxis",
                color: .green,
                priority: .medium
            ))
        }
        
        // Try different intensities
        let intensityCount = Set(sessions.map { $0.intensityLevel }).count
        if intensityCount < 3 {
            recommendations.append(AnalyticsRecommendation(
                title: "Explore Intensities",
                description: "Try different intensity levels for various situations",
                action: "Experiment with different intensities",
                benefit: "Better understanding of what works for your devices",
                icon: "slider.horizontal.3",
                color: .purple,
                priority: .low
            ))
        }
        
        return recommendations
    }
    
    // MARK: - Helper Methods
    
    private static func calculateCurrentStreak(from sessions: [WaterEjectionSession]) -> Int {
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
    
    private static func calculateLongestStreak(from sessions: [WaterEjectionSession]) -> Int {
        // Simplified implementation - would need more sophisticated logic for real longest streak
        return calculateCurrentStreak(from: sessions)
    }
    
    private static func calculateBestWeek(from sessions: [WaterEjectionSession]) -> Int {
        let calendar = Calendar.current
        var weeklyCounts: [Int: Int] = [:]
        
        for session in sessions {
            let weekOfYear = calendar.component(.weekOfYear, from: session.startTime)
            weeklyCounts[weekOfYear, default: 0] += 1
        }
        
        return weeklyCounts.values.max() ?? 0
    }
    
    private static func calculateBestMonth(from sessions: [WaterEjectionSession]) -> Int {
        let calendar = Calendar.current
        var monthlyCounts: [Int: Int] = [:]
        
        for session in sessions {
            let month = calendar.component(.month, from: session.startTime)
            monthlyCounts[month, default: 0] += 1
        }
        
        return monthlyCounts.values.max() ?? 0
    }
} 