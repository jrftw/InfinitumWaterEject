import SwiftUI

@available(iOS 16.0, *)
struct TipsView: View {
    @State private var selectedDevice: DeviceType = .iphone
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Device Picker - Horizontal Scrollable
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(DeviceType.allCases, id: \.self) { device in
                            DevicePickerButton(
                                device: device,
                                isSelected: selectedDevice == device,
                                action: { selectedDevice = device }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                
                // Tips Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        switch selectedDevice {
                        case .iphone:
                            iPhoneTipsView()
                        case .ipad:
                            iPadTipsView()
                        case .macbook:
                            MacBookTipsView()
                        case .applewatch:
                            AppleWatchTipsView()
                        case .airpods:
                            AirPodsTipsView()
                        case .other:
                            OtherDeviceTipsView()
                        }
                        
                        // Banner Ad at the bottom
                        VStack(spacing: 0) {
                            ConditionalBannerAdView(adUnitId: AdMobService.shared.getBannerAdUnitId())
                        }
                        .padding(.top, 20)
                    }
                    .padding()
                }
            }
            .navigationTitle("Safety Tips")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

@available(iOS 16.0, *)
struct DevicePickerButton: View {
    let device: DeviceType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: device.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(device.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(1)
            }
            .frame(width: 80, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

@available(iOS 16.0, *)
struct iPhoneTipsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TipSection(
                title: "Before Ejection",
                tips: [
                    "Remove iPhone case and any accessories",
                    "Power off the device completely",
                    "Remove SIM card tray if possible",
                    "Gently shake to remove excess water",
                    "Place on a clean, dry surface"
                ]
            )
            
            TipSection(
                title: "During Ejection",
                tips: [
                    "Keep device in landscape orientation",
                    "Use low intensity for light water exposure",
                    "Use medium intensity for normal exposure",
                    "Use high intensity for heavy exposure",
                    "Follow the timer and don't interrupt"
                ]
            )
            
            TipSection(
                title: "After Ejection",
                tips: [
                    "Let device dry for at least 2 hours",
                    "Don't charge for at least 4 hours",
                    "Check for water damage indicators",
                    "Test all functions before use",
                    "If issues persist, consult Apple Support"
                ]
            )
            
            TipSection(
                title: "iPhone-Specific Tips",
                tips: [
                    "Focus on speaker grilles and charging port",
                    "iPhone 7+ models are water-resistant but not waterproof",
                    "Avoid using in saltwater or chlorinated water",
                    "Check water damage indicator in SIM tray",
                    "Use rice or silica gel for additional drying"
                ]
            )
            
            WarningSection(
                warnings: [
                    "Never use heat sources (hair dryers, ovens)",
                    "Don't insert objects into ports",
                    "Avoid extreme shaking",
                    "Don't use if water damage is severe",
                    "This app is for preventive measures only"
                ]
            )
        }
    }
}

@available(iOS 16.0, *)
struct iPadTipsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TipSection(
                title: "Before Ejection",
                tips: [
                    "Remove iPad case and Smart Cover",
                    "Power off the device completely",
                    "Remove any connected accessories",
                    "Gently shake to remove excess water",
                    "Place on a clean, dry surface"
                ]
            )
            
            TipSection(
                title: "During Ejection",
                tips: [
                    "Keep iPad in landscape orientation",
                    "Focus on speaker areas and ports",
                    "Use appropriate intensity level",
                    "Follow the timer completely",
                    "Don't move device during ejection"
                ]
            )
            
            TipSection(
                title: "After Ejection",
                tips: [
                    "Let iPad dry for at least 3 hours",
                    "Don't charge for at least 6 hours",
                    "Check all ports and speakers",
                    "Test touch sensitivity",
                    "If issues persist, contact Apple Support"
                ]
            )
            
            TipSection(
                title: "iPad-Specific Tips",
                tips: [
                    "Focus on speaker grilles and charging port",
                    "iPad Pro models have better water resistance",
                    "Avoid using in humid environments",
                    "Check for water damage in ports",
                    "Use silica gel packets for drying"
                ]
            )
            
            WarningSection(
                warnings: [
                    "Never use heat sources",
                    "Don't insert objects into ports",
                    "Avoid extreme shaking",
                    "Don't use if water damage is severe",
                    "This app is for preventive measures only"
                ]
            )
        }
    }
}

@available(iOS 16.0, *)
struct MacBookTipsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TipSection(
                title: "Before Ejection",
                tips: [
                    "Shut down MacBook completely",
                    "Unplug all cables and accessories",
                    "Remove any external devices",
                    "Turn MacBook upside down",
                    "Place on a clean, dry surface"
                ]
            )
            
            TipSection(
                title: "During Ejection",
                tips: [
                    "Keep MacBook in normal orientation",
                    "Focus on speaker areas and ports",
                    "Use appropriate intensity level",
                    "Follow the timer completely",
                    "Don't move device during ejection"
                ]
            )
            
            TipSection(
                title: "After Ejection",
                tips: [
                    "Let MacBook dry for at least 6 hours",
                    "Don't charge for at least 12 hours",
                    "Check all ports and speakers",
                    "Test keyboard and trackpad",
                    "If issues persist, contact Apple Support"
                ]
            )
            
            TipSection(
                title: "MacBook-Specific Tips",
                tips: [
                    "Focus on speaker grilles and ports",
                    "MacBook Pro models have better water resistance",
                    "Avoid using in humid environments",
                    "Check for water damage in ports",
                    "Use silica gel packets for drying"
                ]
            )
            
            WarningSection(
                warnings: [
                    "Never use heat sources",
                    "Don't insert objects into ports",
                    "Avoid extreme shaking",
                    "Don't use if water damage is severe",
                    "This app is for preventive measures only"
                ]
            )
        }
    }
}

