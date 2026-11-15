import Foundation
import AVFoundation
import UIKit
import CoreData

/// One short looping buffer bounds memory for every duration and avoids consumed-buffer callbacks.
final class WaterEjectionService: NSObject, ObservableObject {
    static let shared = WaterEjectionService()
    @Published private(set) var isPlaying = false
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var totalDuration: TimeInterval = 0
    @Published private(set) var currentSession: WaterEjectionSession?
    @Published private(set) var isRealtimeMode = false
    @Published private(set) var currentFrequency: Double = 0
    @Published private(set) var realtimeIntensity: Double = 50
    @Published var errorMessage: String?
    @Published private(set) var completedSessionID: UUID?
    @Published private(set) var lastCompletedDuration: TimeInterval = 0
    @Published private(set) var isSpeakerTest = false
    private var engine: AVAudioEngine?
    private var player: AVAudioPlayerNode?
    private var timer: Timer?
    private var startedAt: TimeInterval = 0
    private var currentDevice: DeviceType = .iphone
    private let coreDataService = CoreDataService.shared
    private var observers: [NSObjectProtocol] = []

    override init() {
        super.init()
        for name in [AVAudioSession.interruptionNotification, AVAudioSession.routeChangeNotification,
                     UIApplication.didEnterBackgroundNotification, AVAudioSession.mediaServicesWereResetNotification] {
            observers.append(NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                self?.stopEjection()
            })
        }
    }
    func startEjection(device: DeviceType, intensity: IntensityLevel, useSavedSettings: Bool = true) {
        guard !isPlaying else { return }
        currentDevice = device
        let defaults = UserDefaults.standard
        let custom = useSavedSettings && defaults.bool(forKey: "useCustomIntensity") && intensity != .realtime
        let customValue = defaults.double(forKey: "customIntensityValue")
        let savedDuration = defaults.double(forKey: "customDuration")
        let duration = custom && savedDuration.isFinite && savedDuration > 0 ? min(300, max(5, savedDuration)) : intensity.duration
        isRealtimeMode = intensity == .realtime
        let frequency: Double
        if isRealtimeMode { frequency = realtimeFrequency(realtimeIntensity) }
        else if custom && customValue.isFinite && customValue > 0 { frequency = baseFrequency * (0.5 + min(100, customValue) / 100 * 1.5) }
        else {
            let multipliers: [IntensityLevel: Double] = [.low: 0.8, .medium: 1, .high: 1.2, .emergency: 1.5]
            frequency = baseFrequency * (multipliers[intensity] ?? 1)
        }
        currentSession = WaterEjectionSession(deviceType: device, intensityLevel: intensity, duration: duration)
        begin(frequency: frequency, duration: duration, speakerTest: false)
    }
    func startSpeakerTest(frequency: Double, duration: TimeInterval = 10) {
        guard !isPlaying else { return }
        isRealtimeMode = false
        currentSession = nil
        begin(frequency: frequency, duration: duration, speakerTest: true)
    }
    private var baseFrequency: Double {
        switch currentDevice {
        case .iphone: return 165
        case .ipad: return 220
        case .macbook: return 440
        case .applewatch: return 880
        case .airpods: return 660
        case .other: return 330
        }
    }
    private func begin(frequency: Double, duration: TimeInterval, speakerTest: Bool) {
        guard frequency.isFinite, duration.isFinite else { currentSession = nil; return }
        errorMessage = nil
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
            // Route tones through this device's speaker; do not play into headphones or Bluetooth.
            guard session.currentRoute.outputs.allSatisfy({ $0.portType == .builtInSpeaker || $0.portType == .builtInReceiver }) else {
                throw AudioError.externalOutput
            }
            guard let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1) else { throw AudioError.unavailable }
            let engine = AVAudioEngine(), player = AVAudioPlayerNode()
            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: format)
            self.engine = engine; self.player = player
            try engine.start()
            try scheduleTone(frequency: frequency)
            totalDuration = min(300, max(1, duration))
            currentTime = 0; startedAt = ProcessInfo.processInfo.systemUptime
            isSpeakerTest = speakerTest; isPlaying = true
            UIApplication.shared.isIdleTimerDisabled = true
            player.play()
            GrowthMetrics.shared.record(speakerTest ? "speaker_test_started" : "session_started")
            timer = Timer(timeInterval: 0.2, repeats: true) { [weak self] _ in self?.tick() }
            if let timer { RunLoop.main.add(timer, forMode: .common) }
        } catch {
            cleanup()
            currentSession = nil; isRealtimeMode = false
            errorMessage = error.localizedDescription
            GrowthMetrics.shared.record("audio_start_failed")
        }
    }
    private func scheduleTone(frequency: Double) throws {
        let frequency = min(2000, max(50, frequency)).rounded()
        guard let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 44100),
              let samples = buffer.floatChannelData?[0] else { throw AudioError.unavailable }
        buffer.frameLength = 44100
        for frame in 0..<44100 {
            // Fade loop boundaries to avoid abrupt waveform transitions.
            let envelope = min(1, Double(min(frame, 44099 - frame)) / 220)
            samples[frame] = Float(0.25 * envelope * sin(2 * Double.pi * frequency * Double(frame) / 44100))
        }
        player?.stop()
        player?.scheduleBuffer(buffer, at: nil, options: .loops)
        currentFrequency = frequency
    }
    private func tick() {
        guard isPlaying else { return }
        currentTime = min(totalDuration, max(0, ProcessInfo.processInfo.systemUptime - startedAt))
        if currentTime >= totalDuration { completeEjection() }
    }
    func updateRealtimeFrequency(intensity: Double) {
        guard isPlaying, isRealtimeMode, intensity.isFinite else { return }
        realtimeIntensity = min(100, max(0, intensity))
        do { try scheduleTone(frequency: realtimeFrequency(realtimeIntensity)); player?.play() }
        catch { errorMessage = error.localizedDescription; stopEjection() }
    }
    private func realtimeFrequency(_ intensity: Double) -> Double { baseFrequency * (0.5 + intensity / 100 * 1.5) }
    func stopEjection() { finish(completed: false) }
    func completeEjection() { finish(completed: true) }
    private func finish(completed: Bool) {
        guard isPlaying else { return }
        let actual = min(totalDuration, max(0, ProcessInfo.processInfo.systemUptime - startedAt))
        let wasTest = isSpeakerTest
        let finishedID = currentSession?.id
        // Clear state before stopping AVAudioEngine, preventing reentrant completion.
        isPlaying = false
        cleanup()
        if var session = currentSession {
            session.endTime = Date(); session.duration = actual; session.isCompleted = completed
            coreDataService.saveWaterEjectionSession(session)
        }
        currentSession = nil; currentTime = 0; isRealtimeMode = false; currentFrequency = 0; isSpeakerTest = false
        GrowthMetrics.shared.record(wasTest ? (completed ? "speaker_test_completed" : "speaker_test_stopped") : (completed ? "session_completed" : "session_stopped"))
        if completed, !wasTest {
            lastCompletedDuration = actual
            completedSessionID = finishedID
        }
    }
    private func cleanup() {
        timer?.invalidate(); timer = nil
        player?.stop(); engine?.stop(); player = nil; engine = nil
        UIApplication.shared.isIdleTimerDisabled = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    func getSessionHistory() -> [WaterEjectionSession] { coreDataService.getWaterEjectionSessions() }
    func getSessionStats() -> SessionStats {
        let sessions = getSessionHistory()
        let duration = sessions.reduce(0) { $0 + $1.duration }
        return SessionStats(totalSessions: sessions.count, completedSessions: sessions.filter(\.isCompleted).count,
            totalDuration: duration, averageDuration: sessions.isEmpty ? 0 : duration / Double(sessions.count),
            deviceStats: Dictionary(grouping: sessions, by: \.deviceType).mapValues(\.count),
            intensityStats: Dictionary(grouping: sessions, by: \.intensityLevel).mapValues(\.count))
    }
    private enum AudioError: LocalizedError {
        case externalOutput, unavailable
        var errorDescription: String? {
            switch self {
            case .externalOutput: return "Disconnect headphones, Bluetooth or AirPlay before playing a tone. Audio plays through this device only."
            case .unavailable: return "Audio is unavailable. Please try again."
            }
        }
    }
}

struct SessionStats {
    let totalSessions: Int
    let completedSessions: Int
    let totalDuration: TimeInterval
    let averageDuration: TimeInterval
    let deviceStats: [DeviceType: Int]
    let intensityStats: [IntensityLevel: Int]
    
    var completionRate: Double {
        guard totalSessions > 0 else { return 0 }
        return Double(completedSessions) / Double(totalSessions)
    }
    
    var totalDurationMinutes: Double {
        return totalDuration / 60.0
    }
    
    var averageDurationMinutes: Double {
        return averageDuration / 60.0
    }
}