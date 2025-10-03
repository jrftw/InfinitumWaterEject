/*
 * ============================================================================
 * INFINITUM WATER EJECT - ACHIEVEMENTS VIEW
 * ============================================================================
 * 
 * FILE: AchievementsView.swift
 * PURPOSE: Displays user achievements, progress, and statistics
 * AUTHOR: Kevin Doyle Jr.
 * CREATED: [1/15/2025]
 * LAST MODIFIED: [1/15/2025]
 *
 * DESCRIPTION:
 * This file contains the achievements view implementation for displaying
 * user accomplishments, progress tracking, and gamification elements.
 * 
 * ============================================================================
 */

import SwiftUI

@available(iOS 16.0, *)
struct AchievementsView: View {
    @StateObject private var achievementService = AchievementService.shared
    @State private var selectedRarity: AchievementRarity?
    @State private var showingStats = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Achievement Stats Card
                    AchievementStatsCard(stats: achievementService.getAchievementStats())
                        .onTapGesture {
                            showingStats = true
                        }
                    
                    // Recently Unlocked Achievements
                    if !achievementService.recentlyUnlocked.isEmpty {
                        RecentlyUnlockedSection(achievements: achievementService.recentlyUnlocked)
                    }
                    
                    // Rarity Filter
                    RarityFilterView(selectedRarity: $selectedRarity)
                    
                    // Achievements Grid
                    AchievementsGridView(
                        achievements: achievementService.getAllAchievementsWithProgress(),
                        selectedRarity: selectedRarity
                    )
                }
                .padding()
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingStats) {
                AchievementStatsView(stats: achievementService.getAchievementStats())
            }
        }
    }
}

// MARK: - Achievement Stats Card
@available(iOS 16.0, *)
struct AchievementStatsCard: View {
    let stats: AchievementStats
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Progress")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("\(stats.unlockedCount) of \(stats.totalAchievements) unlocked")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: stats.completionRate)
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.0), value: stats.completionRate)
                    
                    Text("\(stats.completionPercentage)%")
                        .font(.caption)
                        .fontWeight(.bold)
                }
            }
            
            // Rarity Progress
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
                ForEach(AchievementRarity.allCases, id: \.self) { rarity in
                    RarityProgressView(
                        rarity: rarity,
                        stats: stats.rarityStats.first { $0.0 == rarity }
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

// MARK: - Rarity Progress View
@available(iOS 16.0, *)
struct RarityProgressView: View {
    let rarity: AchievementRarity
    let stats: (AchievementRarity, Int, Int)?
    
    var body: some View {
        VStack(spacing: 4) {
            Text(rarity.displayName)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(rarity.color)
            
            if let stats = stats {
                Text("\(stats.1)/\(stats.2)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                Text("0/0")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Recently Unlocked Section
@available(iOS 16.0, *)
struct RecentlyUnlockedSection: View {
    let achievements: [AchievementType]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recently Unlocked")
                .font(.headline)
                .fontWeight(.semibold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(achievements, id: \.self) { achievement in
                        RecentlyUnlockedCard(achievement: achievement)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Recently Unlocked Card
@available(iOS 16.0, *)
struct RecentlyUnlockedCard: View {
    let achievement: AchievementType
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(achievement.color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(achievement.color)
            }
            
            Text(achievement.title)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 80)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Rarity Filter View
@available(iOS 16.0, *)
struct RarityFilterView: View {
    @Binding var selectedRarity: AchievementRarity?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: "All",
                    isSelected: selectedRarity == nil,
                    color: .blue
                ) {
                    selectedRarity = nil
                }
                
                ForEach(AchievementRarity.allCases, id: \.self) { rarity in
                    FilterChip(
                        title: rarity.displayName,
                        isSelected: selectedRarity == rarity,
                        color: rarity.color
                    ) {
                        selectedRarity = rarity
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Filter Chip
@available(iOS 16.0, *)
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color : color.opacity(0.1))
                .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Achievements Grid View
@available(iOS 16.0, *)
struct AchievementsGridView: View {
    let achievements: [(AchievementType, Double, Bool)]
    let selectedRarity: AchievementRarity?
    
    private var filteredAchievements: [(AchievementType, Double, Bool)] {
        if let rarity = selectedRarity {
            return achievements.filter { $0.0.rarity == rarity }
        }
        return achievements
    }
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
            ForEach(filteredAchievements, id: \.0) { achievement, progress, isUnlocked in
                AchievementCard(
                    achievement: achievement,
                    progress: progress,
                    isUnlocked: isUnlocked
                )
            }
        }
    }
}

// MARK: - Achievement Card
@available(iOS 16.0, *)
struct AchievementCard: View {
    let achievement: AchievementType
    let progress: Double
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon and Progress
            ZStack {
                Circle()
                    .fill(achievement.color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                if isUnlocked {
                    Image(systemName: achievement.icon)
                        .font(.title)
                        .foregroundColor(achievement.color)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                
                // Progress Ring
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                    .frame(width: 70, height: 70)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(achievement.color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(-90))
            }
            
            // Title and Description
            VStack(spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            
            // Rarity Badge
            HStack {
                Circle()
                    .fill(achievement.rarity.color)
                    .frame(width: 8, height: 8)
                
                Text(achievement.rarity.displayName)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(achievement.rarity.color)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .opacity(isUnlocked ? 1.0 : 0.7)
    }
}

// MARK: - Achievement Stats View
@available(iOS 16.0, *)
struct AchievementStatsView: View {
    let stats: AchievementStats
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Overall Progress
                    VStack(spacing: 16) {
                        Text("Overall Progress")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 12)
                                .frame(width: 120, height: 120)
                            
                            Circle()
                                .trim(from: 0, to: stats.completionRate)
                                .stroke(Color.blue, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                                .frame(width: 120, height: 120)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 1.0), value: stats.completionRate)
                            
                            VStack {
                                Text("\(stats.completionPercentage)%")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Text("Complete")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Rarity Breakdown
                    VStack(spacing: 16) {
                        Text("Rarity Breakdown")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 12) {
                            ForEach(stats.rarityStats, id: \.0) { rarity, unlocked, total in
                                RarityProgressRow(
                                    rarity: rarity,
                                    unlocked: unlocked,
                                    total: total
                                )
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

// MARK: - Rarity Progress Row
@available(iOS 16.0, *)
struct RarityProgressRow: View {
    let rarity: AchievementRarity
    let unlocked: Int
    let total: Int
    
    private var progress: Double {
        return total > 0 ? Double(unlocked) / Double(total) : 0
    }
    
    var body: some View {
        HStack {
            Circle()
                .fill(rarity.color)
                .frame(width: 12, height: 12)
            
            Text(rarity.displayName)
                .font(.body)
                .fontWeight(.medium)
            
            Spacer()
            
            Text("\(unlocked)/\(total)")
                .font(.body)
                .foregroundColor(.secondary)
            
            ProgressView(value: progress)
                .frame(width: 60)
        }
    }
}

@available(iOS 16.0, *)
#Preview {
    AchievementsView()
} 