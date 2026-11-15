import XCTest
import AppIntents
import UserNotifications
import Combine
@testable import Infinitum_Water_Eject

final class PlacementPolicyTests: XCTestCase {
    func testNoCompletedCycleNeverShowsFullScreen() {
        XCTAssertFalse(AdPlacementPolicy.allows(completed: 0, shownToday: 0, lastShown: nil, now: Date()))
    }
    func testFirstAndLaterCompletedCyclesAreEligible() {
        for count in [1, 2, 3, 4, 6] {
            XCTAssertTrue(AdPlacementPolicy.allows(completed: count, shownToday: 0, lastShown: nil, now: Date()))
        }
    }
    func testDailyLimitAndCooldownBoundaries() {
        let now = Date()
        XCTAssertFalse(AdPlacementPolicy.allows(completed: 2, shownToday: 3, lastShown: nil, now: now))
        XCTAssertFalse(AdPlacementPolicy.allows(completed: 2, shownToday: 0, lastShown: now.addingTimeInterval(-179), now: now))
        XCTAssertTrue(AdPlacementPolicy.allows(completed: 2, shownToday: 2, lastShown: now.addingTimeInterval(-180), now: now))
        XCTAssertFalse(AdPlacementPolicy.allows(completed: 2, shownToday: 0, lastShown: now.addingTimeInterval(10), now: now))
    }
}

@MainActor
final class AudioRegressionTests: XCTestCase {
    override func tearDown() {
        WaterEjectionService.shared.stopEjection()
        WaterEjectionService.shared.errorMessage = nil
        super.tearDown()
    }
    func testBufferSchedulingDoesNotCompleteTheCycleEarly() async throws {
        let audio = WaterEjectionService.shared
        audio.startEjection(device: .iphone, intensity: .low, useSavedSettings: false)
        XCTAssertTrue(audio.isPlaying, audio.errorMessage ?? "Audio failed")
        try await Task.sleep(nanoseconds: 1_500_000_000)
        XCTAssertTrue(audio.isPlaying, "Scheduling or consuming the short buffer must not end a 30-second cycle")
        XCTAssertLessThan(audio.currentTime, 3)
        audio.stopEjection()
        XCTAssertFalse(audio.isPlaying)
    }
    func testEarlyCompletionRecordsActualDurationAndCannotDuplicate() async throws {
        let audio = WaterEjectionService.shared
        let before = audio.getSessionHistory().count
        audio.startEjection(device: .iphone, intensity: .medium, useSavedSettings: false)
        try await Task.sleep(nanoseconds: 500_000_000)
        audio.completeEjection()
        audio.completeEjection()
        let sessions = audio.getSessionHistory()
        XCTAssertEqual(sessions.count, before + 1)
        let session = try XCTUnwrap(sessions.first)
        XCTAssertTrue(session.isCompleted)
        XCTAssertLessThan(session.duration, 3)
        XCTAssertGreaterThan(session.duration, 0)
        CoreDataService.shared.deleteWaterEjectionSession(session)
    }
    func testSpeakerTestDoesNotCountAsWaterEjection() async throws {
        let audio = WaterEjectionService.shared
        let before = audio.getSessionHistory().count
        let completedID = audio.completedSessionID
        audio.startSpeakerTest(frequency: 440, duration: 1)
        XCTAssertTrue(audio.isPlaying)
        try await Task.sleep(nanoseconds: 1_500_000_000)
        XCTAssertFalse(audio.isPlaying)
        XCTAssertEqual(audio.getSessionHistory().count, before)
        XCTAssertEqual(audio.completedSessionID, completedID)
    }
    func testRapidRealtimeUpdatesStopCleanly() {
        let audio = WaterEjectionService.shared
        audio.startEjection(device: .iphone, intensity: .realtime, useSavedSettings: false)
        for value in stride(from: 0.0, through: 100, by: 5) { audio.updateRealtimeFrequency(intensity: value) }
        XCTAssertTrue(audio.isPlaying)
        XCTAssertEqual(audio.currentFrequency, 330)
        audio.stopEjection()
        XCTAssertFalse(audio.isPlaying)
        XCTAssertEqual(audio.currentFrequency, 0)
    }
    func testInvalidToneInputsDoNotStartAudio() {
        let audio = WaterEjectionService.shared
        audio.startSpeakerTest(frequency: .nan)
        XCTAssertFalse(audio.isPlaying)
        audio.startSpeakerTest(frequency: .infinity)
        XCTAssertFalse(audio.isPlaying)
    }
    func testPersistedCustomValuesAreBounded() {
        let d = UserDefaults.standard
        let keys = ["useCustomIntensity", "customIntensityValue", "customDuration"]
        let previous = keys.map { d.object(forKey: $0) }
        defer { for (key, value) in zip(keys, previous) { if let value { d.set(value, forKey: key) } else { d.removeObject(forKey: key) } } }
        d.set(true, forKey: keys[0]); d.set(1e12, forKey: keys[1]); d.set(1e12, forKey: keys[2])
        let audio = WaterEjectionService.shared
        audio.startEjection(device: .iphone, intensity: .medium)
        XCTAssertEqual(audio.totalDuration, 300)
        XCTAssertEqual(audio.currentFrequency, 330)
    }
    func testShortcutActionsStartAndStopTheFreeCycle() async throws {
        // A prior invalid-input test can leave its SwiftUI alert finishing dismissal.
        // The real intent correctly refuses to play over a presented controller.
        for _ in 0..<20 {
            if AdMobService.presenter?.presentedViewController == nil { break }
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        XCTAssertNil(AdMobService.presenter?.presentedViewController)
        _ = try await StartWaterEjectionIntent().perform()
        AppNavigation.shared.consumePendingAction(whenActive: true)
        let audio = WaterEjectionService.shared
        XCTAssertTrue(audio.isPlaying)
        XCTAssertEqual(audio.totalDuration, 30)
        _ = try await StopWaterEjectionIntent().perform()
        AppNavigation.shared.consumePendingAction(whenActive: true)
        XCTAssertFalse(audio.isPlaying)
        _ = try await OpenSpeakerToolsIntent().perform()
        AppNavigation.shared.consumePendingAction(whenActive: true)
        XCTAssertEqual(AppNavigation.shared.selectedTab, 1)
    }
    func testUnknownDeepLinkDoesNotStartAudio() {
        AppNavigation.shared.handle(URL(string: "infinitumwatereject://unknown")!)
        XCTAssertFalse(WaterEjectionService.shared.isPlaying)
    }
}


@MainActor
final class PolishRegressionTests: XCTestCase {
    func testReadingDefaultSettingsDoesNotWriteOrPublish() {
        let store = CoreDataService(inMemory: true)
        var updates = 0
        let subscription = store.objectWillChange.sink { updates += 1 }
        _ = store.userSettings
        _ = store.userSettings
        XCTAssertFalse(store.context.hasChanges)
        XCTAssertEqual(updates, 0)
        withExtendedLifetime(subscription) {}
    }

