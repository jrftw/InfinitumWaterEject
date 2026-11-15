import Foundation
import UserNotifications

final class NotificationService: ObservableObject {
    static let shared = NotificationService()
    private let center = UNUserNotificationCenter.current()

    func requestPermission() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound])
    }
    func isAuthorized() async -> Bool {
        let status = await center.notificationSettings().authorizationStatus
        return status == .authorized || status == .provisional || status == .ephemeral
    }
    func replaceReminders(daily: Date, custom: [Date]) async throws {
        guard await isAuthorized() else { throw ReminderError.permissionDenied }
        cancelAllNotifications()
        do {
            for request in Self.requests(daily: daily, custom: custom) { try await center.add(request) }
        } catch {
            cancelAllNotifications()
            throw error
        }
    }
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        Task { try? await center.setBadgeCount(0) }
    }
    static func requests(daily: Date, custom: [Date], calendar: Calendar = .current) -> [UNNotificationRequest] {
        var seen = Set<Int>()
        return ([daily] + Array(custom.prefix(10))).enumerated().compactMap { index, time in
            let components = calendar.dateComponents([.hour, .minute], from: time)
            let minute = (components.hour ?? 0) * 60 + (components.minute ?? 0)
            guard seen.insert(minute).inserted else { return nil }
            let content = UNMutableNotificationContent()
            content.title = "Speaker tools reminder"
            content.body = "Your optional reminder: open speaker tools if you need them. Daily tone cycles are not required."
            content.sound = .default
            return UNNotificationRequest(identifier: index == 0 ? "dailyReminder" : "customReminder_\(minute)",
                content: content, trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: true))
        }
    }
    enum ReminderError: LocalizedError {
        case permissionDenied
        var errorDescription: String? { "Notifications are turned off. Allow notifications in iOS Settings to receive reminders." }
    }
}
