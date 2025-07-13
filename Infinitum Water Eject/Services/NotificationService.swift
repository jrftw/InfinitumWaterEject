/*
 * ============================================================================
 * INFINITUM WATER EJECT - NOTIFICATION SERVICE
 * ============================================================================
 * 
 * FILE: NotificationService.swift
 * PURPOSE: Manages local notifications and user notification permissions
 * AUTHOR: Kevin Doyle Jr.
 * CREATED: [7/5/2025]
 * LAST MODIFIED: [7/9/2025]
 *
 * DESCRIPTION:
 * This file contains the notification service implementation for the Infinitum
 * Water Eject application. It manages all local notifications including daily
 * reminders, session completion notifications, weekly tips, and custom reminders.
 * The service handles notification permissions, scheduling, and cancellation
 * with comprehensive error handling and user-friendly notification content.
 * 
 * ARCHITECTURE OVERVIEW:
 * - NotificationService: Singleton service managing all notification operations
 * - Permission Management: Handles notification permission requests and status
 * - Daily Reminders: Scheduled daily notifications for water ejection reminders
 * - Session Notifications: Immediate notifications for completed ejection sessions
 * - Weekly Tips: Educational notifications with rotating water safety tips
 * - Custom Reminders: User-defined notification scheduling and management
 * - Notification Cancellation: Comprehensive notification removal capabilities
 * 
 * KEY COMPONENTS:
 * 1. Permission Request: Handles notification permission requests from users
 * 2. Daily Reminder System: Scheduled daily notifications at user-specified times
 * 3. Session Completion Notifications: Immediate feedback for completed sessions
 * 4. Weekly Tip System: Educational notifications with rotating content
 * 5. Custom Reminder Management: User-defined notification scheduling
 * 6. Notification Cleanup: Comprehensive notification cancellation methods
 * 
 * NOTIFICATION TYPES:
 * - Daily Reminders: Regular water ejection check reminders
 * - Session Complete: Immediate feedback when ejection sessions finish
 * - Weekly Tips: Educational content about water damage prevention
 * - Custom Reminders: User-defined notification schedules
 * 
 * PERMISSION HANDLING:
 * - Requests alert, badge, and sound permissions
 * - Provides error handling for permission requests
 * - Logs permission status for debugging
 * 
 * DEPENDENCIES:
 * - Foundation: Core iOS framework for basic functionality
 * - UserNotifications: Apple's local notification framework
 * 
 * TODO LIST:
 * - [ ] Add notification categories for different notification types
 * - [ ] Implement notification actions for quick responses
 * - [ ] Add notification analytics and user engagement tracking
 * - [ ] Create notification preferences management
 * - [ ] Implement smart notification timing based on user behavior
 * - [ ] Add notification content localization for multiple languages
 * - [ ] Create notification frequency capping to prevent spam
 * - [ ] Implement notification priority levels
 * 
 * FEATURE SUGGESTIONS:
 * - [ ] Add notification templates for different device types
 * - [ ] Implement notification scheduling based on weather conditions
 * - [ ] Create notification grouping for related notifications
 * - [ ] Add notification sound customization options
 * - [ ] Implement notification delivery confirmation
 * - [ ] Create notification history and management interface
 * - [ ] Add notification sharing between users
 * - [ ] Implement notification backup and restore functionality
 * 
 * TECHNICAL NOTES:
 * - Uses singleton pattern for global notification access
 * - Implements proper error handling for all notification operations
 * - Provides comprehensive notification management capabilities
 * - Uses UNUserNotificationCenter for all notification operations
 * - Implements proper notification identifier management
 * - Follows iOS notification best practices and guidelines
 * 
 * ============================================================================
 */

import Foundation
import UserNotifications

// MARK: - Notification Service Class
// Singleton service class that manages all local notification functionality
// Handles permissions, scheduling, and notification lifecycle management

class NotificationService: ObservableObject {
    // MARK: - Singleton Instance
    // Shared instance for global access to notification functionality
    static let shared = NotificationService()
    
    // MARK: - Private Initialization
    // Private initializer for singleton pattern
    
    /// Private initializer for singleton pattern
    /// Ensures only one instance of the notification service exists
    private init() {}
    
    // MARK: - Permission Management
    // Handles notification permission requests and status
    
