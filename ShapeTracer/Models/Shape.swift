//
//  Shape.swift
//  ShapeTracer
//
//  Created by Kenish Raghu on 6/6/25.
//  Defines the different shapes users can trace
//

import Foundation
import CoreGraphics

// All the shapes a user can trace in the app
enum ShapeType: String, CaseIterable {
    case circle = "Circle"
    case square = "Square"
    case cube3D = "Cube3D"
    
    var description: String {
        return self.rawValue
    }
    
    // Accessibility descriptions for VoiceOver
    var accessibilityDescription: String {
        switch self {
        case .circle:
            return "Circle shape for tracing practice"
        case .square:
            return "Square shape for tracing practice"
        case .cube3D: 
            return "3D Cube shape for tracing practice"

        }
    }
}
