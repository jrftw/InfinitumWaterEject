import SwiftUI
import Charts

struct AnalyticsDashboardView: View {
    @ObservedObject private var data = CoreDataService.shared
    private var sessions: [WaterEjectionSession] { data.getWaterEjectionSessions() }
    private var days: [Date] {
        let calendar = Calendar.current
        return (0..<7).reversed().compactMap { calendar.date(byAdding: .day, value: -$0, to: calendar.startOfDay(for: Date())) }
    }
    var body: some View {
        List {
            Section("Last 7 days") {
                Chart(days, id: \.self) { day in
                    BarMark(x: .value("Day", day, unit: .day), y: .value("Sessions", sessions.filter { Calendar.current.isDate($0.startTime, inSameDayAs: day) }.count))
                        .foregroundStyle(.blue)
                }.chartYScale(domain: 0...max(1, days.map { day in sessions.filter { Calendar.current.isDate($0.startTime, inSameDayAs: day) }.count }.max() ?? 0))
                    .frame(height: 180)
                    .accessibilityLabel("Daily session count over the last seven days")
            }
            Section("All time on this device") {
                LabeledContent("Sessions", value: "\(sessions.count)")
                LabeledContent("Completed", value: "\(sessions.filter(\.isCompleted).count)")
                LabeledContent("Stopped", value: "\(sessions.filter { !$0.isCompleted }.count)")
                LabeledContent("Audio time", value: Duration.seconds(sessions.reduce(0) { $0 + $1.duration }).formatted(.time(pattern: .minuteSecond)))
            }
            Section {
                Text("These numbers describe your use of the app. They do not measure water removal, device health or repair success. There is no need to run daily cycles or reach a usage target.").foregroundStyle(.secondary)
            }
        }.navigationTitle("Usage summary").navigationBarTitleDisplayMode(.inline)
    }
}
