//
//  WaterEjectWidgetExtension.swift
//  WaterEjectWidgetExtension
//
//  Created by Kevin Doyle Jr. on 7/7/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), sessionCount: 0, weeklySessions: 0, completionRate: 0, averageDuration: 0, lastSessionDate: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = getCurrentEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline with current data and future updates
        let currentDate = Date()
        for hourOffset in 0 ..< 24 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = getCurrentEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func getCurrentEntry(date: Date = Date()) -> SimpleEntry {
        // Get data from UserDefaults (shared with main app)
        let userDefaults = UserDefaults(suiteName: "group.com.infinitumimagery.watereject")
        
        let sessionCount = userDefaults?.integer(forKey: "totalSessions") ?? 0
        let weeklySessions = userDefaults?.integer(forKey: "weeklySessions") ?? 0
        let completionRate = userDefaults?.double(forKey: "completionRate") ?? 0
        let averageDuration = userDefaults?.double(forKey: "averageDuration") ?? 0
        let lastSessionDate = userDefaults?.object(forKey: "lastSessionDate") as? Date ?? Date()
        
        return SimpleEntry(
            date: date,
            sessionCount: sessionCount,
            weeklySessions: weeklySessions,
            completionRate: completionRate,
            averageDuration: averageDuration,
            lastSessionDate: lastSessionDate
        )
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let sessionCount: Int
    let weeklySessions: Int
    let completionRate: Double
    let averageDuration: Double
    let lastSessionDate: Date
}

struct WaterEjectWidgetExtensionEntryView : View {
    var entry: SimpleEntry
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
    var entry: SimpleEntry
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "drop.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Text("\(entry.sessionCount)")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            Text("Sessions")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(entry.lastSessionDate, style: .relative)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct MediumWidgetView: View {
    var entry: SimpleEntry
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "drop.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("Water Eject")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total: \(entry.sessionCount)")
                        .font(.caption)
                    
                    Text("This Week: \(entry.weeklySessions)")
                        .font(.caption)
                    
                    Text("Last: \(entry.lastSessionDate, style: .relative)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                Text("\(entry.completionRate, specifier: "%.0f")%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text("Success")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

struct WaterEjectWidgetExtension: Widget {
    let kind: String = "WaterEjectWidgetExtension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WaterEjectWidgetExtensionEntryView(entry: entry)
        }
        .configurationDisplayName("Water & Dust Eject")
        .description("Quick access to water and dust ejection for your devices")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
