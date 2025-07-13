//* AUTHOR: Kevin Doyle Jr.
//* CREATED: [7/5/2025]
//* LAST MODIFIED: [7/9/2025]


import SwiftUI

@available(iOS 16.0, *)
struct ChangeLogView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Change Log")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
               // ChangeLogSection(version: "1.0.2 Build 1", date: "2025-07-09", changes: [
                //     "Introduced Ads",
                //     "Introduced Subscriptions & Premium Features"
                //    ])
                
                ChangeLogSection(version: "1.0.1 Build 1", date: "2025-07-08", changes: [
                    "Updated app version to 1.0.1 Build 1",
                    "Improved version synchronization across all targets",
                    "Enhanced build number management",
                    "Updated change log with latest version information"
                ])
                
                ChangeLogSection(version: "1.0.0 Build 2", date: "2025-07-07", changes: [
                    "Fixed iOS version compatibility issues",
                    "Added iOS 16.0+ availability checks for all views",
                    "Resolved app crashes on older iOS versions",
                    "Fixed SceneDelegate configuration issues",
                    "Improved mail composition handling for simulator",
                    "Enhanced backward compatibility support",
                    "Updated tab structure for better UX",
                    "Moved Support & Help to Settings menu",
                    "Fixed optional chaining and nil coalescing issues",
                    "Improved error handling and user feedback"
                ])
                
                ChangeLogSection(version: "1.0.0 Build 1", date: "2025-07-05", changes: [
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
            }
            .padding()
        }
        .navigationTitle("Change Log")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func getAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) Build \(build)"
    }
}

@available(iOS 16.0, *)
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