@available(iOS 16.0, *)
struct AppleWatchTipsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TipSection(
                title: "Before Ejection",
                tips: [
                    "Remove Apple Watch from wrist",
                    "Remove any bands or accessories",
                    "Power off if possible",
                    "Gently shake to remove excess water",
                    "Place on a clean, dry surface"
                ]
            )
            
            TipSection(
                title: "During Ejection",
                tips: [
                    "Keep Apple Watch in normal orientation",
                    "Focus on speaker and microphone areas",
                    "Use appropriate intensity level",
                    "Follow the timer completely",
                    "Don't move device during ejection"
                ]
            )
            
            TipSection(
                title: "After Ejection",
                tips: [
                    "Let Apple Watch dry for at least 2 hours",
                    "Don't charge for at least 4 hours",
                    "Check speaker and microphone",
                    "Test Digital Crown and side button",
                    "If issues persist, contact Apple Support"
                ]
            )
            
            TipSection(
                title: "Apple Watch-Specific Tips",
                tips: [
                    "Focus on speaker and microphone areas",
                    "Apple Watch Series 2+ are water-resistant",
                    "Avoid using in saltwater",
                    "Check for water damage in ports",
                    "Use silica gel packets for drying"
                ]
            )
            
            WarningSection(
                warnings: [
                    "Never use heat sources",
                    "Don't insert objects into ports",
                    "Avoid extreme shaking",
                    "Don't use if water damage is severe",
                    "This app is for preventive measures only"
                ]
            )
        }
    }
}

@available(iOS 16.0, *)
struct AirPodsTipsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TipSection(
                title: "Before Ejection",
                tips: [
                    "Remove AirPods from case",
                    "Remove any ear tips or accessories",
                    "Gently shake to remove excess water",
                    "Place on a clean, dry surface",
                    "Keep case separate"
                ]
            )
            
            TipSection(
                title: "During Ejection",
                tips: [
                    "Keep AirPods in normal orientation",
                    "Focus on speaker grilles",
                    "Use appropriate intensity level",
                    "Follow the timer completely",
                    "Don't move device during ejection"
                ]
            )
            
            TipSection(
                title: "After Ejection",
                tips: [
                    "Let AirPods dry for at least 2 hours",
                    "Don't charge for at least 4 hours",
                    "Check speaker quality",
                    "Test microphone functionality",
                    "If issues persist, contact Apple Support"
                ]
            )
            
            TipSection(
                title: "AirPods-Specific Tips",
                tips: [
                    "Focus on speaker grilles",
                    "AirPods Pro have better water resistance",
                    "Avoid using in humid environments",
                    "Check for water damage in ports",
                    "Use silica gel packets for drying"
                ]
            )
            
            WarningSection(
                warnings: [
                    "Never use heat sources",
                    "Don't insert objects into ports",
                    "Avoid extreme shaking",
                    "Don't use if water damage is severe",
                    "This app is for preventive measures only"
                ]
            )
        }
    }
}

@available(iOS 16.0, *)
struct OtherDeviceTipsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TipSection(
                title: "Before Ejection",
                tips: [
                    "Power off the device completely",
                    "Remove any cases or accessories",
                    "Remove batteries if possible",
                    "Gently shake to remove excess water",
                    "Place on a clean, dry surface"
                ]
            )
            
            TipSection(
                title: "During Ejection",
                tips: [
                    "Keep device in normal orientation",
                    "Focus on speaker areas and ports",
                    "Use appropriate intensity level",
                    "Follow the timer completely",
                    "Don't move device during ejection"
                ]
            )
            
            TipSection(
                title: "After Ejection",
                tips: [
                    "Let device dry for at least 4 hours",
                    "Don't charge for at least 8 hours",
                    "Check all functions before use",
                    "Test speakers and ports",
                    "If issues persist, consult manufacturer"
                ]
            )
            
            TipSection(
                title: "General Tips",
                tips: [
                    "Focus on speaker grilles and ports",
                    "Check device water resistance rating",
                    "Avoid using in humid environments",
                    "Check for water damage indicators",
                    "Use silica gel packets for drying"
                ]
            )
            
            WarningSection(
                warnings: [
                    "Never use heat sources",
                    "Don't insert objects into ports",
                    "Avoid extreme shaking",
                    "Don't use if water damage is severe",
                    "This app is for preventive measures only"
                ]
            )
        }
    }
}

@available(iOS 16.0, *)
struct TipSection: View {
    let title: String
    let tips: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(tips, id: \.self) { tip in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                            .padding(.top, 2)
                        
                        Text(tip)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

@available(iOS 16.0, *)
struct WarningSection: View {
    let warnings: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("⚠️ Important Warnings")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.red)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(warnings, id: \.self) { warning in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 2)
                        
                        Text(warning)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    if #available(iOS 16.0, *) {
        TipsView()
    } else {
        Text("Requires iOS 16.0 or newer")
    }
} 