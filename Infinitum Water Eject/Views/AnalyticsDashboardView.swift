/*
 * ============================================================================
 * INFINITUM WATER EJECT - ANALYTICS DASHBOARD VIEW
 * ============================================================================
 * 
 * FILE: AnalyticsDashboardView.swift
 * PURPOSE: Displays comprehensive analytics dashboard with insights and recommendations
 * AUTHOR: Kevin Doyle Jr.
 * CREATED: [1/15/2025]
 * LAST MODIFIED: [1/15/2025]
 *
 * DESCRIPTION:
 * This file contains the enhanced analytics dashboard implementation for displaying
 * detailed user statistics, insights, and personalized recommendations.
 * 
 * ============================================================================
 */

import SwiftUI
import Charts

@available(iOS 16.0, *)
struct AnalyticsDashboardView: View {
    @StateObject private var coreDataService = CoreDataService.shared
    @State private var analyticsData: AnalyticsData?
    @State private var selectedTimeframe: Timeframe = .week
    @State private var showingDetailedStats = false
    
    enum Timeframe: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        case all = "All Time"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Timeframe Selector
                    TimeframeSelector(selectedTimeframe: $selectedTimeframe)
                    
                    // Overview Cards
                    OverviewCardsSection(analyticsData: analyticsData)
                    
                    // Insights Section
                    if let insights = analyticsData?.insights, !insights.isEmpty {
                        InsightsSection(insights: insights)
                    }
                    
                    // Recommendations Section
                    if let recommendations = analyticsData?.recommendations, !recommendations.isEmpty {
                        RecommendationsSection(recommendations: recommendations)
                    }
                    
                    // Detailed Statistics
                    DetailedStatsSection(analyticsData: analyticsData)
                    
                    // Charts Section
                    ChartsSection(analyticsData: analyticsData)
                }
                .padding()
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingDetailedStats) {
                DetailedAnalyticsView(analyticsData: analyticsData)
            }
            .onAppear {
                loadAnalyticsData()
            }
            .refreshable {
                loadAnalyticsData()
            }
        }
    }
    
    private func loadAnalyticsData() {
        let sessions = coreDataService.getWaterEjectionSessions()
        analyticsData = AnalyticsCalculator.calculateAnalytics(from: sessions)
    }
}

// MARK: - Timeframe Selector
@available(iOS 16.0, *)
struct TimeframeSelector: View {
    @Binding var selectedTimeframe: AnalyticsDashboardView.Timeframe
    
