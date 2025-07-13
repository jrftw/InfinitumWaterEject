/*
 * ============================================================================
 * INFINITUM WATER EJECT - WATCHOS SHARED MODELS
 * ============================================================================
 * 
 * FILE: SharedModels.swift
 * PURPOSE: watchOS-specific shared data models for Apple Watch
 * AUTHOR: Kevin Doyle Jr.
 * CREATED: [7/5/2025]
 * LAST MODIFIED: [7/9/2025]
 *
 * DESCRIPTION:
 * This file contains watchOS-specific data models that are used by the
 * Apple Watch app. It includes device types, intensity levels, and other
 * common enums specifically for watchOS without conflicting with iOS models.
 * 
 * ARCHITECTURE OVERVIEW:
 * - watchOS-specific conditionals
 * - Independent enums for watchOS use
 * - Shared data structures for cross-platform compatibility
 * - Platform-specific imports and configurations
 * 
 * KEY COMPONENTS:
 * 1. WatchIntensityLevel: Intensity levels for watchOS
 * 2. WatchDeviceType: Device types for watchOS
 * 3. Platform-specific imports and configurations
 * 4. Shared data structures for cross-platform use
 * 
 * DEPENDENCIES:
 * - Foundation: Core iOS framework for basic functionality
 * 
 * ============================================================================
 */

import Foundation

#if os(watchOS)

// MARK: - Watch Intensity Level Enumeration
// Defines available intensity levels with associated properties for watchOS
// Each level has specific duration and icon mappings
enum WatchIntensityLevel: String, CaseIterable, Codable {
    // MARK: - Intensity Cases
    // Five intensity levels with string raw values for persistence
    
    /// Low intensity - gentle water removal (30 seconds)
    case low = "Low"
    
    /// Medium intensity - standard water removal (60 seconds)
    case medium = "Medium"
    
    /// High intensity - aggressive water removal (120 seconds)
    case high = "High"
    
    /// Emergency intensity - maximum water removal (180 seconds)
    case emergency = "Emergency"
    
    /// Realtime intensity - continuous adjustment mode (300 seconds)
    case realtime = "Realtime"
    
    // MARK: - Computed Properties
    // These properties provide UI-friendly values for each intensity level
    
    /// Human-readable display name for the intensity level
    /// Used in UI labels and user-facing text
    var displayName: String {
        return rawValue
    }
    
    /// SF Symbol icon name for the intensity level
    /// Used in intensity selection UI and session displays
    var icon: String {
        switch self {
        case .low: return "drop.fill"                    // Water drop for low intensity
        case .medium: return "drop.fill"                 // Water drop for medium intensity
        case .high: return "drop.fill"                   // Water drop for high intensity
        case .emergency: return "exclamationmark.triangle.fill"  // Warning triangle for emergency
        case .realtime: return "waveform.path.ecg"       // ECG waveform for realtime mode
        }
    }
    
    /// Default duration in seconds for the intensity level
    /// Used for session planning and progress tracking
    var duration: TimeInterval {
        switch self {
        case .low: return 30         // 30 seconds for gentle water removal
        case .medium: return 60      // 1 minute for standard water removal
        case .high: return 120       // 2 minutes for aggressive water removal
        case .emergency: return 180  // 3 minutes for maximum water removal
        case .realtime: return 300   // 5 minutes for continuous adjustment mode
        }
    }
}

// MARK: - Watch Device Type Enumeration
// Defines supported device types with associated properties for watchOS
// Each device type has specific icon and display name mappings
enum WatchDeviceType: String, CaseIterable, Codable {
    // MARK: - Device Cases
    // Six device types with string raw values for persistence
    
    /// iPhone device - primary mobile support
    case iphone = "iPhone"
    
    /// iPad device - tablet support
    case ipad = "iPad"
    
    /// MacBook device - laptop support
    case macbook = "MacBook"
    
    /// Apple Watch device - wearable support
    case applewatch = "Apple Watch"
    
    /// AirPods device - audio device support
    case airpods = "AirPods"
    
    /// Other devices - generic fallback
    case other = "Other"
    
    // MARK: - Computed Properties
    // These properties provide UI-friendly values for each device type
    
    /// Human-readable display name for the device type
    /// Used in device selection UI and session displays
    var displayName: String {
        return rawValue
    }
    
    /// SF Symbol icon name for the device type
    /// Used in device selection UI and session displays
    var icon: String {
        switch self {
        case .iphone: return "iphone"                    // iPhone icon
        case .ipad: return "ipad"                        // iPad icon
        case .macbook: return "laptopcomputer"           // MacBook icon
        case .applewatch: return "applewatch"            // Apple Watch icon
        case .airpods: return "airpods"                  // AirPods icon
        case .other: return "device.phone.portrait"      // Generic device icon
        }
    }
    
    /// watchOS-specific device detection
    static func detectCurrentDevice() -> WatchDeviceType {
        // Apple Watch is the primary device on watchOS
        return .applewatch
    }
}

// MARK: - Shared Data Structures for Watch

/// Shared session data structure for watchOS use
struct WatchSessionData: Codable {
    let id: UUID
    let deviceType: WatchDeviceType
    let intensityLevel: WatchIntensityLevel
    let duration: TimeInterval
    let startTime: Date
    let isCompleted: Bool
    
    init(id: UUID = UUID(),
         deviceType: WatchDeviceType = .applewatch,
         intensityLevel: WatchIntensityLevel = .medium,
         duration: TimeInterval = 0,
         startTime: Date = Date(),
         isCompleted: Bool = false) {
        self.id = id
        self.deviceType = deviceType
        self.intensityLevel = intensityLevel
        self.duration = duration
        self.startTime = startTime
        self.isCompleted = isCompleted
    }
}

/// Shared user settings for watchOS use
struct WatchUserSettings: Codable {
    let isPremium: Bool
    let notificationsEnabled: Bool
    let weeklyGoal: Int
    
    init(isPremium: Bool = false,
         notificationsEnabled: Bool = true,
         weeklyGoal: Int = 7) {
        self.isPremium = isPremium
        self.notificationsEnabled = notificationsEnabled
        self.weeklyGoal = weeklyGoal
    }
}

#endif 