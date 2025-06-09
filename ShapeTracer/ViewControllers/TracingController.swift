//
//  TracingController.swift
//  ShapeTracer
//
//  Created by Kenish Raghu on 6/6/25.
//  Calculates whether they're on the right path and handles completion
//

import Foundation
import CoreGraphics
import SwiftUI

class TracingController: ObservableObject {
    @Published var tracingData = TracingData()
    
    // Shape properties
    private var currentShape: ShapeType = .circle
    private var shapeCenter: CGPoint = .zero
    private var shapeSize: CGFloat = 200
    private var toleranceDistance: CGFloat {
        switch currentShape {
        case .cube3D:
            return 24
        case .square:
            return 10
        case .circle:
            return 10
        }
    }
    
    // Set up the frame/size/center for the shape (called from the View)
    func setShapeFrame(center: CGPoint, size: CGFloat) {
        self.shapeCenter = center
        self.shapeSize = size
    }
    
    // Setup for a new shape tracing session
    func setupShape(_ shapeType: ShapeType) {
        currentShape = shapeType
        reset()
    }
    
    // Called on every finger move/touch
    func updatePosition(_ position: CGPoint) {
        tracingData.currentPosition = position

        // Check if position is on the shape path
        let (isOnPath, isAtVertex) = checkIfOnPath(position)
        tracingData.isOnPath = isOnPath
        tracingData.isAtVertex = isAtVertex
        
        // Trigger Haptic Feedback only when on the path
        if isOnPath {
            if currentShape == .cube3D {
                // Sound + haptic always on the path, heavy at vertex, light otherwise
                if isAtVertex {
                    triggerHapticFeedback(style: .heavy)
                } else {
                    triggerHapticFeedback(style: .light)
                }
            } else if currentShape == .square {
                if isAtVertex {
                    triggerHapticFeedback(style: .heavy)
                } else {
                    triggerHapticFeedback(style: .light)
                }
            } else {
                triggerHapticFeedback(style: .light)
            }
        }

        // Add to traced points for drawing the user's path
        tracingData.tracedPoints.append(position)
    }
    
