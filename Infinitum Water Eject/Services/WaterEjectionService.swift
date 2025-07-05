import Foundation
import AVFoundation
import CoreData

class WaterEjectionService: NSObject, ObservableObject {
    static let shared = WaterEjectionService()
    
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var totalDuration: TimeInterval = 0
    @Published var currentSession: WaterEjectionSession?
    
    private var audioEngine: AVAudioEngine?
    private var audioPlayer: AVAudioPlayerNode?
    private var timer: Timer?
    private var startTime: Date?
    
    private let coreDataService = CoreDataService.shared
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func startEjection(device: DeviceType, intensity: IntensityLevel) {
        guard !isPlaying else { return }
        
        // Check if custom intensity is being used
        let useCustomIntensity = UserDefaults.standard.bool(forKey: "useCustomIntensity")
        let customIntensityValue = UserDefaults.standard.double(forKey: "customIntensityValue")
        let customDuration = UserDefaults.standard.double(forKey: "customDuration")
        
        // Calculate duration based on intensity or custom values
        let duration: TimeInterval
        let effectiveIntensity: IntensityLevel
        
        if useCustomIntensity && customIntensityValue > 0 && customDuration > 0 {
            duration = customDuration
            effectiveIntensity = intensity // We'll use custom values for frequency calculation
        } else {
            duration = intensity.duration
            effectiveIntensity = intensity
        }
        
        totalDuration = duration
        
        // Create session
        let session = WaterEjectionSession(
            deviceType: device,
            intensityLevel: intensity,
            duration: duration,
            startTime: Date(),
            endTime: nil,
            isCompleted: false
        )
        
        currentSession = session
        startTime = Date()
        currentTime = 0
        isPlaying = true
        
        // Start audio with custom or preset values
        if useCustomIntensity && customIntensityValue > 0 {
            playWaterEjectionAudio(device: device, customIntensity: customIntensityValue, duration: duration)
        } else {
            playWaterEjectionAudio(device: device, intensity: effectiveIntensity)
        }
        
        // Start timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    func stopEjection() {
        guard isPlaying else { return }
        
        // Stop audio
        stopAudio()
        
        // Stop timer
        timer?.invalidate()
        timer = nil
        
        // Update session
        if var session = currentSession {
            session.endTime = Date()
            session.isCompleted = false
            session.duration = currentTime
            
            // Save to Core Data
            coreDataService.saveWaterEjectionSession(session)
        }
        
        // Reset state
        isPlaying = false
        currentTime = 0
        currentSession = nil
        startTime = nil
    }
    
    func completeEjection() {
        guard isPlaying else { return }
        
        // Stop audio
        stopAudio()
        
        // Stop timer
        timer?.invalidate()
        timer = nil
        
        // Update session
        if var session = currentSession {
            session.endTime = Date()
            session.isCompleted = true
            session.duration = totalDuration
            
            // Save to Core Data
            coreDataService.saveWaterEjectionSession(session)
        }
        
        // Reset state
        isPlaying = false
        currentTime = 0
        currentSession = nil
        startTime = nil
    }
    
    private func updateTimer() {
        guard let startTime = startTime else { return }
        
        currentTime = Date().timeIntervalSince(startTime)
        
        if currentTime >= totalDuration {
            completeEjection()
        }
    }
    
    private func getFrequency(for device: DeviceType, intensity: IntensityLevel) -> Double {
        // Base frequencies optimized for different devices
        let baseFrequencies: [DeviceType: Double] = [
            .iphone: 165.0,    // E3 note - good for iPhone speakers
            .ipad: 220.0,      // A3 note - optimized for iPad speakers
            .macbook: 440.0,   // A4 note - good for MacBook speakers
            .applewatch: 880.0, // A5 note - high frequency for small speakers
            .airpods: 660.0,   // E5 note - optimized for AirPods
            .other: 330.0      // E4 note - general purpose
        ]
        
        let baseFrequency = baseFrequencies[device] ?? 330.0
        
        // Adjust frequency based on intensity
        let intensityMultipliers: [IntensityLevel: Double] = [
            .low: 0.8,
            .medium: 1.0,
            .high: 1.2,
            .emergency: 1.5
        ]
        
        let multiplier = intensityMultipliers[intensity] ?? 1.0
        return baseFrequency * multiplier
    }
    
