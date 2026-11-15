import XCTest
import AppIntents
@testable import Infinitum_Water_Eject

final class PlacementPolicyTests: XCTestCase {
    func testFirstSessionAndOddSessionsNeverShowFullScreen() {
        for count in [0, 1, 3, 5, 7] {
            XCTAssertFalse(AdPlacementPolicy.allows(completed: count, shownToday: 0, lastShown: nil, now: Date()))
        }
    }
    func testEverySecondSessionIsEligible() {
        for count in [2, 4, 6] {
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
