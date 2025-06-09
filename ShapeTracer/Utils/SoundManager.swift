//
//  SoundManager.swift
//  ShapeTracer
//
//  Created by Kenish Raghu on 6/6/25.
//
//  Handles audio feedback using Core Audio
//  Generates tones at different frequencies for tracing feedback
//

import Foundation
import AVFoundation
import AudioToolbox

class SoundManager: ObservableObject {
    
    // Audio engine components
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var currentToneTimer: Timer?
    
    // Audio session setup
    func prepareAudio() {
        setupAudioSession()
        setupAudioEngine()
    }
    
    // Set up the audio session for playback
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    // Set up the audio engine for tone generation
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        
        guard let engine = audioEngine, let player = playerNode else {
            print("Failed to create audio components")
            return
        }
        
        // Attach player to engine
        engine.attach(player)
        
        // Get the main mixer and its format
        let mainMixer = engine.mainMixerNode
        let outputFormat = mainMixer.inputFormat(forBus: 0)
        
        // Connect player to main mixer with matching format
        engine.connect(player, to: mainMixer, format: outputFormat)
        
        // Start the audio engine
        do {
            try engine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    // Play a tone at the specified frequency
    func playTone(frequency: Double, duration: Double) {
        guard let player = playerNode, let engine = audioEngine else { return }
        
        // Stop any current tone
        stopCurrentTone()
        
        // Get the format from the engine's main mixer
        let mainMixer = engine.mainMixerNode
        let format = mainMixer.inputFormat(forBus: 0)
        
        let sampleRate = format.sampleRate
        let channelCount = format.channelCount
        let samples = Int(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(samples)) else {
            print("Failed to create audio buffer")
            return
        }
        
        // Fill buffer with sine wave
        buffer.frameLength = AVAudioFrameCount(samples)
        
        let amplitude: Float = 0.3 // Keep volume reasonable
        let twoPi = 2.0 * Float.pi
        let frequencyFloat = Float(frequency)
        
        // Handle both mono and stereo
        for channel in 0..<Int(channelCount) {
            let channelData = buffer.floatChannelData![channel]
            
            for i in 0..<samples {
                let time = Float(i) / Float(sampleRate)
                let sineValue = sin(twoPi * frequencyFloat * time)
                channelData[i] = amplitude * sineValue
            }
        }
        
        // Schedule and play the buffer
        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        
        if !player.isPlaying {
            player.play()
        }
        
        // Set up timer to stop the tone after duration
        currentToneTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.stopCurrentTone()
        }
    }
    
    // Stop the current tone
    private func stopCurrentTone() {
        currentToneTimer?.invalidate()
        currentToneTimer = nil
        
        playerNode?.stop()
    }
    
    // Stop all sounds
    func stopAllSounds() {
        stopCurrentTone()
        playerNode?.reset()
    }
    
    // Clean up audio resources
    func cleanup() {
        stopAllSounds()
        audioEngine?.stop()
        audioEngine = nil
        playerNode = nil
        
        // Deactivate audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
    
    deinit {
        cleanup()
    }
}

// Alternative simple implementation using system sounds (fallback)
extension SoundManager {
    
    // Play a simple system beep as fallback
    func playSystemBeep() {
        AudioServicesPlaySystemSound(1104) // This is a short beep sound
    }
    
    // Play different system sounds for different feedback types
    func playSystemFeedback(for feedbackType: SystemFeedbackType) {
        let soundID: SystemSoundID
        
        switch feedbackType {
        case .success:
            soundID = 1103 // Success sound
        case .error:
            soundID = 1102 // Error sound
        case .neutral:
            soundID = 1104 // Neutral beep
        }
        
        AudioServicesPlaySystemSound(soundID)
    }
}

enum SystemFeedbackType {
    case success
    case error
    case neutral
}