    var body: some View {
        HStack {
            ForEach(AnalyticsDashboardView.Timeframe.allCases, id: \.self) { timeframe in
                Button(action: {
                    selectedTimeframe = timeframe
                }) {
                    Text(timeframe.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(selectedTimeframe == timeframe ? .white : .primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedTimeframe == timeframe ? Color.blue : Color(.systemGray6))
                        .cornerRadius(16)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

// MARK: - Overview Cards Section
@available(iOS 16.0, *)
struct OverviewCardsSection: View {
    let analyticsData: AnalyticsData?
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
            if let data = analyticsData {
                StatCard(
                    title: "Total Sessions",
                    value: "\(data.sessionStats.totalSessions)",
                    icon: "number.circle.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Completion Rate",
                    value: "\(Int(data.sessionStats.completionRate * 100))%",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Current Streak",
                    value: "\(data.sessionStats.currentStreak) days",
                    icon: "flame.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "Avg Duration",
                    value: formatDuration(data.sessionStats.averageDuration),
                    icon: "clock.fill",
                    color: .purple
                )
            } else {
                ForEach(0..<4, id: \.self) { _ in
                    StatCard(
                        title: "Loading...",
                        value: "...",
                        icon: "circle.dashed",
                        color: .gray
                    )
                }
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        return "\(minutes)m"
    }
}

// MARK: - Stat Card
@available(iOS 16.0, *)
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Insights Section
@available(iOS 16.0, *)
struct InsightsSection: View {
    let insights: [AnalyticsInsight]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights")
                .font(.headline)
                .fontWeight(.semibold)
            
            ForEach(insights) { insight in
                InsightCard(insight: insight)
            }
        }
    }
}

// MARK: - Insight Card
@available(iOS 16.0, *)
struct InsightCard: View {
    let insight: AnalyticsInsight
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: insight.icon)
                .font(.title2)
                .foregroundColor(insight.color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(insight.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text(insight.value)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(insight.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(insight.color.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Recommendations Section
@available(iOS 16.0, *)
struct RecommendationsSection: View {
    let recommendations: [AnalyticsRecommendation]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommendations")
                .font(.headline)
                .fontWeight(.semibold)
            
            ForEach(recommendations) { recommendation in
                RecommendationCard(recommendation: recommendation)
            }
        }
    }
}

// MARK: - Recommendation Card
@available(iOS 16.0, *)
struct RecommendationCard: View {
    let recommendation: AnalyticsRecommendation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: recommendation.icon)
                    .font(.title3)
                    .foregroundColor(recommendation.color)
                
                Text(recommendation.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                PriorityBadge(priority: recommendation.priority)
            }
            
            Text(recommendation.description)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Action:")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(recommendation.action)
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Benefit:")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(recommendation.benefit)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Priority Badge
@available(iOS 16.0, *)
struct PriorityBadge: View {
    let priority: RecommendationPriority
    
    var body: some View {
        Text(priorityText.capitalized)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(priorityColor)
            .cornerRadius(4)
    }
    
    private var priorityText: String {
        switch priority {
        case .low: return "low"
        case .medium: return "medium"
        case .high: return "high"
        case .urgent: return "urgent"
        }
    }
    
    private var priorityColor: Color {
        switch priority {
        case .low: return .gray
        case .medium: return .blue
        case .high: return .orange
        case .urgent: return .red
        }
    }
}

// MARK: - Detailed Stats Section
@available(iOS 16.0, *)
struct DetailedStatsSection: View {
    let analyticsData: AnalyticsData?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Detailed Statistics")
                .font(.headline)
                .fontWeight(.semibold)
            
            if let data = analyticsData {
                VStack(spacing: 16) {
                    // Device Usage
                    if !data.deviceStats.deviceUsage.isEmpty {
                        DeviceUsageCard(deviceStats: data.deviceStats)
                    }
                    
                    // Intensity Usage
                    if !data.intensityStats.intensityUsage.isEmpty {
                        IntensityUsageCard(intensityStats: data.intensityStats)
                    }
                    
                    // Time Patterns
                    TimePatternsCard(timeStats: data.timeStats)
                }
            } else {
                ProgressView("Loading statistics...")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
    }
}

// MARK: - Device Usage Card
@available(iOS 16.0, *)
struct DeviceUsageCard: View {
    let deviceStats: DeviceStatistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Device Usage")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            ForEach(Array(DeviceType.allCases), id: \.self) { device in
                if let count = deviceStats.deviceUsage[device] {
                    HStack {
                        Image(systemName: device.icon)
                            .foregroundColor(device.color)
                            .frame(width: 20)
                        
                        Text(device.displayName)
                            .font(.caption)
                        
                        Spacer()
                        
                        Text("\(count)")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Intensity Usage Card
@available(iOS 16.0, *)
struct IntensityUsageCard: View {
    let intensityStats: IntensityStatistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Intensity Usage")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            ForEach(IntensityLevel.allCases, id: \.self) { intensity in
                if let count = intensityStats.intensityUsage[intensity] {
                    HStack {
                        Circle()
                            .fill(intensity.color)
                            .frame(width: 12, height: 12)
                        
                        Text(intensity.displayName)
                            .font(.caption)
                        
                        Spacer()
                        
                        Text("\(count)")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Time Patterns Card
@available(iOS 16.0, *)
struct TimePatternsCard: View {
    let timeStats: TimeStatistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Time Patterns")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Peak Hour:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let peakHour = timeStats.peakHour {
                        Text("\(peakHour):00")
                            .font(.caption)
                            .fontWeight(.medium)
                    } else {
                        Text("N/A")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Avg/Day:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(String(format: "%.1f", timeStats.averageSessionsPerDay))
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Charts Section
@available(iOS 16.0, *)
struct ChartsSection: View {
    let analyticsData: AnalyticsData?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trends")
                .font(.headline)
                .fontWeight(.semibold)
            
            if let data = analyticsData {
                VStack(spacing: 16) {
                    // Weekly Trend Chart
                    WeeklyTrendChart(weeklyTrend: data.trends.weeklyTrend)
                    
                    // Completion Rate Chart
                    CompletionRateChart(completionRateTrend: data.trends.completionRateTrend)
                }
            } else {
                ProgressView("Loading charts...")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
    }
}

// MARK: - Weekly Trend Chart
@available(iOS 16.0, *)
struct WeeklyTrendChart: View {
    let weeklyTrend: [Date: Int]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weekly Activity")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            if #available(iOS 17.0, *) {
                Chart(Array(weeklyTrend.sorted(by: { $0.key < $1.key })), id: \.key) { item in
                    BarMark(
                        x: .value("Week", item.key, unit: .weekOfYear),
                        y: .value("Sessions", item.value)
                    )
                    .foregroundStyle(Color.blue.gradient)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .weekOfYear)) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
            } else {
                Text("Charts require iOS 17.0+")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(height: 200)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Completion Rate Chart
@available(iOS 16.0, *)
struct CompletionRateChart: View {
    let completionRateTrend: [Date: Double]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Completion Rate Trend")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            if #available(iOS 17.0, *) {
                Chart(Array(completionRateTrend.sorted(by: { $0.key < $1.key })), id: \.key) { item in
                    LineMark(
                        x: .value("Week", item.key, unit: .weekOfYear),
                        y: .value("Rate", item.value * 100)
                    )
                    .foregroundStyle(Color.green.gradient)
                    .interpolationMethod(.catmullRom)
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
            } else {
                Text("Charts require iOS 17.0+")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(height: 200)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Detailed Analytics View
@available(iOS 16.0, *)
struct DetailedAnalyticsView: View {
    let analyticsData: AnalyticsData?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let data = analyticsData {
                        // Detailed statistics
                        DetailedStatisticsView(analyticsData: data)
                    } else {
                        ProgressView("Loading detailed analytics...")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("Detailed Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

// MARK: - Detailed Statistics View
@available(iOS 16.0, *)
struct DetailedStatisticsView: View {
    let analyticsData: AnalyticsData
    
    var body: some View {
        VStack(spacing: 20) {
            // Session Statistics
            SessionStatisticsView(stats: analyticsData.sessionStats)
            
            // Device Statistics
            DeviceStatisticsView(stats: analyticsData.deviceStats)
            
            // Intensity Statistics
            IntensityStatisticsView(stats: analyticsData.intensityStats)
            
            // Time Statistics
            TimeStatisticsView(stats: analyticsData.timeStats)
        }
    }
}

// MARK: - Session Statistics View
@available(iOS 16.0, *)
struct SessionStatisticsView: View {
    let stats: SessionStatistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session Statistics")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                StatRow(title: "Total Sessions", value: "\(stats.totalSessions)")
                StatRow(title: "Completed Sessions", value: "\(stats.completedSessions)")
                StatRow(title: "Completion Rate", value: "\(Int(stats.completionRate * 100))%")
                StatRow(title: "Average Duration", value: formatDuration(stats.averageDuration))
                StatRow(title: "Total Duration", value: formatDuration(stats.totalDuration))
                StatRow(title: "Current Streak", value: "\(stats.currentStreak) days")
                StatRow(title: "Longest Streak", value: "\(stats.longestStreak) days")
                StatRow(title: "Best Week", value: "\(stats.bestWeek) sessions")
                StatRow(title: "Best Month", value: "\(stats.bestMonth) sessions")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        return "\(hours)h \(minutes)m"
    }
}

// MARK: - Stat Row
@available(iOS 16.0, *)
struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Device Statistics View
@available(iOS 16.0, *)
struct DeviceStatisticsView: View {
    let stats: DeviceStatistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Device Statistics")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                if let mostUsed = stats.mostUsedDevice {
                    StatRow(title: "Most Used Device", value: mostUsed.displayName)
                }
                if let leastUsed = stats.leastUsedDevice {
                    StatRow(title: "Least Used Device", value: leastUsed.displayName)
                }
                
                ForEach(Array(DeviceType.allCases), id: \.self) { device in
                    if let successRate = stats.deviceSuccessRates[device] {
                        StatRow(title: "\(device.displayName) Success Rate", value: "\(Int(successRate * 100))%")
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Intensity Statistics View
@available(iOS 16.0, *)
struct IntensityStatisticsView: View {
    let stats: IntensityStatistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Intensity Statistics")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                if let mostUsed = stats.mostUsedIntensity {
                    StatRow(title: "Most Used Intensity", value: mostUsed.displayName)
                }
                if let leastUsed = stats.leastUsedIntensity {
                    StatRow(title: "Least Used Intensity", value: leastUsed.displayName)
                }
                
                ForEach(IntensityLevel.allCases, id: \.self) { intensity in
                    if let successRate = stats.intensitySuccessRates[intensity] {
                        StatRow(title: "\(intensity.displayName) Success Rate", value: "\(Int(successRate * 100))%")
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Time Statistics View
@available(iOS 16.0, *)
struct TimeStatisticsView: View {
    let stats: TimeStatistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Time Statistics")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                if let peakHour = stats.peakHour {
                    StatRow(title: "Peak Hour", value: "\(peakHour):00")
                }
                if let peakDay = stats.peakDay {
                    StatRow(title: "Peak Day", value: dayName(for: peakDay))
                }
                StatRow(title: "Average Sessions/Day", value: String(format: "%.1f", stats.averageSessionsPerDay))
                StatRow(title: "Average Sessions/Week", value: String(format: "%.1f", stats.averageSessionsPerWeek))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func dayName(for dayNumber: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.weekdaySymbols[dayNumber - 1]
    }
}

@available(iOS 16.0, *)
#Preview {
    AnalyticsDashboardView()
} 