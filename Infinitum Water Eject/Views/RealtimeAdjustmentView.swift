import SwiftUI

@available(iOS 16.0, *)
struct RealtimeAdjustmentView: View {
    @ObservedObject var waterEjectionService: WaterEjectionService
    @State private var intensity: Double = 50.0
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Realtime Mode")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Adjust frequency while running")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            
            // Current Frequency Display
            VStack(spacing: 16) {
                Text("Current Frequency")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ZStack {
                    Circle()
                        .stroke(Color.purple.opacity(0.3), lineWidth: 8)
                        .frame(maxWidth: 150, maxHeight: 150)
                        .aspectRatio(1, contentMode: .fit)
                    
                    Circle()
                        .trim(from: 0, to: intensity / 100.0)
                        .stroke(Color.purple, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(maxWidth: 150, maxHeight: 150)
                        .aspectRatio(1, contentMode: .fit)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.3), value: intensity)
                    
                    VStack(spacing: 4) {
                        Text("\(Int(waterEjectionService.currentFrequency))")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.purple)
                            .minimumScaleFactor(0.8)
                            .lineLimit(1)
                        
                        Text("Hz")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            
            // Intensity Slider
            VStack(spacing: 16) {
                HStack {
                    Text("Intensity")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("\(Int(intensity))%")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                }
                
                Slider(value: $intensity, in: 0...100, step: 1)
                    .accentColor(.purple)
                    .onChange(of: intensity) { newValue in
                        waterEjectionService.updateRealtimeFrequency(intensity: newValue)
                    }
                
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
            
            // Frequency Range Info
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                        .frame(width: 20, height: 20)
                    
                    Text("Frequency Range")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Min:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(calculateMinFrequency())) Hz")
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("Max:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(calculateMaxFrequency())) Hz")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    
                    Text("Adjust the slider to change frequency in real-time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            
            Spacer(minLength: 20)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .onAppear {
            intensity = waterEjectionService.realtimeIntensity
        }
    }
    
    private func calculateMinFrequency() -> Double {
        let baseFrequencies: [DeviceType: Double] = [
            .iphone: 165.0,
            .ipad: 220.0,
            .macbook: 440.0,
            .applewatch: 880.0, // (temporarily disabled)
            .airpods: 660.0,
            .other: 330.0
        ]
        
        let baseFrequency = baseFrequencies[waterEjectionService.currentSession?.deviceType ?? .iphone] ?? 330.0
        return baseFrequency * 0.5 // Min multiplier
    }
    
    private func calculateMaxFrequency() -> Double {
        let baseFrequencies: [DeviceType: Double] = [
            .iphone: 165.0,
            .ipad: 220.0,
            .macbook: 440.0,
            .applewatch: 880.0, // (temporarily disabled)
            .airpods: 660.0,
            .other: 330.0
        ]
        
        let baseFrequency = baseFrequencies[waterEjectionService.currentSession?.deviceType ?? .iphone] ?? 330.0
        return baseFrequency * 2.0 // Max multiplier
    }
}

#Preview {
    if #available(iOS 16.0, *) {
        RealtimeAdjustmentView(waterEjectionService: WaterEjectionService.shared)
    } else {
        Text("Requires iOS 16.0 or newer")
    }
} 