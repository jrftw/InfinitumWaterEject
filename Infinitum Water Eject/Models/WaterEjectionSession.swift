/*
 * ============================================================================
 * INFINITUM WATER EJECT - WATER & DUST EJECTION SESSION MODEL
 * ============================================================================
 * 
 * FILE: WaterEjectionSession.swift
 * PURPOSE: Defines data models for water and dust ejection sessions and related enums
 * AUTHOR: Kevin Doyle Jr.
 * CREATED: [7/5/2025]
 * LAST MODIFIED: [7/9/2025]
 *
 * DESCRIPTION:
 * This file contains the core data models for tracking water and dust ejection sessions
 * in the Infinitum Water Eject application. It defines the WaterEjectionSession
 * struct, DeviceType enum, and IntensityLevel enum for managing session
 * data, device compatibility, and intensity settings for water and dust removal operations.
 * 
 * ARCHITECTURE OVERVIEW:
 * - WaterEjectionSession: Main data structure for session tracking
 * - IntensityLevel: Enumeration of available intensity settings with properties
 * - DeviceType: Enumeration of supported device types with UI properties
 * - Identifiable Protocol: Enables SwiftUI list integration and data binding
 * - Codable Protocol: Supports data persistence and serialization
 * - Core Data Ready: Designed for future Core Data integration
 * 
 * KEY COMPONENTS:
 * 1. WaterEjectionSession: Complete session data with timing and completion status
 * 2. IntensityLevel: Five intensity levels with duration, color, and icon mappings
 * 3. DeviceType: Six device types with display properties and icon mappings
 * 4. Session Tracking: Comprehensive session lifecycle management
 * 
 * DATA FIELDS (WaterEjectionSession):
 * - id: Unique identifier for each session (UUID)
 * - deviceType: Type of device used for water ejection
 * - intensityLevel: Intensity setting used during the session
 * - duration: Total duration of the session in seconds
 * - startTime: When the session began
 * - endTime: When the session completed (optional)
 * - isCompleted: Whether the session finished successfully
 * 
 * INTENSITY LEVELS:
 * - Low: 30 seconds, blue color, gentle water removal
 * - Medium: 60 seconds, cyan color, standard water removal
 * - High: 120 seconds, orange color, aggressive water removal
 * - Emergency: 180 seconds, red color, maximum water removal
 * - Realtime: 300 seconds, purple color, continuous adjustment mode
 * 
 * SUPPORTED DEVICES:
 * - iPhone: Primary mobile device support
 * - iPad: Tablet device support
 * - MacBook: Laptop device support
 * - Apple Watch: Wearable device support
 * - AirPods: Audio device support
 * - Other: Generic device fallback
 * 
 * DEPENDENCIES:
 * - Foundation: Core iOS framework for basic functionality
 * - CoreData: Data persistence framework (for future integration)
 * - SwiftUI: UI framework for Color and Identifiable integration
 * 
 * TODO LIST:
 * - [ ] Implement Core Data integration for persistent session storage
 * - [ ] Add session analytics and performance metrics
 * - [ ] Create session export functionality (CSV, JSON)
 * - [ ] Add session sharing between devices
 * - [ ] Implement session backup/restore functionality
 * - [ ] Add session search and filtering capabilities
 * - [ ] Create session templates for quick setup
 * - [ ] Add session notes and user comments
 * 
 * FEATURE SUGGESTIONS:
 * - [ ] Add custom intensity levels with user-defined parameters
 * - [ ] Implement session scheduling and recurring sessions
 * - [ ] Add session comparison and trend analysis
 * - [ ] Create session recommendations based on device type
 * - [ ] Implement session collaboration features
 * - [ ] Add session gamification elements (achievements, streaks)
 * - [ ] Create session automation based on device conditions
 * - [ ] Add session integration with health apps
 * 
 * TECHNICAL NOTES:
 * - Uses UUID for unique session identification
 * - Implements proper time interval handling
 * - Provides comprehensive enum properties for UI integration
 * - Follows Swift naming conventions and best practices
 * - Designed for easy Core Data migration
 * - Supports both completed and in-progress sessions
 * 
 * ============================================================================
 */

import Foundation
import CoreData
import SwiftUI

// MARK: - Core Data Model Documentation
// This section will be replaced with generated Core Data model code
// For now, we use a simple struct that can be converted to/from Core Data
// The struct is designed to be easily migratable to Core Data entities

// MARK: - Core Data Integration Extensions

extension WaterEjectionSession {
    /// Creates a WaterEjectionSession instance from a Core Data entity
    init(from entity: SessionEntity) {
        self.id = entity.id ?? UUID()
        self.deviceType = DeviceType(rawValue: entity.deviceType ?? "iPhone") ?? .iphone
        self.intensityLevel = IntensityLevel(rawValue: entity.intensity ?? "Medium") ?? .medium
        self.duration = entity.duration
        self.startTime = entity.timestamp ?? Date()
        self.endTime = nil // Core Data model doesn't store endTime separately
        self.isCompleted = entity.isCompleted
    }
    
