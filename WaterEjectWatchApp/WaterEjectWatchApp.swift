import SwiftUI

#if os(watchOS)
@main
struct WaterEjectWatchApp: App {
    var body: some Scene {
        WindowGroup {
            WatchMainView()
        }
    }
}
#endif

#if os(watchOS)
struct WatchMainView: View {
    @StateObject private var waterEjectionService = WaterEjectionService.shared
                @State private var selectedDevice: WatchDeviceType = .applewatch
            @State private var selectedIntensity: WatchIntensityLevel = .medium
    @State private var isPremium = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "drop.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text("Water Eject")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    
                    // Status
                    if waterEjectionService.isPlaying {
                        VStack(spacing: 8) {
                            Text("Ejecting...")
                                .font(.caption)
                                .foregroundColor(.green)
                            
                            Text("\(Int(waterEjectionService.currentTime))s")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Button("Stop") {
                                waterEjectionService.stopEjection()
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                        }
                    } else {
                        // Device Selection
                        VStack(spacing: 8) {
                            Text("Device")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Picker("Device", selection: $selectedDevice) {
                                ForEach(WatchDeviceType.allCases, id: \.self) { device in
                                    Text(device.displayName).tag(device)
                                }
                            }
                            .pickerStyle(.wheel)
                        }
                        
                        // Intensity Selection
                        VStack(spacing: 8) {
                            Text("Intensity")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Picker("Intensity", selection: $selectedIntensity) {
                                ForEach(WatchIntensityLevel.allCases, id: \.self) { intensity in
                                    Text(intensity.displayName).tag(intensity)
                                }
                            }
                            .pickerStyle(.wheel)
                        }
                        
                        // Start Button
                        Button("Start Ejection") {
                            waterEjectionService.startEjection(
                                device: selectedDevice,
                                intensity: selectedIntensity
                            )
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(waterEjectionService.isPlaying)
                    }
                    
                    // Premium Notice
                    if !isPremium {
                        VStack(spacing: 4) {
                            Image(systemName: "crown.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                            
                            Text("Upgrade to Premium")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding()
            }
            .navigationTitle("Water Eject")
        }
        .onAppear {
            loadPremiumStatus()
        }
    }
    
    private func loadPremiumStatus() {
        let userDefaults = UserDefaults(suiteName: "group.com.infinitumimagery.watereject")
        isPremium = userDefaults?.bool(forKey: "isPremium") ?? false
    }
}
#endif

#if os(watchOS)
#Preview {
    WatchMainView()
}
#endif 