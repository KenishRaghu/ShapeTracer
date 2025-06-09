//
//  TracingData.swift
//  ShapeTracer
//
//  Created by Kenish Raghu on 6/6/25.
//  Stores information about user's trace
//

import Foundation
import CoreGraphics


// Stores all the real-time info about the user's tracing session
struct TracingData {
    var currentPosition: CGPoint        
    var isOnPath: Bool
    var completionPercentage: Double
    var tracedPoints: [CGPoint]
    var isAtVertex: Bool                 // True if they're on a corner (for extra feedback)
    
    // Starting with an empty/default tracing state
    init() {
        self.currentPosition = .zero
        self.isOnPath = false
        self.completionPercentage = 0.0
        self.tracedPoints = []
        self.isAtVertex = false
    }
}