    /// Updates a Core Data entity with the current WaterEjectionSession values
    func updateEntity(_ entity: SessionEntity) {
        entity.id = self.id
        entity.deviceType = self.deviceType.rawValue
        entity.intensity = self.intensityLevel.rawValue
        entity.duration = self.duration
        entity.timestamp = self.startTime
        entity.isCompleted = self.isCompleted
        // Note: endTime is calculated from startTime + duration when isCompleted is true
    }
}

extension SessionEntity {
    /// Creates a WaterEjectionSession instance from this entity
    var toWaterEjectionSession: WaterEjectionSession {
        return WaterEjectionSession(from: self)
    }
    
    /// Updates this entity with WaterEjectionSession values
    func update(from session: WaterEjectionSession) {
        session.updateEntity(self)
    }
}

// MARK: - Water Ejection Session Data Model
// Main data structure for tracking individual water ejection sessions
// Implements Identifiable for SwiftUI list integration and Codable for persistence
struct WaterEjectionSession: Identifiable, Codable {
    // MARK: - Session Properties
    // These properties define the complete session data and state
    
    /// Unique identifier for each water ejection session
    /// Generated automatically using UUID for guaranteed uniqueness
    let id: UUID
    
    /// Type of device used for the water ejection session
    /// Determines available features and UI presentation
    var deviceType: DeviceType
    
    /// Intensity level setting used during the session
    /// Controls duration, power, and visual feedback
    var intensityLevel: IntensityLevel
    
    /// Total duration of the session in seconds
    /// Tracks actual time spent in water ejection mode
    var duration: TimeInterval
    
    /// Timestamp when the session was initiated
    /// Used for chronological ordering and analytics
    var startTime: Date
    
    /// Timestamp when the session completed (optional)
    /// nil indicates an incomplete or interrupted session
    var endTime: Date?
    
    /// Boolean indicating whether the session finished successfully
    /// Used for completion tracking and statistics
    var isCompleted: Bool
    
    // MARK: - Initialization
    // Custom initializer with sensible default values for new sessions
    // Ensures all sessions have consistent starting state
    init(id: UUID = UUID(), 
         deviceType: DeviceType = .iphone, 
         intensityLevel: IntensityLevel = .medium, 
         duration: TimeInterval = 0, 
         startTime: Date = Date(), 
         endTime: Date? = nil, 
         isCompleted: Bool = false) {
        self.id = id
        self.deviceType = deviceType
        self.intensityLevel = intensityLevel
        self.duration = duration
        self.startTime = startTime
        self.endTime = endTime
        self.isCompleted = isCompleted
    }
}

// MARK: - Intensity Level Enumeration
// Defines available intensity levels with associated properties
// Each level has specific duration, color, and icon mappings
enum IntensityLevel: String, CaseIterable, Codable {
    // MARK: - Intensity Cases
    // Five intensity levels with string raw values for persistence
    
    /// Low intensity - gentle water and dust removal (30 seconds)
    case low
    
    /// Medium intensity - standard water and dust removal (60 seconds)
    case medium
    
    /// High intensity - aggressive water and dust removal (120 seconds)
    case high
    
    /// Emergency intensity - maximum water and dust removal (180 seconds)
    case emergency
    
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
    
    /// SwiftUI Color for the intensity level
    /// Used for visual differentiation in UI elements
    var color: Color {
        switch self {
        case .low: return .blue      // Blue for gentle operation
        case .medium: return .cyan   // Cyan for standard operation
        case .high: return .orange   // Orange for aggressive operation
        case .emergency: return .red // Red for emergency operation
        case .realtime: return .purple // Purple for realtime operation
        }
    }
    
    /// Default duration in seconds for the intensity level
    /// Used for session planning and progress tracking
    var duration: TimeInterval {
        switch self {
        case .low: return 30         // 30 seconds for gentle water and dust removal
        case .medium: return 60      // 1 minute for standard water and dust removal
        case .high: return 120       // 2 minutes for aggressive water and dust removal
        case .emergency: return 180  // 3 minutes for maximum water and dust removal
        case .realtime: return 300   // 5 minutes for continuous adjustment mode
        }
    }
}

// MARK: - Device Type Enumeration
// Defines supported device types with associated properties
// Each device type has specific icon and display name mappings
enum DeviceType: String, CaseIterable, Codable {
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
        case .applewatch: return "applewatch"            // Apple Watch icon (temporarily disabled)
        case .airpods: return "airpods"                  // AirPods icon
        case .other: return "device.phone.portrait"      // Generic device icon
        }
    }
    
    /// Color for the device type
    /// Used in device selection UI and session displays
    var color: Color {
        switch self {
        case .iphone: return .blue                       // iPhone blue
        case .ipad: return .purple                       // iPad purple
        case .macbook: return .gray                       // MacBook gray
        case .applewatch: return .green                   // Apple Watch green (temporarily disabled)
        case .airpods: return .orange                     // AirPods orange
        case .other: return .secondary                     // Other secondary
        }
    }
} 
