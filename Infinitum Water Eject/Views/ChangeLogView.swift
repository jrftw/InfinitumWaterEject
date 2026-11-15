import SwiftUI

struct AppRelease: Identifiable {
    let version: String
    let title: String
    let changes: [String]
    var id: String { version }

    // Describe shipped behavior, rather than internal implementation or submission builds.
    static let history: [AppRelease] = [
        .init(version: "1.0.3", title: "A simpler everyday experience", changes: [
            "Find your tools faster with four clear tabs: Eject, Tools, Activity and Settings.",
            "Explore what changed in every version from Settings > What’s New.",
            "Choose an appearance and seasonal theme that stay selected when you return.",
            "Manage optional reminders with clearer permission feedback.",
            "Share session history or delete it with a clear confirmation.",
            "Enjoy more readable controls, clearer session details and improved navigation."
        ]),
        .init(version: "1.0.2", title: "More ways to reach your speaker tools", changes: [
            "Add Home Screen and Lock Screen widgets for quick access.",
            "Use Siri and Shortcuts to start a cycle, stop audio or open speaker tools.",
            "Try free 10-second speaker tests from 50 to 2,000 Hz.",
            "Remove ads and save custom test presets with optional lifetime Premium.",
            "Where available, watch an optional video to unlock preset saving for 30 minutes.",
            "Improved session timing, audio interruptions, purchase restoration and safety guidance."
        ]),
        .init(version: "1.0.1", title: "A smoother, more personal app", changes: [
            "Refined appearance options and seasonal themes.",
            "Improved session statistics and compatibility.",
            "Updated the advertising-permission experience and fixed stability issues."
        ]),
        .init(version: "1.0.0", title: "Welcome to Water Eject", changes: [
            "Play timed tones with adjustable cycle settings.",
            "Review session history stored on your device.",
            "Choose an appearance, set optional reminders and find help and safety tips."
        ])
    ]
}

struct ChangeLogView: View {
    private var currentVersion: String { Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.3" }
    var body: some View {
        List {
            Section {
                Label("Made for quicker access, clearer controls and useful speaker tools.", systemImage: "sparkles")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
            ForEach(AppRelease.history) { release in
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(release.title).font(.title3.bold())
                        ForEach(release.changes, id: \.self) { change in
                            Label { Text(change).fixedSize(horizontal: false, vertical: true) } icon: {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(.blue)
                            }.font(.body)
                        }
                    }.padding(.vertical, 8)
                } header: {
                    Text("Version \(release.version)\(release.version == currentVersion ? " · This version" : "")")
                }
            }
        }.navigationTitle("What’s New").navigationBarTitleDisplayMode(.inline)
    }
}
