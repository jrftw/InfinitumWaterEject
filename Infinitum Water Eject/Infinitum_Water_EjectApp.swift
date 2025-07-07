//
//  Infinitum_Water_EjectApp.swift
//  Infinitum Water Eject
//
//  Created by Kevin Doyle Jr. on 7/5/25.
//

import SwiftUI

@main
struct Infinitum_Water_EjectApp: App {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var adMobService = AdMobService.shared
    
    var body: some Scene {
        WindowGroup {
            if #available(iOS 16.0, *) {
                MainTabView()
                    .preferredColorScheme(themeManager.colorScheme)
                    .environmentObject(themeManager)
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("Infinitum Water Eject")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("This app requires iOS 16.0 or newer to run.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("Please update your device to iOS 16.0 or later to use this app.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .preferredColorScheme(themeManager.colorScheme)
                .environmentObject(themeManager)
            }
        }
    }
}
