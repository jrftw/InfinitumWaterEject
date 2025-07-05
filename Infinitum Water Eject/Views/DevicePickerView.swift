import SwiftUI

struct DevicePickerView: View {
    @Binding var selectedDevice: DeviceType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(DeviceType.allCases, id: \.self) { device in
                    Button(action: {
                        selectedDevice = device
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: device.icon)
                                .font(.title2)
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(device.displayName)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(getDeviceDescription(for: device))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedDevice == device {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Select Device")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func getDeviceDescription(for device: DeviceType) -> String {
        switch device {
        case .iphone:
            return "iPhone models with optimized frequencies"
        case .ipad:
            return "iPad models with speaker optimization"
        case .macbook:
            return "MacBook models with enhanced audio"
        case .applewatch:
            return "Apple Watch with high-frequency output"
        case .airpods:
            return "AirPods with specialized frequencies"
        case .other:
            return "Other electronic devices"
        }
    }
}

#Preview {
    DevicePickerView(selectedDevice: .constant(.iphone))
} 