    func testDeletingHistoryKeepsPreferencesAndRestoresEndTimes() throws {
        let store = CoreDataService(inMemory: true)
        var preferences = try XCTUnwrap(store.userSettings)
        preferences.notificationsEnabled = false
        preferences.weeklyGoal = 17
        store.saveUserSettings(preferences)
        let start = Date(timeIntervalSince1970: 1700000000)
        store.saveWaterEjectionSession(WaterEjectionSession(duration: 12.5, startTime: start, isCompleted: false))
        let saved = try XCTUnwrap(store.getWaterEjectionSessions().first)
        XCTAssertEqual(saved.endTime, start.addingTimeInterval(12.5))
        try store.deleteSessionHistory()
        XCTAssertTrue(store.getWaterEjectionSessions().isEmpty)
        XCTAssertEqual(store.userSettings?.weeklyGoal, 17)
        XCTAssertEqual(store.userSettings?.notificationsEnabled, false)
    }
    func testHistoryMeansLastThirtyDaysRatherThanCalendarMonth() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let now = calendar.date(from: DateComponents(year: 2026, month: 3, day: 2, hour: 12))!
        let days = [-31, -30, -29, -1, 0, 1]
        let sessions = days.map { WaterEjectionSession(startTime: calendar.date(byAdding: .day, value: $0, to: now)!) }
        XCTAssertEqual(HistoryFilter.month.apply(to: sessions, now: now, calendar: calendar).map(\.id), [sessions[4], sessions[3], sessions[2], sessions[1]].map(\.id))
    }
    func testRemindersDeduplicateSameClockMinuteAndDoNotSetBadges() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let daily = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1, hour: 9, minute: 15))!
        let duplicate = daily.addingTimeInterval(86400 + 20)
        let other = daily.addingTimeInterval(3600)
        let requests = NotificationService.requests(daily: daily, custom: [duplicate, other, other], calendar: calendar)
        XCTAssertEqual(requests.count, 2)
        XCTAssertEqual(requests.first?.identifier, "dailyReminder")
        for request in requests {
            let trigger = try XCTUnwrap(request.trigger as? UNCalendarNotificationTrigger)
            XCTAssertTrue(trigger.repeats)
            XCTAssertEqual(trigger.dateComponents.minute, 15)
            XCTAssertNil(request.content.badge)
        }
    }
    func testManualSeasonalThemeSurvivesRelaunchAndAutomaticCanBeDisabled() throws {
        let suite = "PolishTests." + UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let manager = HolidayThemeManager(defaults: defaults)
        let service = ThemeService(themeManager: manager)
        var updates = 0
        let subscription = service.objectWillChange.sink { updates += 1 }
        service.setTheme(.christmas)
        XCTAssertGreaterThan(updates, 0)
        XCTAssertEqual(HolidayThemeManager(defaults: defaults).currentTheme.type, HolidayTheme.christmas.type)
        XCTAssertFalse(HolidayThemeManager(defaults: defaults).isAutomaticThemeEnabled)
        service.enableAutomaticTheme()
        service.setAutomaticThemeEnabled(false)
        XCTAssertFalse(HolidayThemeManager(defaults: defaults).isAutomaticThemeEnabled)
        withExtendedLifetime(subscription) {}
    }
    func testCSVHasStableDecimalsEscapingAndEndTimestamp() {
        let start = Date(timeIntervalSince1970: 1700000000)
        let session = WaterEjectionSession(duration: 12.5, startTime: start, endTime: start.addingTimeInterval(12.5), isCompleted: true)
        let csv = SessionHistoryExport.csv([session])
        XCTAssertTrue(csv.contains(",12.5,2023-11-14T22:13:20Z,2023-11-14T22:13:32Z,Yes"))
        XCTAssertTrue(csv.hasSuffix("\r\n"))
        XCTAssertEqual(SessionHistoryExport.escape("a,\"b\""), "\"a,\"\"b\"\"\"")
    }
    func testCorruptPresetValuesAreSafeToRenderAndPlay() {
        XCTAssertEqual(TonePreset.boundedFrequency(.nan), 165)
        XCTAssertEqual(TonePreset.boundedFrequency(.infinity), 165)
        XCTAssertEqual(TonePreset.boundedFrequency(1e300), 2000)
        XCTAssertEqual(TonePreset.boundedFrequency(-1e300), 50)
    }
    func testSavedCustomToneCanUseZeroPosition() {
        let defaults = UserDefaults.standard
        let keys = ["useCustomIntensity", "customIntensityValue", "customDuration"]
        let previous = keys.map { defaults.object(forKey: $0) }
        defer {
            WaterEjectionService.shared.stopEjection()
            for (key, value) in zip(keys, previous) {
                if let value { defaults.set(value, forKey: key) } else { defaults.removeObject(forKey: key) }
            }
        }
        defaults.set(true, forKey: keys[0]); defaults.set(0.0, forKey: keys[1]); defaults.set(10.0, forKey: keys[2])
        let audio = WaterEjectionService.shared
        audio.startEjection(device: .iphone, intensity: .medium)
        XCTAssertTrue(audio.isPlaying)
        XCTAssertEqual(audio.currentFrequency, 82.5, accuracy: 0.6)
        XCTAssertEqual(audio.totalDuration, 10)
        audio.stopEjection()
        defaults.removeObject(forKey: "customIntensityValue")
        audio.startEjection(device: .iphone, intensity: .medium)
        XCTAssertEqual(audio.currentFrequency, 206.25, accuracy: 0.6, "An absent value uses the picker’s default position, not zero")
    }
}
