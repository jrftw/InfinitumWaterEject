import SwiftUI

@available(iOS 16.0, *)
struct MainEjectionView: View {
    @StateObject private var waterEjectionService = WaterEjectionService.shared
    @StateObject private var subscriptionService = SubscriptionService.shared
    @Environment(\.appTheme) var theme: HolidayTheme
    
    @State private var selectedDevice: DeviceType = detectCurrentDevice()
    @State private var selectedIntensity: IntensityLevel = .medium
    @State private var showingDevicePicker = false
    @State private var showingIntensityPicker = false
    @State private var showingTips = false
    @State private var showingPremiumOffer = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text("Infinitum Water Eject")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .minimumScaleFactor(0.8)
                        
                        Text("Protect your devices with sound frequencies")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.9)
                    }
                    .padding(.top, 8)
                    .padding(.horizontal)
                    
                    // Timer Display or Realtime Adjustment
                    if waterEjectionService.isPlaying {
                        if waterEjectionService.isRealtimeMode {
                            RealtimeAdjustmentView(waterEjectionService: waterEjectionService)
                                .padding(.horizontal)
                        } else {
                            TimerDisplayView(
                                currentTime: waterEjectionService.currentTime,
                                totalDuration: waterEjectionService.totalDuration
                            )
                            .padding(.horizontal)
                        }
                    } else {
                        // Device and Intensity Selection
                        VStack(spacing: 20) {
                            // Device Selection
                            VStack(spacing: 12) {
                                Text("Select Device")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Button(action: { showingDevicePicker = true }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: selectedDevice.icon)
                                            .font(.title2)
                                            .foregroundColor(.blue)
                                            .frame(width: 24, height: 24)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(selectedDevice.displayName)
                                                .font(.body)
                                                .fontWeight(.medium)
                                                .foregroundColor(.primary)
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
                            
                            // Intensity Selection
                            VStack(spacing: 12) {
                                Text("Select Intensity")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Button(action: { showingIntensityPicker = true }) {
                                    HStack(spacing: 12) {
                                        // Check if custom intensity is being used
                                        let useCustomIntensity = UserDefaults.standard.bool(forKey: "useCustomIntensity")
                                        let customIntensityValue = UserDefaults.standard.double(forKey: "customIntensityValue")
                                        let customDuration = UserDefaults.standard.double(forKey: "customDuration")
                                        
                                        if useCustomIntensity && customIntensityValue > 0 {
                                            // Show custom intensity
                                            Image(systemName: "slider.horizontal.3")
                                                .font(.title2)
                                                .foregroundColor(.blue)
                                                .frame(width: 24, height: 24)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Custom: \(Int(customIntensityValue))%")
                                                    .font(.body)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.primary)
                                                
                                                Text("\(Int(customDuration)) seconds")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        } else {
                                            // Show preset intensity
                                            Image(systemName: selectedIntensity.icon)
                                                .font(.title2)
                                                .foregroundColor(selectedIntensity.color)
                                                .frame(width: 24, height: 24)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(selectedIntensity.displayName)
                                                    .font(.body)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.primary)
                                                
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
                        .padding(.horizontal)
                    }
                    
                    // Control Buttons
                    VStack(spacing: 12) {
                        if waterEjectionService.isPlaying {
                            // Stop Button
                            Button(action: waterEjectionService.stopEjection) {
                                HStack(spacing: 8) {
                                    Image(systemName: "stop.fill")
                                        .font(.headline)
                                    Text("Stop Ejection")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.red)
                                .cornerRadius(12)
                            }
                            
                            // Complete Button
                            Button(action: waterEjectionService.completeEjection) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.headline)
                                    Text("Complete Session")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.green)
                                .cornerRadius(12)
                            }
                            
                            // Banner Ad under Complete Session button
                            VStack(spacing: 0) {
                                ConditionalBannerAdView(adUnitId: AdMobService.shared.getBannerAdUnitId())
                            }
                            .padding(.top, 12)
                        } else {
                            // Start Button
                            Button(action: startEjection) {
                                HStack(spacing: 8) {
                                    Image(systemName: "play.fill")
                                        .font(.headline)
                                    Text("Start Water & Dust Ejection")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(theme.gradient)
                                .cornerRadius(12)
                            }
                            .disabled(waterEjectionService.isPlaying)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Tips Button
                    if !waterEjectionService.isPlaying {
                        Button(action: { showingTips = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.headline)
                                Text("Safety Tips")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Premium Banner (if not premium)
                    if !subscriptionService.isPremium {
                        PremiumBannerView {
                            showingPremiumOffer = true
                        }
                    }
                    
                    // Banner Ad (only show when not actively ejecting)
                    if !waterEjectionService.isPlaying {
                        VStack(spacing: 0) {
                            ConditionalBannerAdView(adUnitId: AdMobService.shared.getBannerAdUnitId())
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
            .navigationTitle("Water Eject")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(StackNavigationViewStyle())
            .sheet(isPresented: $showingDevicePicker) {
                DevicePickerView(selectedDevice: $selectedDevice)
            }
            .sheet(isPresented: $showingIntensityPicker) {
                IntensityPickerView(selectedIntensity: $selectedIntensity)
            }
                    .sheet(isPresented: $showingTips) {
            TipsView()
        }
        .sheet(isPresented: $showingPremiumOffer) {
            PremiumOfferView()
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

// Device detection function
private func detectCurrentDevice() -> DeviceType {
    #if targetEnvironment(macCatalyst)
    return .macbook
    #else
    let device = UIDevice.current
    let model = device.model
    
    switch model {
    case "iPhone":
        return .iphone
    case "iPad":
        return .ipad
    default:
        // For other devices, try to detect based on screen size
        let screenSize = UIScreen.main.bounds.size
        let screenHeight = max(screenSize.width, screenSize.height)
        
        if screenHeight >= 1024 {
            // iPad Pro, iPad Air, etc.
            return .ipad
        } else if screenHeight >= 667 {
            // iPhone 6 and larger
            return .iphone
        } else {
            // Smaller devices, default to iPhone
            return .iphone
        }
    }
    #endif
}

@available(iOS 16.0, *)
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
        VStack(spacing: 24) {
            // Progress Circle
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 8)
                    .frame(maxWidth: 200, maxHeight: 200)
                    .aspectRatio(1, contentMode: .fit)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(maxWidth: 200, maxHeight: 200)
                    .aspectRatio(1, contentMode: .fit)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)
                
                VStack(spacing: 4) {
                    Text(formatTime(remainingTime))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                    
                    Text("remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            
            // Progress Bar
            VStack(spacing: 12) {
                HStack {
                    Text("Progress")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .frame(height: 8)
            }
        }
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .frame(maxWidth: .infinity)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}



#Preview {
    if #available(iOS 16.0, *) {
        MainEjectionView()
    } else {
        Text("Requires iOS 16.0 or newer")
    }
} 