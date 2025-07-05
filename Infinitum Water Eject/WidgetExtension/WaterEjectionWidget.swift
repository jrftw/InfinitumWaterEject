import WidgetKit
import SwiftUI

struct WaterEjectionWidget: Widget {
    let kind: String = "WaterEjectionWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WaterEjectionTimelineProvider()) { entry in
            WaterEjectionWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Infinitum Water Eject")
        .description("Quick access to water ejection for your devices")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct WaterEjectionTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> WaterEjectionEntry {
        WaterEjectionEntry(date: Date(), lastSession: nil, weeklyCount: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (WaterEjectionEntry) -> ()) {
        let entry = WaterEjectionEntry(date: Date(), lastSession: nil, weeklyCount: 3)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let entry = WaterEjectionEntry(date: currentDate, lastSession: nil, weeklyCount: 0)
        
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct WaterEjectionEntry: TimelineEntry {
    let date: Date
    let lastSession: Date?
    let weeklyCount: Int
}

struct WaterEjectionWidgetEntryView: View {
    var entry: WaterEjectionTimelineProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    let entry: WaterEjectionEntry
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "drop.fill")
                .font(.system(size: 30))
                .foregroundColor(.blue)
            
            Text("Infinitum Water Eject")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("\(entry.weeklyCount) sessions")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if let lastSession = entry.lastSession {
                Text("Last: \(lastSession, style: .relative)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .widgetURL(URL(string: "infinitumwatereject://eject"))
    }
}

struct MediumWidgetView: View {
    let entry: WaterEjectionEntry
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "drop.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("Infinitum Water Eject")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("This week: \(entry.weeklyCount) sessions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let lastSession = entry.lastSession {
                        Text("Last session: \(lastSession, style: .relative)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                Button(action: {}) {
                    Image(systemName: "play.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                .widgetURL(URL(string: "infinitumwatereject://eject"))
                
                Text("Quick Start")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// This @main attribute should only be used in the separate widget extension target
// @main
// struct WaterEjectionWidgetBundle: WidgetBundle {
//     var body: some Widget {
//         WaterEjectionWidget()
//     }
// } 