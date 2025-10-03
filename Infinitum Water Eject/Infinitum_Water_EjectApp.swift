/*
 * ============================================================================
 * INFINITUM WATER EJECT - MAIN APPLICATION ENTRY POINT
 * ============================================================================
 * 
 * FILE: Infinitum_Water_EjectApp.swift
 * PURPOSE: Main application entry point and configuration
 * AUTHOR: Kevin Doyle Jr.
 * CREATED: [7/5/2025]
 * LAST MODIFIED: [7/9/2025]
 *
 * DESCRIPTION:
 * This file serves as the primary entry point for the Infinitum Water Eject iOS application.
 * It initializes the app's core services, manages the main window group, and handles
 * iOS version compatibility. The app provides water ejection functionality with
 * premium features, AdMob integration, and comprehensive user settings.
 * 
 * ARCHITECTURE OVERVIEW:
 * - @main struct: Defines the main app structure using SwiftUI's App protocol
 * - State Management: Uses @StateObject for theme and AdMob service management
 * - Version Compatibility: Implements iOS 16.0+ requirement with fallback UI
 * - Service Integration: Initializes core services (ThemeManager, AdMobService)
 * - Environment Objects: Provides theme and service objects to child views
 * 
 * KEY COMPONENTS:
 * 1. ThemeManager.shared: Manages app-wide theme and color scheme preferences
 * 2. AdMobService.shared: Handles advertisement display and revenue generation
 * 3. MainTabView(): Primary navigation interface for the application
 * 4. iOS Version Check: Ensures compatibility with iOS 16.0+ requirement
 * 
 * DEPENDENCIES:
 * - SwiftUI: Core UI framework
 * - ThemeManager: Custom theme management service
 * - AdMobService: Advertisement service integration
 * - MainTabView: Primary navigation view
 * 
 * TODO LIST:
 * - [ ] Add app launch analytics tracking
 * - [ ] Implement crash reporting service integration
 * - [ ] Add app state restoration for background/foreground transitions
 * - [ ] Consider adding app configuration from remote sources
 * - [ ] Implement app update notification system
 * - [ ] Add accessibility improvements for VoiceOver users
 * 
 * FEATURE SUGGESTIONS:
 * - [ ] Add app onboarding flow for first-time users
 * - [ ] Implement deep linking support for external app integration
 * - [ ] Add app widget configuration from main app
 * - [ ] Consider adding app shortcuts for quick actions
 * - [ ] Implement app state persistence across app launches
 * - [ ] Add app performance monitoring and metrics collection
 * 
 * TECHNICAL NOTES:
 * - Uses SwiftUI's modern App protocol for iOS 14+ compatibility
 * - Implements proper state management with @StateObject
 * - Handles iOS version compatibility gracefully
 * - Follows MVVM architecture patterns
 * 
 * ============================================================================
 */

//
//  Infinitum_Water_EjectApp.swift
//  Infinitum Water Eject
//
//  Created by Kevin Doyle Jr. on 7/5/25.
//

import SwiftUI

// MARK: - Main Application Structure
// This is the primary entry point for the Infinitum Water Eject application
// The @main attribute indicates this is the main app entry point
@main
struct Infinitum_Water_EjectApp: App {
    // MARK: - State Objects
    // These @StateObject properties manage app-wide state and services
    // They are initialized once and shared across the entire app lifecycle
    
    /// Manages the app's theme and color scheme preferences
    /// Provides dark/light mode switching and custom theme support
    @StateObject private var themeService = ThemeService()
    
    /// Handles AdMob advertisement integration and revenue generation
    /// Manages banner ads, interstitial ads, and ad loading states
    @StateObject private var adMobService = AdMobService.shared
    
    // MARK: - App Body
    // Defines the main app interface and window configuration
    var body: some Scene {
        WindowGroup {
            // MARK: - iOS Version Compatibility Check
            // Ensures the app only runs on iOS 16.0 or newer
            // Provides a user-friendly error message for incompatible devices
            if #available(iOS 16.0, *) {
                // MARK: - Main App Interface
                // Displays the primary tab-based navigation interface
                // Applies theme preferences and provides environment objects
                MainTabView()
                    .environmentObject(themeService)                 // Makes theme service available to all child views
                    .environment(\.appTheme, themeService.currentTheme) // Provides current theme to all views
            } else {
                // MARK: - Incompatible iOS Version Fallback
                // Displays a user-friendly error message for devices running iOS 15 or earlier
                // Includes app icon, title, and clear instructions for updating
                VStack(spacing: 20) {
                    // Warning icon to indicate compatibility issue
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    // App title display
                    Text("Infinitum Water Eject")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Primary error message explaining the requirement
                    Text("This app requires iOS 16.0 or newer to run.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Secondary message with action instructions
                    Text("Please update your device to iOS 16.0 or later to use this app.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .environmentObject(themeService)                 // Provides theme service for consistent styling
                .environment(\.appTheme, themeService.currentTheme) // Provides current theme to all views
            }
        }
    }
}
