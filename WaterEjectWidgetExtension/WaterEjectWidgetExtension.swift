import WidgetKit
import SwiftUI

struct SimpleEntry: TimelineEntry {
    let date: Date
    let sessionCount: Int
    let lastSession: Date?
}
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry { SimpleEntry(date: Date(), sessionCount: 3, lastSession: Date()) }
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) { completion(entry()) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        completion(Timeline(entries: [entry()], policy: .after(Date().addingTimeInterval(1800))))
    }
    private func entry() -> SimpleEntry {
        let defaults = UserDefaults(suiteName: "group.com.infinitumimagery.watereject")
        return SimpleEntry(date: Date(), sessionCount: defaults?.integer(forKey: "totalSessions") ?? 0,
            lastSession: defaults?.object(forKey: "lastSessionDate") as? Date)
    }
}
struct WaterEjectWidgetView: View {
    let entry: SimpleEntry
    @Environment(\.widgetFamily) private var family
    var body: some View {
        Group {
            if family == .accessoryCircular {
                Image(systemName: "drop.fill").font(.title).accessibilityLabel("Start Water Ejection")
            } else if family == .accessoryRectangular {
                VStack(alignment: .leading) {
                    Label("Water Eject", systemImage: "drop.fill").font(.headline)
                    Text("Tap for a 30-second cycle").font(.caption)
                }
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Water Eject", systemImage: "drop.fill").font(.headline)
                    Text("Ready when you need it").font(.subheadline).foregroundStyle(.secondary)
                    if family == .systemMedium {
                        HStack {
                            Link(destination: URL(string: "infinitumwatereject://start")!) { Label("Start 30s", systemImage: "play.fill") }
                            Spacer()
                            Link(destination: URL(string: "infinitumwatereject://tools")!) { Label("Speaker test", systemImage: "waveform") }
                        }.font(.subheadline.bold())
                    } else {
                        Label("Start 30s", systemImage: "play.circle.fill").font(.title3.bold())
                    }
                    Text("\(entry.sessionCount) sessions recorded").font(.caption2).foregroundStyle(.secondary)
                }
            }
        }.widgetURL(URL(string: "infinitumwatereject://start"))
    }
}
struct WaterEjectWidgetExtension: Widget {
    let kind = "WaterEjectWidgetExtension"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOSApplicationExtension 17.0, *) {
                WaterEjectWidgetView(entry: entry).containerBackground(.fill.tertiary, for: .widget)
            } else {
                WaterEjectWidgetView(entry: entry).padding().background(Color(.systemBackground))
            }
        }.configurationDisplayName("Water Eject")
            .description("Open a 30-second cycle or your speaker tools. Audio plays after the app opens.")
            .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}
