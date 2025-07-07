import Foundation
import UserNotifications

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func scheduleDailyReminder(at time: Date) {
        let center = UNUserNotificationCenter.current()
        
        // Remove existing notifications
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Water Ejection Reminder"
        content.body = "Time to check your devices for water damage prevention!"
        content.sound = .default
        content.badge = 1
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    func scheduleEjectionCompleteNotification(device: DeviceType) {
        let content = UNMutableNotificationContent()
        content.title = "Ejection Complete"
        content.body = "Your \(device.rawValue) water ejection session has finished. Remember to let it dry completely!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "ejectionComplete", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleWeeklyTip() {
        let tips = [
            "Did you know? Most water damage occurs within the first 24 hours. Act quickly!",
            "Tip: Always remove cases and accessories before water ejection",
            "Remember: Let devices dry for at least 24 hours before charging",
            "Pro tip: Use silica gel packets to speed up drying process",
            "Safety first: Never use heat sources to dry electronics"
        ]
        
        let randomTip = tips.randomElement() ?? tips[0]
        
        let content = UNMutableNotificationContent()
        content.title = "Weekly Water Ejection Tip"
        content.body = randomTip
        content.sound = .default
        
        // Schedule for next week
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7 * 24 * 60 * 60, repeats: false)
        let request = UNNotificationRequest(identifier: "weeklyTip", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleCustomReminder(at time: Date) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Water Ejection Reminder"
        content.body = "Custom reminder: Time to check your devices!"
        content.sound = .default
        content.badge = 1
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        let identifier = "customReminder_\(components.hour ?? 0)_\(components.minute ?? 0)"
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule custom reminder: \(error)")
            }
        }
    }
    func cancelCustomReminder(at time: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        let identifier = "customReminder_\(components.hour ?? 0)_\(components.minute ?? 0)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
} 