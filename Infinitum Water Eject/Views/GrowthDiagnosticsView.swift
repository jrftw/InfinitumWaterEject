import SwiftUI

@available(iOS 16.0, *)
struct GrowthDiagnosticsView: View {
    @StateObject private var metrics = GrowthMetrics.shared
    @State private var confirmReset = false
    var body: some View {
        Form {
            Section {
                Text("These diagnostics describe this installation only. They do not measure all users, total revenue, or population retention.")
                Toggle("Save diagnostics on this device", isOn: Binding(get: { metrics.enabled }, set: { metrics.enabled = $0 }))
                Text("No diagnostic data is uploaded automatically. Share only if you choose to. Advertising SDK data handling is separate.").font(.footnote).foregroundStyle(.secondary)
            }
            Section("Placement experiment") {
                LabeledContent("This installation", value: metrics.cohort == "banner_only" ? "Banner only" : "After sessions")
                Text("20% of installations keep banners only. Others are eligible for one full-screen ad after every second completed cycle, at least 3 minutes apart, up to 3 per day. No ad interrupts audio or blocks starting a cycle.").font(.footnote)
            }
            Section {
                ShareLink("Share diagnostic report", item: metrics.export)
                Button("Reset diagnostic counters", role: .destructive) { confirmReset = true }
            }
        }.navigationTitle("Diagnostics")
            .confirmationDialog("Clear local diagnostic counters?", isPresented: $confirmReset) {
                Button("Clear counters", role: .destructive) { metrics.reset() }
            }
    }
}
