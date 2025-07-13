/*
 * ============================================================================
 * INFINITUM WATER EJECT - WATCH APP WATER EJECTION SERVICE
 * ============================================================================
 * 
 * FILE: WaterEjectionService.swift
 * PURPOSE: Simplified water ejection service for Apple Watch
 * AUTHOR: Kevin Doyle Jr.
 * CREATED: [7/5/2025]
 * LAST MODIFIED: [7/9/2025]
 *
 * DESCRIPTION:
 * This file contains a simplified version of the water ejection service
 * specifically designed for Apple Watch. It includes only the essential
 * functionality needed for watchOS, with proper platform conditionals
 * and watchOS-specific optimizations.
 * 
 * ARCHITECTURE OVERVIEW:
 * - Simplified audio generation for watchOS
 * - Platform-specific conditionals for watchOS only
 * - Essential session management functionality
 * - Optimized for Apple Watch performance
 * 
 * KEY COMPONENTS:
 * 1. WaterEjectionService: Core ejection logic and audio management
 * 2. Session Management: Basic session tracking for Watch App
 * 3. Audio Generation: Simplified frequency generation for watchOS
 * 4. Platform Integration: watchOS-specific optimizations
 * 
 * DEPENDENCIES:
 * - Foundation: Core iOS framework for basic functionality
 * - AVFoundation: Audio generation and playback (watchOS compatible)
 * 
 * ============================================================================
 */

import Foundation
import AVFoundation

#if os(watchOS)
class WaterEjectionService: NSObject, ObservableObject {
    static let shared = WaterEjectionService()
    
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var totalDuration: TimeInterval = 0
    @Published var isRealtimeMode = false
    @Published var currentFrequency: Double = 0
    @Published var realtimeIntensity: Double = 50.0
    
    private var audioEngine: AVAudioEngine?
    private var audioPlayer: AVAudioPlayerNode?
    private var timer: Timer?
    private var startTime: Date?
    private var currentDevice: WatchDeviceType = .applewatch
    private var realtimeTimer: Timer?
    
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
    
    func startEjection(device: WatchDeviceType, intensity: WatchIntensityLevel) {
        guard !isPlaying else { return }
        
        currentDevice = device
        
        // Check if this is realtime mode
        if intensity == .realtime {
            isRealtimeMode = true
            totalDuration = intensity.duration
            
            startTime = Date()
            currentTime = 0
            isPlaying = true
            
            // Start realtime audio
            startRealtimeAudio()
            
            // Start timer
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.updateTimer()
            }
            return
        }
        
        totalDuration = intensity.duration
        startTime = Date()
        currentTime = 0
        isPlaying = true
        isRealtimeMode = false
        
        // Start audio
        playWaterEjectionAudio(device: device, intensity: intensity)
        
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
        
        // Reset state
        isPlaying = false
        currentTime = 0
        startTime = nil
        isRealtimeMode = false
        currentFrequency = 0
    }
    
    func completeEjection() {
        guard isPlaying else { return }
        
        // Stop audio
        stopAudio()
        
        // Stop timer
        timer?.invalidate()
        timer = nil
        
        // Reset state
        isPlaying = false
        currentTime = 0
        startTime = nil
        isRealtimeMode = false
        currentFrequency = 0
    }
    
    private func updateTimer() {
        guard let startTime = startTime else { return }
        
        currentTime = Date().timeIntervalSince(startTime)
        
        if currentTime >= totalDuration {
            completeEjection()
        }
    }
    
    private func getFrequency(for device: WatchDeviceType, intensity: WatchIntensityLevel) -> Double {
        // Base frequencies optimized for different devices
        let baseFrequencies: [WatchDeviceType: Double] = [
            .iphone: 165.0,    // E3 note - good for iPhone speakers
            .ipad: 220.0,      // A3 note - optimized for iPad speakers
            .macbook: 440.0,   // A4 note - good for MacBook speakers
            .applewatch: 880.0, // A5 note - high frequency for small speakers
            .airpods: 660.0,   // E5 note - optimized for AirPods
            .other: 330.0      // E4 note - general purpose
        ]
        
        let baseFrequency = baseFrequencies[device] ?? 440.0
        
        // Adjust frequency based on intensity
        let intensityMultiplier: [WatchIntensityLevel: Double] = [
            .low: 0.8,
            .medium: 1.0,
            .high: 1.2,
            .emergency: 1.5,
            .realtime: 1.0
        ]
        
        return baseFrequency * (intensityMultiplier[intensity] ?? 1.0)
    }
    
    private func playWaterEjectionAudio(device: WatchDeviceType, intensity: WatchIntensityLevel) {
        let frequency = getFrequency(for: device, intensity: intensity)
        currentFrequency = frequency
        
        // Create audio engine
        audioEngine = AVAudioEngine()
        audioPlayer = AVAudioPlayerNode()
        
        guard let audioEngine = audioEngine,
              let audioPlayer = audioPlayer else { return }
        
        audioEngine.attach(audioPlayer)
        audioEngine.connect(audioPlayer, to: audioEngine.mainMixerNode, format: nil)
        
        // Generate audio buffer
        let sampleRate: Double = 44100
        let duration = intensity.duration
        let frameCount = Int(sampleRate * duration)
        
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: AVAudioFrameCount(frameCount))!
        
        // Fill buffer with sine wave
        for frame in 0..<frameCount {
            let time = Double(frame) / sampleRate
            let amplitude = 0.3 // Reduced amplitude for watch
            let sample = amplitude * sin(2.0 * .pi * frequency * time)
            audioBuffer.floatChannelData![0][frame] = Float(sample)
        }
        
        audioBuffer.frameLength = AVAudioFrameCount(frameCount)
        
        // Play audio
        do {
            try audioEngine.start()
            audioPlayer.scheduleBuffer(audioBuffer, at: nil, options: .interrupts, completionHandler: nil)
            audioPlayer.play()
        } catch {
            print("Error playing audio: \(error)")
        }
    }
    
    private func startRealtimeAudio() {
        // Simplified realtime audio for watch
        let frequency = getFrequency(for: currentDevice, .medium)
        currentFrequency = frequency
        
        // Create audio engine
        audioEngine = AVAudioEngine()
        audioPlayer = AVAudioPlayerNode()
        
        guard let audioEngine = audioEngine,
              let audioPlayer = audioPlayer else { return }
        
        audioEngine.attach(audioPlayer)
        audioEngine.connect(audioPlayer, to: audioEngine.mainMixerNode, format: nil)
        
        // Generate short audio buffer for realtime
        let sampleRate: Double = 44100
        let bufferDuration: TimeInterval = 1.0 // 1 second buffer
        let frameCount = Int(sampleRate * bufferDuration)
        
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: AVAudioFrameCount(frameCount))!
        
        // Fill buffer with sine wave
        for frame in 0..<frameCount {
            let time = Double(frame) / sampleRate
            let amplitude = 0.2 // Reduced amplitude for watch
            let sample = amplitude * sin(2.0 * .pi * frequency * time)
            audioBuffer.floatChannelData![0][frame] = Float(sample)
        }
        
        audioBuffer.frameLength = AVAudioFrameCount(frameCount)
        
        // Play audio in loop
        do {
            try audioEngine.start()
            audioPlayer.scheduleBuffer(audioBuffer, at: nil, options: .loops, completionHandler: nil)
            audioPlayer.play()
        } catch {
            print("Error playing realtime audio: \(error)")
        }
    }
    
    private func stopAudio() {
        audioPlayer?.stop()
        audioEngine?.stop()
        audioPlayer = nil
        audioEngine = nil
        currentFrequency = 0
    }
}
#endif 