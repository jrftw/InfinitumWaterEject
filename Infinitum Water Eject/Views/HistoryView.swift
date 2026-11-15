import SwiftUI

struct HistoryView: View {
    @ObservedObject private var data = CoreDataService.shared
    @State private var filter: HistoryFilter = .all
    @State private var pendingDelete: WaterEjectionSession?
    private var sessions: [WaterEjectionSession] { filter.apply(to: data.getWaterEjectionSessions()) }
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Show sessions", selection: $filter) {
                        ForEach(HistoryFilter.allCases, id: \.self) { Text($0.displayName).tag($0) }
                    }
                }
                if sessions.isEmpty {
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Label(filter == .all ? "Your sessions will appear here" : "No sessions in this view", systemImage: "clock.arrow.circlepath").font(.headline)
                            Text("Completed and stopped cycles are saved on this device. Speaker tests are not added to history.").foregroundStyle(.secondary)
                            Button("Open Water Eject") { AppNavigation.shared.route("eject") }
                        }.padding(.vertical, 12)
                    }
                } else {
                    Section("In this view") {
                        LabeledContent("Sessions", value: "\(sessions.count)")
                        LabeledContent("Completed", value: "\(sessions.filter(\.isCompleted).count)")
                        LabeledContent("Audio time", value: Duration.seconds(sessions.reduce(0) { $0 + $1.duration }).formatted(.time(pattern: .minuteSecond)))
                    }
                    Section("Session history") {
                        ForEach(sessions) { session in
                            VStack(alignment: .leading, spacing: 8) {
                                ViewThatFits(in: .horizontal) {
                                    HStack { sessionTitle(session); Spacer(); status(session) }
                                    VStack(alignment: .leading, spacing: 8) { sessionTitle(session); status(session) }
                                }
                                Text(session.startTime, format: .dateTime.month().day().year().hour().minute()).font(.subheadline).foregroundStyle(.secondary)
                                Text("\(session.intensityLevel.displayName) · \(Duration.seconds(session.duration).formatted(.time(pattern: .minuteSecond)))")
                                    .font(.subheadline).foregroundStyle(.secondary)
                            }.padding(.vertical, 6)
                                .swipeActions { Button("Delete", role: .destructive) { pendingDelete = session } }
                        }
                    }
                }
                Section {
                    Text("Completion describes the session timer. It does not measure speaker health or dryness.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                Section { ConditionalBannerAdView(adUnitId: AdMobService.shared.getBannerAdUnitId()) }
            }.navigationTitle("Activity")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink { AnalyticsDashboardView() } label: { Label("Usage summary", systemImage: "chart.bar") }
                    }
                }
                .confirmationDialog("Delete this session?", isPresented: Binding(get: { pendingDelete != nil }, set: { if !$0 { pendingDelete = nil } }), titleVisibility: .visible) {
                    Button("Delete session", role: .destructive) {
                        if let session = pendingDelete { data.deleteWaterEjectionSession(session) }; pendingDelete = nil
                    }
                }
        }
    }
    private func sessionTitle(_ session: WaterEjectionSession) -> some View {
        Label(session.deviceType.displayName, systemImage: session.deviceType.icon).font(.headline)
    }
    private func status(_ session: WaterEjectionSession) -> some View {
        Text(session.isCompleted ? "Completed" : "Stopped").font(.caption.bold())
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background((session.isCompleted ? Color.green : Color.orange).opacity(0.12), in: Capsule())
    }
}

enum HistoryFilter: CaseIterable {
    case all, completed, incomplete, today, week, month
    var displayName: String {
        switch self {
        case .all: return "All sessions"
        case .completed: return "Completed"
        case .incomplete: return "Stopped"
        case .today: return "Today"
        case .week: return "Last 7 days"
        case .month: return "Last 30 days"
        }
    }
    func apply(to sessions: [WaterEjectionSession], now: Date = Date(), calendar: Calendar = .current) -> [WaterEjectionSession] {
        sessions.filter { session in
            switch self {
            case .all: return true
            case .completed: return session.isCompleted
            case .incomplete: return !session.isCompleted
            case .today: return calendar.isDate(session.startTime, inSameDayAs: now)
            case .week, .month:
                let start = calendar.date(byAdding: .day, value: self == .week ? -7 : -30, to: now) ?? now
                return session.startTime >= start && session.startTime <= now
            }
        }.sorted { $0.startTime > $1.startTime }
    }
}