    private func playWaterEjectionAudio(device: DeviceType, intensity: IntensityLevel) {
        let frequency = getFrequency(for: device, intensity: intensity)
        let sampleRate: Double = 44100
        let duration = intensity.duration
        
        // Generate audio buffer
        let frameCount = Int(sampleRate * duration)
        let audioBuffer = AVAudioPCMBuffer(pcmFormat: AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!, frameCapacity: AVAudioFrameCount(frameCount))!
        
        // Fill buffer with sine wave
        if let channelData = audioBuffer.floatChannelData?[0] {
            for frame in 0..<frameCount {
                let time = Double(frame) / sampleRate
                let amplitude: Float = 0.3 // Safe volume level
                
                // Create a sine wave with the calculated frequency
                let sample = amplitude * Float(sin(2.0 * Double.pi * frequency * time))
                // Add some variation to make it more effective
                let variation = Float(sin(2.0 * Double.pi * 0.5 * time)) * 0.1
                let finalSample = sample + variation
                channelData[frame] = finalSample
            }
        }
        
        audioBuffer.frameLength = AVAudioFrameCount(frameCount)
        
        // Setup audio engine
        audioEngine = AVAudioEngine()
        audioPlayer = AVAudioPlayerNode()
        
        guard let audioEngine = audioEngine,
              let audioPlayer = audioPlayer else { return }
        
        audioEngine.attach(audioPlayer)
        audioEngine.connect(audioPlayer, to: audioEngine.mainMixerNode, format: audioBuffer.format)
        
        do {
            try audioEngine.start()
            audioPlayer.scheduleBuffer(audioBuffer, at: nil, options: .interrupts, completionHandler: { [weak self] in
                DispatchQueue.main.async {
                    self?.completeEjection()
                }
            })
            audioPlayer.play()
        } catch {
            print("Failed to start audio: \(error)")
            stopEjection()
        }
    }
    
    private func playWaterEjectionAudio(device: DeviceType, customIntensity: Double, duration: TimeInterval) {
        // Get base frequency for the device
        let baseFrequencies: [DeviceType: Double] = [
            .iphone: 165.0,    // E3 note - good for iPhone speakers
            .ipad: 220.0,      // A3 note - optimized for iPad speakers
            .macbook: 440.0,   // A4 note - good for MacBook speakers
            .applewatch: 880.0, // A5 note - high frequency for small speakers
            .airpods: 660.0,   // E5 note - optimized for AirPods
            .other: 330.0      // E4 note - general purpose
        ]
        
        let baseFrequency = baseFrequencies[device] ?? 330.0
        
        // Calculate custom frequency multiplier based on intensity percentage
        // Map 0-100% to 0.5-2.0 multiplier range
        let intensityMultiplier = 0.5 + (customIntensity / 100.0) * 1.5
        let frequency = baseFrequency * intensityMultiplier
        
        let sampleRate: Double = 44100
        
        // Generate audio buffer
        let frameCount = Int(sampleRate * duration)
        let audioBuffer = AVAudioPCMBuffer(pcmFormat: AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!, frameCapacity: AVAudioFrameCount(frameCount))!
        
        // Fill buffer with sine wave
        if let channelData = audioBuffer.floatChannelData?[0] {
            for frame in 0..<frameCount {
                let time = Double(frame) / sampleRate
                let amplitude: Float = 0.3 // Safe volume level
                
                // Create a sine wave with the calculated frequency
                let sample = amplitude * Float(sin(2.0 * Double.pi * frequency * time))
                // Add some variation to make it more effective
                let variation = Float(sin(2.0 * Double.pi * 0.5 * time)) * 0.1
                let finalSample = sample + variation
                channelData[frame] = finalSample
            }
        }
        
        audioBuffer.frameLength = AVAudioFrameCount(frameCount)
        
        // Setup audio engine
        audioEngine = AVAudioEngine()
        audioPlayer = AVAudioPlayerNode()
        
        guard let audioEngine = audioEngine,
              let audioPlayer = audioPlayer else { return }
        
        audioEngine.attach(audioPlayer)
        audioEngine.connect(audioPlayer, to: audioEngine.mainMixerNode, format: audioBuffer.format)
        
        do {
            try audioEngine.start()
            audioPlayer.scheduleBuffer(audioBuffer, at: nil, options: .interrupts, completionHandler: { [weak self] in
                DispatchQueue.main.async {
                    self?.completeEjection()
                }
            })
            audioPlayer.play()
        } catch {
            print("Failed to start audio: \(error)")
            stopEjection()
        }
    }
    
    private func stopAudio() {
        audioPlayer?.stop()
        audioEngine?.stop()
        audioPlayer = nil
        audioEngine = nil
    }
    
    func getSessionHistory() -> [WaterEjectionSession] {
        return coreDataService.getWaterEjectionSessions()
    }
    
    func getSessionStats() -> SessionStats {
        let sessions = getSessionHistory()
        
        let totalSessions = sessions.count
        let completedSessions = sessions.filter { $0.isCompleted }.count
        let totalDuration = sessions.reduce(0) { $0 + $1.duration }
        let averageDuration = totalSessions > 0 ? totalDuration / Double(totalSessions) : 0
        
        let deviceStats = Dictionary(grouping: sessions, by: { $0.deviceType })
            .mapValues { $0.count }
        
        let intensityStats = Dictionary(grouping: sessions, by: { $0.intensityLevel })
            .mapValues { $0.count }
        
        return SessionStats(
            totalSessions: totalSessions,
            completedSessions: completedSessions,
            totalDuration: totalDuration,
            averageDuration: averageDuration,
            deviceStats: deviceStats,
            intensityStats: intensityStats
        )
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