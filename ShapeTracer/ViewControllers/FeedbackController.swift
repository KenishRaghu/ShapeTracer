//
//  FeedbackController.swift
//  ShapeTracer
//
//  Created by Kenish Raghu on 6/6/25.
//  Manages all types of feedback (haptic, audio, visual)
//  Coordinates different feedback systems to provide smooth user experience
//

import Foundation
import SwiftUI

class FeedbackController: ObservableObject {
    @Published var isEnabled: Bool = true
    
    // Feedback managers
    private let hapticManager = HapticManager()
    private let soundManager = SoundManager()
    
    // State tracking
    private var lastFeedbackTime: Date = Date()
    private let feedbackCooldown: TimeInterval = 0.1 // Prevent overwhelming feedback
    
    // Prepare the feedback systems for a tracing session
    func prepareForTracing() {
        soundManager.prepareAudio()
        hapticManager.prepare()
    }
    
    // Provide feedback based on current tracing state
    func provideFeedback(_ feedbackTypes: [FeedbackType]) {
        // Respect cooldown to prevent overwhelming the user
        let now = Date()
        guard now.timeIntervalSince(lastFeedbackTime) >= feedbackCooldown else {
            return
        }
        
        // Only provide feedback if enabled
        guard isEnabled else {
            return
        }
        
        // Process each type of feedback
        for feedbackType in feedbackTypes {
            switch feedbackType {
            case .haptic(let intensity):
                hapticManager.provideFeedback(intensity: intensity)
                
            case .audio(let frequency):
                soundManager.playTone(frequency: frequency, duration: 0.2)
                
            case .visual:
                break
                
            case .none:
                break
            }
        }
        
        lastFeedbackTime = now
    }
    
    // Stop all ongoing feedback
    func stopAllFeedback() {
        soundManager.stopAllSounds()
    }
    
    // Toggle feedback on/off
    func toggleEnabled() {
        isEnabled.toggle()
        
        if !isEnabled {
            stopAllFeedback()
        }
    }
    
    // Clean up resources
    func cleanup() {
        stopAllFeedback()
        soundManager.cleanup()
    }
}

// Extension for testing feedback functionality
extension FeedbackController {
    // Test method to verify feedback triggering
    func testFeedbackTriggering(isOnPath: Bool, isAtVertex: Bool) -> [FeedbackType] {
        var feedbacks: [FeedbackType] = []
        
        if isOnPath {
            let intensity: HapticIntensity = isAtVertex ? .heavy : .medium
            feedbacks.append(.haptic(intensity: intensity))
            
            let frequency = isAtVertex ? 800.0 : 440.0
            feedbacks.append(.audio(frequency: frequency))
            feedbacks.append(.visual)
        }
        
        return feedbacks
    }
}
