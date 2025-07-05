import SwiftUI

struct ChangeLogView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Change Log")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                ChangeLogSection(version: "1.0.0", date: "2025-07-05", changes: [
                    "Initial release of Infinitum Water Eject",
                    "Water ejection for iPhone, iPad, MacBook, Apple Watch, AirPods, and more",
                    "Device and intensity picker with custom slider",
                    "Session history and analytics dashboard",
                    // "Premium subscription: unlimited sessions, advanced analytics, ad-free, priority support",
                    "Comprehensive safety tips and FAQ",
                    "Modern UI with light/dark/auto themes",
                    "Widget extension support",
                    "Notifications and reminders",
                    "Settings, privacy policy, and terms of service"
                ])
                
                // Add more ChangeLogSection for future versions
            }
            .padding()
        }
        .navigationTitle("Change Log")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ChangeLogSection: View {
    let version: String
    let date: String
    let changes: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Version \(version)")
                    .font(.headline)
                Spacer()
                Text(date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ForEach(changes, id: \.self) { change in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                        .padding(.top, 2)
                    Text(change)
                        .font(.body)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    ChangeLogView()
} 