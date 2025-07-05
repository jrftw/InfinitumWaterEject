import SwiftUI

struct HistoryView: View {
    @StateObject private var waterEjectionService = WaterEjectionService.shared
    @State private var selectedFilter: HistoryFilter = .all
    @State private var showingStats = false
    
    var filteredSessions: [WaterEjectionSession] {
        let sessions = waterEjectionService.getSessionHistory()
        
        switch selectedFilter {
        case .all:
            return sessions
        case .completed:
            return sessions.filter { $0.isCompleted }
        case .incomplete:
            return sessions.filter { !$0.isCompleted }
        case .today:
            let today = Calendar.current.startOfDay(for: Date())
            return sessions.filter { Calendar.current.isDate($0.startTime, inSameDayAs: today) }
        case .week:
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            return sessions.filter { $0.startTime >= weekAgo }
        case .month:
            let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            return sessions.filter { $0.startTime >= monthAgo }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Picker
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(HistoryFilter.allCases, id: \.self) { filter in
                        Text(filter.displayName).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if filteredSessions.isEmpty {
                    EmptyHistoryView(filter: selectedFilter)
                } else {
                    // Statistics Card
                    StatsCard(stats: waterEjectionService.getSessionStats(), filter: selectedFilter)
                        .padding(.horizontal)
                    
                    // Sessions List
                    List {
                        ForEach(filteredSessions.sorted(by: { $0.startTime > $1.startTime }), id: \.id) { session in
                            SessionRowView(session: session)
                        }
                        .onDelete(perform: deleteSessions)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingStats = true }) {
                        Image(systemName: "chart.bar.fill")
                    }
                }
            }
        }
        .sheet(isPresented: $showingStats) {
            StatisticsView(stats: waterEjectionService.getSessionStats())
        }
    }
    
    private func deleteSessions(offsets: IndexSet) {
        let sessionsToDelete = offsets.map { filteredSessions.sorted(by: { $0.startTime > $1.startTime })[$0] }
        
        for session in sessionsToDelete {
            CoreDataService.shared.deleteWaterEjectionSession(session)
        }
    }
}

struct EmptyHistoryView: View {
    let filter: HistoryFilter
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Sessions Found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(getEmptyMessage())
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func getEmptyMessage() -> String {
        switch filter {
        case .all:
            return "Start your first water ejection session to see it here"
        case .completed:
            return "No completed sessions found. Complete a session to see it here"
        case .incomplete:
            return "No incomplete sessions found"
        case .today:
            return "No sessions today. Start a new session to protect your device"
        case .week:
            return "No sessions in the last 7 days"
        case .month:
            return "No sessions in the last 30 days"
        }
    }
}

struct StatsCard: View {
    let stats: SessionStats
    let filter: HistoryFilter
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Statistics")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(filter.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
            
            HStack(spacing: 20) {
                StatItem(
                    title: "Total",
                    value: "\(stats.totalSessions)",
                    icon: "number.circle.fill",
                    color: .blue
                )
                
                StatItem(
                    title: "Completed",
                    value: "\(stats.completedSessions)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatItem(
                    title: "Success Rate",
                    value: "\(Int(stats.completionRate * 100))%",
                    icon: "percent",
                    color: .orange
                )
            }
            
            HStack(spacing: 20) {
                StatItem(
                    title: "Total Time",
                    value: String(format: "%.1f min", stats.totalDurationMinutes),
                    icon: "clock.fill",
                    color: .purple
                )
                
                StatItem(
                    title: "Avg Duration",
                    value: String(format: "%.1f min", stats.averageDurationMinutes),
                    icon: "timer",
                    color: .red
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SessionRowView: View {
    let session: WaterEjectionSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: session.deviceType.icon)
                    .foregroundColor(.blue)
                    .frame(width: 20)
                
                Text(session.deviceType.displayName)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
                
                StatusBadge(isCompleted: session.isCompleted)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Intensity: \(session.intensityLevel.displayName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Duration: \(formatDuration(session.duration))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatDate(session.startTime))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let endTime = session.endTime {
                        Text(formatTime(session.startTime, endTime))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatTime(_ start: Date, _ end: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
}

struct StatusBadge: View {
    let isCompleted: Bool
    
    var body: some View {
        Text(isCompleted ? "Completed" : "Incomplete")
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isCompleted ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
            .foregroundColor(isCompleted ? .green : .orange)
            .cornerRadius(8)
    }
}

struct StatisticsView: View {
    let stats: SessionStats
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Overview Stats
                    VStack(spacing: 16) {
                        Text("Overview")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                            StatCard(
                                title: "Total Sessions",
                                value: "\(stats.totalSessions)",
                                icon: "number.circle.fill",
                                color: .blue
                            )
                            
                            StatCard(
                                title: "Success Rate",
                                value: "\(Int(stats.completionRate * 100))%",
                                icon: "percent",
                                color: .green
                            )
                            
                            StatCard(
                                title: "Total Time",
                                value: String(format: "%.1f hours", stats.totalDurationMinutes / 60),
                                icon: "clock.fill",
                                color: .purple
                            )
                            
                            StatCard(
                                title: "Avg Duration",
                                value: String(format: "%.1f min", stats.averageDurationMinutes),
                                icon: "timer",
                                color: .orange
                            )
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    
                    // Device Breakdown
                    if !stats.deviceStats.isEmpty {
                        VStack(spacing: 16) {
                            Text("Device Usage")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            ForEach(Array(stats.deviceStats.keys.sorted(by: { stats.deviceStats[$0]! > stats.deviceStats[$1]! })), id: \.self) { device in
                                DeviceStatRow(
                                    device: device,
                                    count: stats.deviceStats[device] ?? 0,
                                    total: stats.totalSessions
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                    }
                    
                    // Intensity Breakdown
                    if !stats.intensityStats.isEmpty {
                        VStack(spacing: 16) {
                            Text("Intensity Usage")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            ForEach(Array(stats.intensityStats.keys.sorted(by: { stats.intensityStats[$0]! > stats.intensityStats[$1]! })), id: \.self) { intensity in
                                IntensityStatRow(
                                    intensity: intensity,
                                    count: stats.intensityStats[intensity] ?? 0,
                                    total: stats.totalSessions
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
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

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct DeviceStatRow: View {
    let device: DeviceType
    let count: Int
    let total: Int
    
    var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total)
    }
    
    var body: some View {
        HStack {
            Image(systemName: device.icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(device.displayName)
                .font(.body)
            
            Spacer()
            
            Text("\(count) (\(Int(percentage * 100))%)")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

struct IntensityStatRow: View {
    let intensity: IntensityLevel
    let count: Int
    let total: Int
    
    var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total)
    }
    
    var body: some View {
        HStack {
            Image(systemName: intensity.icon)
                .foregroundColor(intensity.color)
                .frame(width: 20)
            
            Text(intensity.displayName)
                .font(.body)
            
            Spacer()
            
            Text("\(count) (\(Int(percentage * 100))%)")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

enum HistoryFilter: CaseIterable {
    case all, completed, incomplete, today, week, month
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .completed: return "Completed"
        case .incomplete: return "Incomplete"
        case .today: return "Today"
        case .week: return "Week"
        case .month: return "Month"
        }
    }
}

#Preview {
    HistoryView()
} 