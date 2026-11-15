import SwiftUI

struct TonePreset: Codable, Identifiable {
    var id = UUID()
    var name: String
    var frequency: Double
}

@available(iOS 16.0, *)
struct SpeakerToolsView: View {
    @StateObject private var audio = WaterEjectionService.shared
    @StateObject private var purchases = SubscriptionService.shared
    @StateObject private var ads = AdMobService.shared
    @AppStorage("speakerTestFrequency") private var frequency = 165.0
    @AppStorage("tonePresets") private var presetData = Data()
    @State private var name = ""
    @State private var showPremium = false
    private var presets: [TonePreset] { (try? JSONDecoder().decode([TonePreset].self, from: presetData)) ?? [] }
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Listen, compare and find your preferred tone.").font(.headline)
                    Text("Use this device’s built-in speaker. Start at a low system volume and keep the device away from your ears. A tone test cannot diagnose damage or confirm that water is gone.")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                Section("Speaker test") {
                    Text("\(Int(frequency)) Hz").font(.title.monospacedDigit()).accessibilityLabel("Frequency, \(Int(frequency)) hertz")
                    Slider(value: $frequency, in: 50...2000, step: 1).accessibilityLabel("Test frequency")
                        .disabled(audio.isPlaying)
                    HStack {
                        ForEach([165.0, 440, 1000], id: \.self) { hz in
                            Button("\(Int(hz)) Hz") { frequency = hz }.buttonStyle(.bordered).disabled(audio.isPlaying)
                        }
                    }
                    if audio.isPlaying {
                        Button("Stop audio", role: .destructive) { audio.stopEjection() }
                    } else {
                        Button { audio.startSpeakerTest(frequency: frequency) } label: {
                            Label("Play 10-second test", systemImage: "play.fill")
                        }
                    }
                }
                Section("Saved presets") {
                    if purchases.isPremium || ads.toolsUnlocked {
                        TextField("Preset name", text: $name).accessibilityLabel("Preset name")
                        Button("Save current frequency") {
                            guard purchases.isPremium || ads.toolsUnlocked else { return }
                            var updated = presets
                            updated.append(TonePreset(name: String(name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(40)), frequency: frequency))
                            presetData = (try? JSONEncoder().encode(updated)) ?? presetData
                            name = ""; GrowthMetrics.shared.record("preset_saved")
                        }.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || presets.count >= 20)
                        if ads.toolsUnlocked && !purchases.isPremium {
                            Text("Preset saving unlocked for 30 minutes. Your saved presets remain available afterward.").font(.caption)
                        }
                    } else {
                        Button("Unlock preset saving") { showPremium = true }
                        if ads.rewardedReady {
                            Button("Watch a video · unlock saving for 30 minutes") { ads.unlockToolsWithReward() }
                                .disabled(audio.isPlaying || ads.isPresenting)
                        }
                    }
                    ForEach(presets) { preset in
                        Button { frequency = min(2000, max(50, preset.frequency)) } label: {
                            HStack { Text(preset.name); Spacer(); Text("\(Int(preset.frequency)) Hz").foregroundStyle(.secondary) }
                        }.disabled(audio.isPlaying)
                    }.onDelete { offsets in
                        var updated = presets; updated.remove(atOffsets: offsets)
                        presetData = (try? JSONEncoder().encode(updated)) ?? presetData
                    }
                }
                Section("Widgets, Siri & Shortcuts") {
                    Text("Add Water Eject from your Home Screen or Lock Screen widget gallery. In Shortcuts, search for Water Eject to add Start Water Ejection, Stop Audio or Open Speaker Tools.")
                    Text("Try: “Siri, start water ejection with Infinitum Water Eject.” Siri opens the app before playing audio.")
                }
                Section { ConditionalBannerAdView(adUnitId: ads.getBannerAdUnitId()) }
            }.navigationTitle("Speaker Tools")
                .sheet(isPresented: $showPremium) { PremiumOfferView() }
                .alert("Audio", isPresented: Binding(get: { audio.errorMessage != nil }, set: { if !$0 { audio.errorMessage = nil } })) {
                    Button("OK") { audio.errorMessage = nil }
                } message: { Text(audio.errorMessage ?? "") }
                .alert("Video", isPresented: Binding(get: { ads.message != nil }, set: { if !$0 { ads.message = nil } })) {
                    Button("OK") { ads.message = nil }
                } message: { Text(ads.message ?? "") }
        }
    }
}
