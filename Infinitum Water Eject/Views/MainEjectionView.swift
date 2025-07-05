import SwiftUI

struct MainEjectionView: View {
    @StateObject private var waterEjectionService = WaterEjectionService.shared
    // @StateObject private var subscriptionService = SubscriptionService.shared
    
    @State private var selectedDevice: DeviceType = .iphone
    @State private var selectedIntensity: IntensityLevel = .medium
    @State private var showingDevicePicker = false
    @State private var showingIntensityPicker = false
    @State private var showingTips = false
    // @State private var showingPremiumOffer = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 8) {
                    Text("Infinitum Water Eject")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Protect your devices with sound frequencies")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Timer Display
                if waterEjectionService.isPlaying {
                    TimerDisplayView(
                        currentTime: waterEjectionService.currentTime,
                        totalDuration: waterEjectionService.totalDuration
                    )
                } else {
                    // Device and Intensity Selection
                    VStack(spacing: 24) {
                        // Device Selection
                        VStack(spacing: 12) {
                            Text("Select Device")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Button(action: { showingDevicePicker = true }) {
                                HStack {
                                    Image(systemName: selectedDevice.icon)
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                    
                                    Text(selectedDevice.displayName)
                                        .font(.body)
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // Intensity Selection
                        VStack(spacing: 12) {
                            Text("Select Intensity")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Button(action: { showingIntensityPicker = true }) {
                                HStack {
                                    // Check if custom intensity is being used
                                    let useCustomIntensity = UserDefaults.standard.bool(forKey: "useCustomIntensity")
                                    let customIntensityValue = UserDefaults.standard.double(forKey: "customIntensityValue")
                                    let customDuration = UserDefaults.standard.double(forKey: "customDuration")
                                    
                                    if useCustomIntensity && customIntensityValue > 0 {
                                        // Show custom intensity
                                        Image(systemName: "slider.horizontal.3")
                                            .font(.title2)
                                            .foregroundColor(.blue)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Custom: \(Int(customIntensityValue))%")
                                                .font(.body)
                                                .fontWeight(.medium)
                                            
                                            Text("\(Int(customDuration)) seconds")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    } else {
                                        // Show preset intensity
                                        Image(systemName: selectedIntensity.icon)
                                            .font(.title2)
                                            .foregroundColor(selectedIntensity.color)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(selectedIntensity.displayName)
                                                .font(.body)
                                                .fontWeight(.medium)
                                            
                                            Text("\(Int(selectedIntensity.duration)) seconds")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                // Control Buttons
                VStack(spacing: 16) {
                    if waterEjectionService.isPlaying {
                        // Stop Button
                        Button(action: waterEjectionService.stopEjection) {
                            HStack {
                                Image(systemName: "stop.fill")
                                Text("Stop Ejection")
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                        }
                        
                        // Complete Button
                        Button(action: waterEjectionService.completeEjection) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Complete Session")
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                        }
                    } else {
                        // Start Button
                        Button(action: startEjection) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start Water Ejection")
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        .disabled(waterEjectionService.isPlaying)
                    }
                }
                
                // Tips Button
                if !waterEjectionService.isPlaying {
                    Button(action: { showingTips = true }) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                            Text("Safety Tips")
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                
                // Premium Banner (if not premium) - COMMENTED OUT FOR NOW
                /*
                if !subscriptionService.isPremium {
                    PremiumBannerView {
                        showingPremiumOffer = true
                    }
                }
                */
                
                Spacer()
            }
            .padding()
            .navigationTitle("Water Eject")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingDevicePicker) {
                DevicePickerView(selectedDevice: $selectedDevice)
            }
            .sheet(isPresented: $showingIntensityPicker) {
                IntensityPickerView(selectedIntensity: $selectedIntensity)
            }
            .sheet(isPresented: $showingTips) {
                TipsView()
            }
            // .sheet(isPresented: $showingPremiumOffer) {
            //     PremiumOfferView()
            // }
        }
    }
    
    private func startEjection() {
        waterEjectionService.startEjection(device: selectedDevice, intensity: selectedIntensity)
    }
}

struct TimerDisplayView: View {
    let currentTime: TimeInterval
    let totalDuration: TimeInterval
    
    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return currentTime / totalDuration
    }
    
    var remainingTime: TimeInterval {
        return max(0, totalDuration - currentTime)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress Circle
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 8)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)
                
                VStack(spacing: 4) {
                    Text(formatTime(remainingTime))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress Bar
            VStack(spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// Premium Banner View - COMMENTED OUT FOR NOW
/*
struct PremiumBannerView: View {
    let onUpgrade: () -> Void
    
    var body: some View {
        Button(action: onUpgrade) {
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundColor(.yellow)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Upgrade to Premium")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("Unlimited sessions & advanced features")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
*/

#Preview {
    MainEjectionView()
} 