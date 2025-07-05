import Foundation
import CoreData
import SwiftUI

// Core Data model - this will be generated from the .xcdatamodeld file
// For now, we'll use a simple struct that can be converted to/from Core Data

struct WaterEjectionSession: Identifiable, Codable {
    let id: UUID
    var deviceType: DeviceType
    var intensityLevel: IntensityLevel
    var duration: TimeInterval
    var startTime: Date
    var endTime: Date?
    var isCompleted: Bool
    
    init(id: UUID = UUID(), deviceType: DeviceType = .iphone, intensityLevel: IntensityLevel = .medium, duration: TimeInterval = 0, startTime: Date = Date(), endTime: Date? = nil, isCompleted: Bool = false) {
        self.id = id
        self.deviceType = deviceType
        self.intensityLevel = intensityLevel
        self.duration = duration
        self.startTime = startTime
        self.endTime = endTime
        self.isCompleted = isCompleted
    }
}

enum IntensityLevel: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case emergency = "Emergency"
    
    var displayName: String {
        return rawValue
    }
    
    var icon: String {
        switch self {
        case .low: return "drop.fill"
        case .medium: return "drop.fill"
        case .high: return "drop.fill"
        case .emergency: return "exclamationmark.triangle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return .blue
        case .medium: return .cyan
        case .high: return .orange
        case .emergency: return .red
        }
    }
    
    var duration: TimeInterval {
        switch self {
        case .low: return 30
        case .medium: return 60
        case .high: return 120
        case .emergency: return 180
        }
    }
}

enum DeviceType: String, CaseIterable, Codable {
    case iphone = "iPhone"
    case ipad = "iPad"
    case macbook = "MacBook"
    case applewatch = "Apple Watch"
    case airpods = "AirPods"
    case other = "Other"
    
    var displayName: String {
        return rawValue
    }
    
    var icon: String {
        switch self {
        case .iphone: return "iphone"
        case .ipad: return "ipad"
        case .macbook: return "laptopcomputer"
        case .applewatch: return "applewatch"
        case .airpods: return "airpods"
        case .other: return "device.phone.portrait"
        }
    }
} 