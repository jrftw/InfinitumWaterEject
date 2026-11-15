import SwiftUI
import AppIntents

@available(iOS 16.0, *)
struct MainEjectionView: View {
    @StateObject private var audio = WaterEjectionService.shared
    @StateObject private var purchases = SubscriptionService.shared
    @StateObject private var ads = AdMobService.shared
    @Environment(\.appTheme) var theme: HolidayTheme
    @AppStorage("useCustomIntensity") private var usingCustom = false
    @AppStorage("selectedEjectionIntensity") private var intensityRaw = IntensityLevel.medium.rawValue
    @State private var showIntensity = false
    @State private var showTips = false
    @State private var showPremium = false
    @State private var showCompletion = false
    private var intensity: IntensityLevel { IntensityLevel(rawValue: intensityRaw) ?? .medium }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: audio.isPlaying ? "waveform" : "drop.circle.fill")
                        .font(.system(size: 72)).foregroundStyle(theme.primaryColor).accessibilityHidden(true)
                    Text(audio.isPlaying ? "Sound in progress" : "Clearer sound starts here")
                        .font(.largeTitle.bold()).multilineTextAlignment(.center)
                    Text("Place this device speaker-side down. Start at a comfortable volume.")
                        .foregroundStyle(.secondary).multilineTextAlignment(.center)
                    if audio.isPlaying {
                        if audio.isRealtimeMode { RealtimeAdjustmentView(waterEjectionService: audio) }
                        else { TimerDisplayView(currentTime: audio.currentTime, totalDuration: audio.totalDuration) }
                        Button(role: .destructive) { audio.stopEjection() } label: {
                            Label("Stop audio", systemImage: "stop.fill").frame(maxWidth: .infinity).padding(.vertical, 8)
                        }.buttonStyle(.borderedProminent).tint(.red)
                        if !audio.isSpeakerTest {
                            Button("Finish session early") { audio.completeEjection() }.buttonStyle(.bordered)
                        }
                    } else {
                        Button { showIntensity = true } label: {
                            HStack {
                                Label("Cycle settings", systemImage: "slider.horizontal.3")
                                Spacer()
                                Text(usingCustom ? "Custom" : intensity.displayName.capitalized).foregroundStyle(.secondary)
                                Image(systemName: "chevron.right")
                            }.padding().background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                        }.buttonStyle(.plain)
                        Button {
                            showCompletion = false
                            audio.startEjection(device: UIDevice.current.userInterfaceIdiom == .pad ? .ipad : .iphone, intensity: intensity)
                        } label: {
                            Label("Start Water Ejection", systemImage: "play.fill").font(.headline)
                                .frame(maxWidth: .infinity).padding(.vertical, 12)
                        }.buttonStyle(.borderedProminent).tint(theme.primaryColor)
                            .disabled(ads.isPresenting)
                        if showCompletion {
                            VStack(alignment: .leading, spacing: 10) {
                                Label("Session finished", systemImage: "checkmark.circle.fill").font(.headline).foregroundStyle(.green)
                                Text("Listen to your speaker and compare. A finished cycle does not confirm that your device is dry or repaired.")
                                    .font(.subheadline).foregroundStyle(.secondary)
                                Button("Open speaker test") { AppNavigation.shared.route("tools") }
                            }.padding().background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                        }
                        HStack {
                            Button { showTips = true } label: { Label("Safety tips", systemImage: "lightbulb") }
                            Spacer()
                            Button { AppNavigation.shared.route("tools") } label: { Label("Speaker tools", systemImage: "waveform") }
                        }.buttonStyle(.bordered)
                        Text("Audio plays through this device only. Disconnect headphones and Bluetooth. This app cannot repair damage or measure dryness.")
                            .font(.footnote).foregroundStyle(.secondary)
                        if !purchases.isPremium { PremiumBannerView { showPremium = true } }
                        ShortcutsLink().shortcutsLinkStyle(.automatic)
                        ConditionalBannerAdView(adUnitId: ads.getBannerAdUnitId())
                    }
                }.padding(24).frame(maxWidth: 600).frame(maxWidth: .infinity)
            }.background(Color(.systemGroupedBackground))
                .navigationTitle("Water Eject").navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $showIntensity) {
                    IntensityPickerView(selectedIntensity: Binding(get: { intensity }, set: { intensityRaw = $0.rawValue }))
                }
                .sheet(isPresented: $showTips) { TipsView() }
                .sheet(isPresented: $showPremium) { PremiumOfferView() }
                .alert("Audio unavailable", isPresented: Binding(get: { audio.errorMessage != nil }, set: { if !$0 { audio.errorMessage = nil } })) {
                    Button("OK") { audio.errorMessage = nil }
                } message: { Text(audio.errorMessage ?? "") }
                .onChange(of: audio.completedSessionID) { id in
                    guard id != nil else { return }
                    showCompletion = true
                    if audio.lastCompletedDuration >= 25 { ads.sessionCompleted() }
                }
        }
    }
}

@available(iOS 16.0, *)
struct TimerDisplayView: View {
    let currentTime: TimeInterval
    let totalDuration: TimeInterval
    private var progress: Double { totalDuration > 0 ? min(1, max(0, currentTime / totalDuration)) : 0 }
    var body: some View {
        VStack(spacing: 16) {
            Text(Duration.seconds(max(0, totalDuration - currentTime)).formatted(.time(pattern: .minuteSecond)))
                .font(.system(size: 48, weight: .bold, design: .rounded)).monospacedDigit()
                .accessibilityLabel("Time remaining")
            ProgressView(value: progress).accessibilityLabel("Cycle progress")
            Text("\(Int(progress * 100))% complete").font(.caption).foregroundStyle(.secondary)
        }.padding(24).background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
    }
}
