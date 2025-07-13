import SwiftUI

@available(iOS 16.0, *)
struct IntensityPickerView: View {
    @Binding var selectedIntensity: IntensityLevel
    @Environment(\.dismiss) private var dismiss
    
    @State private var useCustomIntensity = false
    @State private var customIntensityValue: Double = 50.0
    @State private var customDuration: Double = 60.0
    
    private let minIntensity: Double = 0.0
    private let maxIntensity: Double = 100.0
    private let minDuration: Double = 10.0
    private let maxDuration: Double = 300.0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Select Intensity")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Choose the intensity level for water and dust ejection")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Preset Intensity Levels
                VStack(spacing: 16) {
                    Text("Preset Levels")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 12) {
                        ForEach(IntensityLevel.allCases, id: \.self) { intensity in
                            IntensityLevelRow(
                                intensity: intensity,
                                isSelected: selectedIntensity == intensity && !useCustomIntensity,
                                onTap: {
                                    selectedIntensity = intensity
                                    useCustomIntensity = false
                                }
                            )
                        }
                    }
                }
                
                // Custom Intensity Section
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Custom Intensity")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("Use sliders for precise control")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $useCustomIntensity)
                            .onChange(of: useCustomIntensity) { newValue in
                                if newValue {
                                    // Convert current preset to custom values
                                    customIntensityValue = getIntensityValue(for: selectedIntensity)
                                    customDuration = selectedIntensity.duration
                                }
                            }
                    }
                    
                    if useCustomIntensity {
                        VStack(spacing: 20) {
                            // Intensity Slider
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Intensity Level")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(customIntensityValue))%")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                }
                                
                                Slider(value: $customIntensityValue, in: minIntensity...maxIntensity, step: 1)
                                    .accentColor(.blue)
                                
                                HStack {
                                    Text("Low")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text("High")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            // Duration Slider
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Duration")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(customDuration))s")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.green)
                                }
                                
                                Slider(value: $customDuration, in: minDuration...maxDuration, step: 5)
                                    .accentColor(.green)
                                
                                HStack {
                                    Text("10s")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text("5m")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            // Custom Intensity Preview
                            VStack(spacing: 8) {
                                Text("Custom Settings")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Intensity: \(Int(customIntensityValue))%")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text("Duration: \(Int(customDuration)) seconds")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "slider.horizontal.3")
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                
                // Safety Warning
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        
                        Text("Safety Reminder")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                    
                    Text("Higher intensity levels may be more effective but should be used with caution. Always follow device-specific safety guidelines.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
                
                // Realtime Mode Info
                if selectedIntensity == .realtime {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "waveform.path.ecg")
                                .foregroundColor(.purple)
                            
                            Text("Realtime Mode")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                        
                        Text("Adjust frequency in real-time while the session is running. Perfect for finding the optimal frequency for your specific situation.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Intensity")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(StackNavigationViewStyle())
            .onAppear {
                // Load existing custom values if they exist
                let existingUseCustom = UserDefaults.standard.bool(forKey: "useCustomIntensity")
                let existingIntensity = UserDefaults.standard.double(forKey: "customIntensityValue")
                let existingDuration = UserDefaults.standard.double(forKey: "customDuration")
                
                if existingUseCustom && existingIntensity > 0 {
                    useCustomIntensity = true
                    customIntensityValue = existingIntensity
                    customDuration = existingDuration > 0 ? existingDuration : 60.0
                }
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Done") {
                    if useCustomIntensity {
                        // Store custom values in UserDefaults for the service to use
                        UserDefaults.standard.set(customIntensityValue, forKey: "customIntensityValue")
                        UserDefaults.standard.set(customDuration, forKey: "customDuration")
                        UserDefaults.standard.set(true, forKey: "useCustomIntensity")
                        
                        // Set to a special custom intensity level
                        selectedIntensity = .emergency // This will be overridden by custom values
                    } else {
                        // Clear custom values
                        UserDefaults.standard.removeObject(forKey: "customIntensityValue")
                        UserDefaults.standard.removeObject(forKey: "customDuration")
                        UserDefaults.standard.set(false, forKey: "useCustomIntensity")
                    }
                    dismiss()
                }
            )
        }
    }
    
    private func getIntensityValue(for intensity: IntensityLevel) -> Double {
        switch intensity {
        case .low: return 25.0
        case .medium: return 50.0
        case .high: return 75.0
        case .emergency: return 100.0
        case .realtime: return 50.0
        }
    }
    
    private func getCustomIntensityLevel() -> IntensityLevel {
        // This function is no longer used since we're storing custom values directly
        // Return emergency as a fallback, but custom values will be used from UserDefaults
        return .emergency
    }
}

@available(iOS 16.0, *)
struct IntensityLevelRow: View {
    let intensity: IntensityLevel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: intensity.icon)
                    .font(.title2)
                    .foregroundColor(intensity.color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(intensity.displayName)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("\(Int(intensity.duration)) seconds")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    if #available(iOS 16.0, *) {
        IntensityPickerView(selectedIntensity: .constant(.medium))
    } else {
        Text("Requires iOS 16.0 or newer")
    }
} 