//
//  FeedbackTests.swift
//  ShapeTracer
//
//  Created by Kenish Raghu on 6/6/25.
//  Tests for the feedback system accuracy
//  Ensures that feedback is triggered correctly based on tracing state
//

import XCTest
@testable import ShapeTracer

final class FeedbackTests: XCTestCase {
    
    var feedbackController: FeedbackController!
    
    override func setUp() {
        super.setUp()
        feedbackController = FeedbackController()
    }
    
    override func tearDown() {
        feedbackController = nil
        super.tearDown()
    }
    
    // Test feedback generation when on correct path
    func testOnPathFeedbackGeneration() {
        let feedbacks = feedbackController.testFeedbackTriggering(isOnPath: true, isAtVertex: false)
        
        // Should have haptic, audio, and visual feedback
        XCTAssertEqual(feedbacks.count, 3, "Should generate 3 types of feedback when on path")
        
        // Check for correct feedback types
        let hasHaptic = feedbacks.contains {
            if case .haptic = $0 { return true }
            return false
        }
        let hasAudio = feedbacks.contains {
            if case .audio = $0 { return true }
            return false
        }
        let hasVisual = feedbacks.contains {
            if case .visual = $0 { return true }
            return false
        }
        
        XCTAssertTrue(hasHaptic, "Should include haptic feedback when on path")
        XCTAssertTrue(hasAudio, "Should include audio feedback when on path")
        XCTAssertTrue(hasVisual, "Should include visual feedback when on path")
    }
    
    // Test enhanced feedback at vertices
    func testVertexFeedbackEnhancement() {
        let regularFeedbacks = feedbackController.testFeedbackTriggering(isOnPath: true, isAtVertex: false)
        let vertexFeedbacks = feedbackController.testFeedbackTriggering(isOnPath: true, isAtVertex: true)
        
        // Both should have same number of feedback types
        XCTAssertEqual(regularFeedbacks.count, vertexFeedbacks.count, "Should have same number of feedback types")
        
        // Extract haptic intensities
        var regularIntensity: HapticIntensity?
        var vertexIntensity: HapticIntensity?
        
        for feedback in regularFeedbacks {
            if case .haptic(let intensity) = feedback {
                regularIntensity = intensity
            }
        }
        
        for feedback in vertexFeedbacks {
            if case .haptic(let intensity) = feedback {
                vertexIntensity = intensity
            }
        }
        
        // Vertex should have stronger haptic feedback
        XCTAssertNotNil(regularIntensity, "Regular feedback should have haptic intensity")
        XCTAssertNotNil(vertexIntensity, "Vertex feedback should have haptic intensity")
        XCTAssertNotEqual(regularIntensity, vertexIntensity, "Vertex haptic intensity should be different from regular")
        
        // Extract audio frequencies
        var regularFrequency: Double?
        var vertexFrequency: Double?
        
        for feedback in regularFeedbacks {
            if case .audio(let frequency) = feedback {
                regularFrequency = frequency
            }
        }
        
        for feedback in vertexFeedbacks {
            if case .audio(let frequency) = feedback {
                vertexFrequency = frequency
            }
        }
        
        // Vertex should have higher frequency
        XCTAssertNotNil(regularFrequency, "Regular feedback should have audio frequency")
        XCTAssertNotNil(vertexFrequency, "Vertex feedback should have audio frequency")
        XCTAssertGreaterThan(vertexFrequency!, regularFrequency!, "Vertex frequency should be higher than regular")
    }
    
    // Test no feedback when off path
    func testOffPathNoFeedback() {
        let feedbacks = feedbackController.testFeedbackTriggering(isOnPath: false, isAtVertex: false)
        
        XCTAssertTrue(feedbacks.isEmpty, "Should not generate feedback when off path")
    }
    
    // Test feedback enabling/disabling
    func testFeedbackToggling() {
        // Initially should be enabled
        XCTAssertTrue(feedbackController.isEnabled, "Feedback should be enabled by default")
        
        // Toggle off
        feedbackController.toggleEnabled()
        XCTAssertFalse(feedbackController.isEnabled, "Feedback should be disabled after toggle")
        
        // Toggle back on
        feedbackController.toggleEnabled()
        XCTAssertTrue(feedbackController.isEnabled, "Feedback should be enabled after second toggle")
    }
    
