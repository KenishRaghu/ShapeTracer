//
//  FeedbackType.swift
//  ShapeTracer
//
//  Created by Kenish Raghu on 6/6/25.
//  Defines different types of feedback we can provide to users
//

import Foundation

// Represents the type of feedback we can give while tracing
enum FeedbackType {
    case haptic(intensity: HapticIntensity)
    case audio(frequency: Double)
    case visual
    case none
}

// Different vibration strengths for haptic feedback
enum HapticIntensity {
    case light
    case medium
    case heavy
    
    
    // Maping each level to a float value
    var value: Float {
        switch self {
        case .light: return 0.3
        case .medium: return 0.7
        case .heavy: return 1.0
        }
    }
}