    /// Requests notification permissions from the user
    /// Requests alert, badge, and sound permissions with error handling
    func requestPermission() {
        // MARK: - Permission Request
        // Request notification permissions with comprehensive options
        // Includes alert, badge, and sound permissions for full functionality
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")  // Log successful permission grant
            } else if let error = error {
                print("Notification permission error: \(error)")  // Log permission errors
            }
        }
    }
    
    // MARK: - Daily Reminder Scheduling
    // Schedules daily water ejection reminder notifications
    
    /// Schedules a daily reminder notification at the specified time
    /// Removes existing notifications and creates new daily reminder
    func scheduleDailyReminder(at time: Date) {
        // MARK: - Notification Center Setup
        // Get the current notification center for scheduling
        let center = UNUserNotificationCenter.current()
        
        // MARK: - Existing Notification Cleanup
        // Remove all existing pending notifications to prevent duplicates
        center.removeAllPendingNotificationRequests()
        
        // MARK: - Notification Content Creation
        // Create notification content with title, body, sound, and badge
        let content = UNMutableNotificationContent()
        content.title = "Water Ejection Reminder"
        content.body = "Time to check your devices for water damage prevention!"
        content.sound = .default
        content.badge = 1
        
        // MARK: - Time Component Extraction
        // Extract hour and minute components from the specified time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        // MARK: - Notification Trigger Creation
        // Create calendar-based trigger that repeats daily
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        // MARK: - Notification Scheduling
        // Schedule the notification with error handling
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")  // Log scheduling errors
            }
        }
    }
    
    // MARK: - Session Completion Notifications
    // Schedules immediate notifications for completed water ejection sessions
    
    /// Schedules an immediate notification when a water ejection session completes
    /// Provides user feedback and drying reminder for the specific device
    func scheduleEjectionCompleteNotification(device: DeviceType) {
        // MARK: - Notification Content Setup
        // Create notification content specific to session completion
        let content = UNMutableNotificationContent()
        content.title = "Ejection Complete"
        content.body = "Your \(device.rawValue) water ejection session has finished. Remember to let it dry completely!"
        content.sound = .default
        
        // MARK: - Immediate Trigger Creation
        // Create trigger for immediate notification delivery
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "ejectionComplete", content: content, trigger: trigger)
        
        // MARK: - Notification Scheduling
        // Schedule the immediate notification
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Weekly Tip Notifications
    // Schedules educational weekly notifications with rotating tips
    
    /// Schedules a weekly educational notification with rotating water safety tips
    /// Provides valuable information about water damage prevention
    func scheduleWeeklyTip() {
        // MARK: - Tip Content Array
        // Collection of educational tips about water damage prevention
        // Rotates randomly to provide variety in educational content
        let tips = [
            "Did you know? Most water damage occurs within the first 24 hours. Act quickly!",
            "Tip: Always remove cases and accessories before water ejection",
            "Remember: Let devices dry for at least 24 hours before charging",
            "Pro tip: Use silica gel packets to speed up drying process",
            "Safety first: Never use heat sources to dry electronics"
        ]
        
        // MARK: - Random Tip Selection
        // Select a random tip from the array for variety
        let randomTip = tips.randomElement() ?? tips[0]
        
        // MARK: - Notification Content Creation
        // Create notification content with educational tip
        let content = UNMutableNotificationContent()
        content.title = "Weekly Water Ejection Tip"
        content.body = randomTip
        content.sound = .default
        
        // MARK: - Weekly Trigger Creation
        // Schedule notification for next week (7 days from now)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7 * 24 * 60 * 60, repeats: false)
        let request = UNNotificationRequest(identifier: "weeklyTip", content: content, trigger: trigger)
        
        // MARK: - Notification Scheduling
        // Schedule the weekly tip notification
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Custom Reminder Management
    // Handles user-defined custom reminder notifications
    
    /// Schedules a custom reminder notification at the specified time
    /// Creates unique identifier based on time components for management
    func scheduleCustomReminder(at time: Date) {
        // MARK: - Notification Center and Content Setup
        // Get notification center and create notification content
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Water Ejection Reminder"
        content.body = "Custom reminder: Time to check your devices!"
        content.sound = .default
        content.badge = 1
        
        // MARK: - Time Component Extraction
        // Extract hour and minute for identifier creation
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        // MARK: - Unique Identifier Creation
        // Create unique identifier based on time for precise management
        let identifier = "customReminder_\(components.hour ?? 0)_\(components.minute ?? 0)"
        
        // MARK: - Trigger and Request Creation
        // Create calendar trigger and notification request
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // MARK: - Notification Scheduling with Error Handling
        // Schedule custom reminder with comprehensive error handling
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule custom reminder: \(error)")  // Log scheduling errors
            }
        }
    }
    
    // MARK: - Custom Reminder Cancellation
    // Cancels specific custom reminder notifications
    
    /// Cancels a custom reminder notification at the specified time
    /// Uses time-based identifier for precise cancellation targeting
    func cancelCustomReminder(at time: Date) {
        // MARK: - Time Component Extraction
        // Extract hour and minute components for identifier recreation
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        // MARK: - Identifier Recreation
        // Recreate the unique identifier used for scheduling
        let identifier = "customReminder_\(components.hour ?? 0)_\(components.minute ?? 0)"
        
        // MARK: - Notification Cancellation
        // Remove the specific custom reminder notification
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // MARK: - Complete Notification Cleanup
    // Removes all pending notifications from the system
    
    /// Cancels all pending notifications from the notification center
    /// Provides complete notification cleanup functionality
    func cancelAllNotifications() {
        // MARK: - All Notifications Removal
        // Remove all pending notification requests from the system
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
} 