    private func triggerHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: style)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }

    // Reset all tracing data
    func reset() {
        tracingData = TracingData()
    }
    
    // Check if a point is close enough to the shape outline
    private func checkIfOnPath(_ point: CGPoint) -> (isOnPath: Bool, isAtVertex: Bool) {
        let distance = distanceToShapePath(point)
        let isOnPath = distance <= toleranceDistance
        
        // Check if we're near a vertex
        let isAtVertex = isNearVertex(point) && isOnPath
        
        return (isOnPath, isAtVertex)
    }
    
    // Calculate distance from point to the nearest point on shape outline
    private func distanceToShapePath(_ point: CGPoint) -> CGFloat {
        switch currentShape {
        case .circle:
            return distanceToCircle(point)
        case .square:
            return distanceToSquare(point)
        case .cube3D:
            return distanceToCube3D(point)
        }
    }
    
    // Distance calculation for circle outline
    private func distanceToCircle(_ point: CGPoint) -> CGFloat {
        let radius = shapeSize / 2
        let distanceFromCenter = GeometryHelper.distance(from: point, to: shapeCenter)
        return abs(distanceFromCenter - radius)
    }
    
    // Distance calculation for square outline
    private func distanceToSquare(_ point: CGPoint) -> CGFloat {
        let halfSize = shapeSize / 2
        let left = shapeCenter.x - halfSize
        let right = shapeCenter.x + halfSize
        let top = shapeCenter.y - halfSize
        let bottom = shapeCenter.y + halfSize
        
        // Calculate distance to each edge
        let distanceToLeft = abs(point.x - left)
        let distanceToRight = abs(point.x - right)
        let distanceToTop = abs(point.y - top)
        let distanceToBottom = abs(point.y - bottom)
        
        // Check if point is within the square bounds
        let withinHorizontalBounds = point.x >= left && point.x <= right
        let withinVerticalBounds = point.y >= top && point.y <= bottom
        
        if withinHorizontalBounds && withinVerticalBounds {
            return min(distanceToLeft, distanceToRight, distanceToTop, distanceToBottom)
        } else {
            let dx = max(left - point.x, 0, point.x - right)
            let dy = max(top - point.y, 0, point.y - bottom)
            if dx > 0 && dy > 0 {
                // Outside both axes: use Pythagoras
                return sqrt(dx*dx + dy*dy)
            } else if dx > 0 {
                return dx
            } else if dy > 0 {
                return dy
            }
            return 0
        }
    }
    
    private func distanceToCube3D(_ point: CGPoint) -> CGFloat {
        let w = shapeSize
        let h = shapeSize * 0.75
        let depth = shapeSize * 0.22

        let centerX = shapeCenter.x
        let centerY = shapeCenter.y

        // Cube corners
        let A = CGPoint(x: centerX - w/2 + depth, y: centerY - h/2)
        let B = CGPoint(x: centerX + w/2, y: centerY - h/2)
        let C = CGPoint(x: centerX + w/2, y: centerY - h/2 + h)
        let D = CGPoint(x: centerX - w/2 + depth, y: centerY - h/2 + h)
        let E = CGPoint(x: centerX - w/2, y: centerY - h/2 + depth)
        let F = CGPoint(x: centerX + w/2 - depth, y: centerY - h/2 + depth)
        let G = CGPoint(x: centerX + w/2 - depth, y: centerY - h/2 + h + depth)
        let H = CGPoint(x: centerX - w/2, y: centerY - h/2 + h + depth)

        // All lines (each as [start, end])
        let lines: [[CGPoint]] = [
            // Front face edges
            [A, B], [B, C], [C, D], [D, A],
            // Back face edges
            [E, F], [F, G], [G, H], [H, E],
            // Connecting edges
            [A, E], [B, F], [C, G], [D, H]
        ]
        
        // Find minimum distance from point to any line
        let minDist = lines.map { line in
            GeometryHelper.distanceFromPoint(point, toLineSegment: line[0], line[1])
        }.min() ?? CGFloat.greatestFiniteMagnitude
        
        return minDist
    }
    
    // Check if point is near a vertex
    private func isNearVertex(_ point: CGPoint) -> Bool {
        let vertexTolerance: CGFloat = {
            switch currentShape {
            case .cube3D: return 25
            default:      return 30
            }
        }()
        
        switch currentShape {
        case .circle:
            // Four axis points: top, right, bottom, left
            let radius = shapeSize / 2
            let topPoint = CGPoint(x: shapeCenter.x, y: shapeCenter.y - radius)
            let rightPoint = CGPoint(x: shapeCenter.x + radius, y: shapeCenter.y)
            let bottomPoint = CGPoint(x: shapeCenter.x, y: shapeCenter.y + radius)
            let leftPoint = CGPoint(x: shapeCenter.x - radius, y: shapeCenter.y)
            let vertices = [topPoint, rightPoint, bottomPoint, leftPoint]
            return vertices.contains { vertex in
                GeometryHelper.distance(from: point, to: vertex) <= vertexTolerance
            }
        case .square:
            // Actual corners
            let halfSize = shapeSize / 2
            let topLeft = CGPoint(x: shapeCenter.x - halfSize, y: shapeCenter.y - halfSize)
            let topRight = CGPoint(x: shapeCenter.x + halfSize, y: shapeCenter.y - halfSize)
            let bottomLeft = CGPoint(x: shapeCenter.x - halfSize, y: shapeCenter.y + halfSize)
            let bottomRight = CGPoint(x: shapeCenter.x + halfSize, y: shapeCenter.y + halfSize)
            let vertices = [topLeft, topRight, bottomRight, bottomLeft]
            return vertices.contains { vertex in
                GeometryHelper.distance(from: point, to: vertex) <= vertexTolerance
            }
        case .cube3D:
            let w = shapeSize
            let h = shapeSize * 0.75
            let depth = shapeSize * 0.22

            let centerX = shapeCenter.x
            let centerY = shapeCenter.y

            let A = CGPoint(x: centerX - w/2 + depth, y: centerY - h/2)
            let B = CGPoint(x: centerX + w/2, y: centerY - h/2)
            let C = CGPoint(x: centerX + w/2, y: centerY - h/2 + h)
            let D = CGPoint(x: centerX - w/2 + depth, y: centerY - h/2 + h)
            let E = CGPoint(x: centerX - w/2, y: centerY - h/2 + depth)
            let F = CGPoint(x: centerX + w/2 - depth, y: centerY - h/2 + depth)
            let G = CGPoint(x: centerX + w/2 - depth, y: centerY - h/2 + h + depth)
            let H = CGPoint(x: centerX - w/2, y: centerY - h/2 + h + depth)

            let allVertices = [A, B, C, D, E, F, G, H]
            return allVertices.contains { v in
                GeometryHelper.distance(from: point, to: v) <= vertexTolerance
            }
        }
    }
}

extension TracingController {
    func testDistanceToPath(_ point: CGPoint, shapeType: ShapeType, center: CGPoint, size: CGFloat) -> CGFloat {
        self.currentShape = shapeType
        self.shapeCenter = center
        self.shapeSize = size
        return distanceToShapePath(point)
    }
    
    func testIsOnPath(_ point: CGPoint, shapeType: ShapeType, center: CGPoint, size: CGFloat) -> Bool {
        self.currentShape = shapeType
        self.shapeCenter = center
        self.shapeSize = size
        return checkIfOnPath(point).isOnPath
    }
}