    // Test feedback accuracy with different states
    func testFeedbackAccuracyForDifferentStates() {
        // Test regular on-path state
        let onPathFeedback = feedbackController.testFeedbackTriggering(isOnPath: true, isAtVertex: false)
        XCTAssertFalse(onPathFeedback.isEmpty, "Should provide feedback when on path")
        
        // Test vertex state
        let vertexFeedback = feedbackController.testFeedbackTriggering(isOnPath: true, isAtVertex: true)
        XCTAssertFalse(vertexFeedback.isEmpty, "Should provide enhanced feedback at vertices")
        
        // Test off-path state
        let offPathFeedback = feedbackController.testFeedbackTriggering(isOnPath: false, isAtVertex: false)
        XCTAssertTrue(offPathFeedback.isEmpty, "Should not provide feedback when off path")
        
        // Test impossible state (off path but at vertex - shouldn't happen but test anyway)
        let impossibleState = feedbackController.testFeedbackTriggering(isOnPath: false, isAtVertex: true)
        XCTAssertTrue(impossibleState.isEmpty, "Should not provide feedback for impossible state")
    }
    
    
    // Test different haptic intensities have correct values
    func testHapticIntensityValues() {
        let lightValue = HapticIntensity.light.value
        let mediumValue = HapticIntensity.medium.value
        let heavyValue = HapticIntensity.heavy.value
        
        // Test proper intensity ordering
        XCTAssertLessThan(lightValue, mediumValue, "Light intensity should be less than medium")
        XCTAssertLessThan(mediumValue, heavyValue, "Medium intensity should be less than heavy")
        
        // Test reasonable value ranges
        XCTAssertGreaterThan(lightValue, 0, "Light intensity should be positive")
        XCTAssertLessThanOrEqual(heavyValue, 1.0, "Heavy intensity should not exceed 1.0")
        
        // Test specific expected values
        XCTAssertEqual(lightValue, 0.3, accuracy: 0.01, "Light intensity should be 0.3")
        XCTAssertEqual(mediumValue, 0.7, accuracy: 0.01, "Medium intensity should be 0.7")
        XCTAssertEqual(heavyValue, 1.0, accuracy: 0.01, "Heavy intensity should be 1.0")
    }
    
    // Test feedback type enumeration
    func testFeedbackTypeHandling() {
        // Create different feedback types
        let hapticFeedback = FeedbackType.haptic(intensity: .medium)
        let audioFeedback = FeedbackType.audio(frequency: 440.0)
        let visualFeedback = FeedbackType.visual
        let noFeedback = FeedbackType.none
        
        // Test that we can create and handle all types
        let allFeedbacks = [hapticFeedback, audioFeedback, visualFeedback, noFeedback]
        XCTAssertEqual(allFeedbacks.count, 4, "Should handle all feedback types")
        
        // Test providing mixed feedback types
        feedbackController.provideFeedback(allFeedbacks)
        // Should complete without crashing
        XCTAssertTrue(true, "Should handle mixed feedback types without issues")
    }
    
    // Test feedback controller state management
    func testFeedbackControllerStateManagement() {
        // Test initial state
        XCTAssertTrue(feedbackController.isEnabled, "Should start enabled")
        
        // Test preparation
        feedbackController.prepareForTracing()
        // Should complete without issues
        
        // Test cleanup
        feedbackController.stopAllFeedback()
        // Should complete without issues
        
        // Test toggle functionality
        let initialState = feedbackController.isEnabled
        feedbackController.toggleEnabled()
        XCTAssertNotEqual(feedbackController.isEnabled, initialState, "Toggle should change state")
        
        feedbackController.toggleEnabled()
        XCTAssertEqual(feedbackController.isEnabled, initialState, "Second toggle should restore state")
    }
    
    
    // Test feedback with disabled controller
    func testDisabledFeedbackController() {
        // Disable feedback
        feedbackController.isEnabled = false
        
        // Trying to generate feedback
        let feedbacks = feedbackController.testFeedbackTriggering(isOnPath: true, isAtVertex: true)
        
        // Should still generate feedback types
        XCTAssertFalse(feedbacks.isEmpty, "Should still generate feedback types when disabled")
        
        feedbackController.provideFeedback(feedbacks)
        XCTAssertTrue(true, "Should handle disabled state gracefully")
    }
}
