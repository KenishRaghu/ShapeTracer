//
//  HapticManager.swift
//  ShapeTracer
//
//  Created by Kenish Raghu on 6/6/25.
//  Manages haptic feedback for touch interactions
//  Provides different intensities of vibration feedback
//

import Foundation
import UIKit

class HapticManager: ObservableObject {
    
    // Different types of haptic feedback generators
    private let lightFeedback = UIImpactFeedbackGenerator(style: .light)
    private let mediumFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let heavyFeedback = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    // Prepare the haptic generators
    func prepare() {
        lightFeedback.prepare()
        mediumFeedback.prepare()
        heavyFeedback.prepare()
        selectionFeedback.prepare()
        notificationFeedback.prepare()
    }
    
    // Provide haptic feedback based on intensity
    func provideFeedback(intensity: HapticIntensity) {
        guard UIDevice.current.userInterfaceIdiom == .phone else {
            return
        }
        
        switch intensity {
        case .light:
            lightFeedback.impactOccurred()
            
        case .medium:
            mediumFeedback.impactOccurred()
            
        case .heavy:
            heavyFeedback.impactOccurred()
        }
    }
    
    // Provide selection feedback (for UI interactions)
    func provideSelectionFeedback() {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return }
        selectionFeedback.selectionChanged()
    }
    
    // Provide notification feedback
    func provideNotificationFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return }
        notificationFeedback.notificationOccurred(type)
    }
    
    // Provide success feedback
    func provideSuccessFeedback() {
        provideNotificationFeedback(.success)
    }
    
    // Provide error feedback
    func provideErrorFeedback() {
        provideNotificationFeedback(.error)
    }
    
    // Provide warning feedback
    func provideWarningFeedback() {
        provideNotificationFeedback(.warning)
    }
    
    // Custom pattern feedback for special cases
    func provideCustomPattern() {
        // Create a custom pattern of feedback
        DispatchQueue.main.async { [weak self] in
            self?.provideFeedback(intensity: .light)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.provideFeedback(intensity: .medium)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.provideFeedback(intensity: .heavy)
        }
    }
    
    // Check if haptic feedback is available
    static var isHapticFeedbackAvailable: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    // Provide feedback for tracing events
    func provideFeedbackForTracing(isOnPath: Bool, isAtVertex: Bool = false) {
        if isOnPath {
            if isAtVertex {
                // Special pattern for vertices
                provideFeedback(intensity: .heavy)
            } else {
                // Regular path feedback
                provideFeedback(intensity: .medium)
            }
        }
    }
    
    // Provide feedback for shape completion
    func provideCompletionFeedback(completionPercentage: Double) {
        if completionPercentage >= 100.0 {
            provideSuccessFeedback()
        } else if completionPercentage >= 75.0 {
            provideFeedback(intensity: .medium)
        }
    }
}
