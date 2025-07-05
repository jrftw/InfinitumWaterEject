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
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(themeManager.colorScheme)
                .environmentObject(themeManager)
        }
    }
}
