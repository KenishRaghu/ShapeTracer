//
//  GeometryHelper.swift
//  ShapeTracer
//
//  Created by Kenish Raghu on 6/6/25.
//  Utility functions for geometric calculations
//  Helps with distance calculations and shape mathematics
//

import Foundation
import CoreGraphics

struct GeometryHelper {
    
    // Calculate distance between two points
    static func distance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
        let deltaX = point2.x - point1.x
        let deltaY = point2.y - point1.y
        return sqrt(deltaX * deltaX + deltaY * deltaY)
    }
    
    // Calculate angle between two points
    static func angle(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
        let deltaX = point2.x - point1.x
        let deltaY = point2.y - point1.y
        return atan2(deltaY, deltaX)
    }
    
    // Check if a point is inside a circle
    static func isPointInCircle(point: CGPoint, center: CGPoint, radius: CGFloat) -> Bool {
        return distance(from: point, to: center) <= radius
    }
    
    // Check if a point is inside a rectangle
    static func isPointInRectangle(point: CGPoint, center: CGPoint, size: CGFloat) -> Bool {
        let halfSize = size / 2
        let minX = center.x - halfSize
        let maxX = center.x + halfSize
        let minY = center.y - halfSize
        let maxY = center.y + halfSize
        
        return point.x >= minX && point.x <= maxX && point.y >= minY && point.y <= maxY
    }
    
    // Get the closest point on a circle's circumference to a given point
    static func closestPointOnCircle(to point: CGPoint, center: CGPoint, radius: CGFloat) -> CGPoint {
        let direction = CGPoint(
            x: point.x - center.x,
            y: point.y - center.y
        )
        
        let distance = distance(from: CGPoint.zero, to: direction)
        
        // Normalizing the direction
        let normalizedDirection = CGPoint(
            x: direction.x / distance,
            y: direction.y / distance
        )
        
        // Scaling by radius and add to center
        return CGPoint(
            x: center.x + normalizedDirection.x * radius,
            y: center.y + normalizedDirection.y * radius
        )
    }
    
    // Get the closest point on a rectangle's perimeter to a given point
    static func closestPointOnRectangle(to point: CGPoint, center: CGPoint, size: CGFloat) -> CGPoint {
        let halfSize = size / 2
        let left = center.x - halfSize
        let right = center.x + halfSize
        let top = center.y - halfSize
        let bottom = center.y + halfSize
        
        // Clamp the point to the rectangle bounds
        let clampedX = max(left, min(right, point.x))
        let clampedY = max(top, min(bottom, point.y))
        
        // If the point is inside the rectangle, find the closest edge
        if point.x > left && point.x < right && point.y > top && point.y < bottom {
            let distanceToLeft = point.x - left
            let distanceToRight = right - point.x
            let distanceToTop = point.y - top
            let distanceToBottom = bottom - point.y
            
            let minDistance = min(distanceToLeft, distanceToRight, distanceToTop, distanceToBottom)
            
            if minDistance == distanceToLeft {
                return CGPoint(x: left, y: point.y)
            } else if minDistance == distanceToRight {
                return CGPoint(x: right, y: point.y)
            } else if minDistance == distanceToTop {
                return CGPoint(x: point.x, y: top)
            } else {
                return CGPoint(x: point.x, y: bottom)
            }
        }
        
        return CGPoint(x: clampedX, y: clampedY)
    }
    
    // Convert degrees to radians
    static func degreesToRadians(_ degrees: CGFloat) -> CGFloat {
        return degrees * .pi / 180
    }
    
    // Convert radians to degrees
    static func radiansToDegrees(_ radians: CGFloat) -> CGFloat {
        return radians * 180 / .pi
    }
    
    // Calculate distance from a point to a line segment
    static func distanceFromPoint(_ p: CGPoint, toLineSegment a: CGPoint, _ b: CGPoint) -> CGFloat {
        let ab = CGPoint(x: b.x - a.x, y: b.y - a.y)
        let ap = CGPoint(x: p.x - a.x, y: p.y - a.y)
        let abLen2 = ab.x * ab.x + ab.y * ab.y
        let t = max(0, min(1, (ap.x * ab.x + ap.y * ab.y) / (abLen2 == 0 ? 1 : abLen2)))
        let closest = CGPoint(x: a.x + ab.x * t, y: a.y + ab.y * t)
        return distance(from: p, to: closest)
    }
    
    // Calculate the length of a path
    static func pathLength(_ points: [CGPoint]) -> CGFloat {
        guard points.count > 1 else { return 0 }
        
        var totalLength: CGFloat = 0
        
        for i in 1..<points.count {
            totalLength += distance(from: points[i-1], to: points[i])
        }
        
        return totalLength
    }
    
    // Simplify a path by removing points that are too close together
    static func simplifyPath(_ points: [CGPoint], tolerance: CGFloat = 5.0) -> [CGPoint] {
        guard points.count > 2 else { return points }
        
        var simplified: [CGPoint] = [points[0]]
        
        for i in 1..<points.count {
            let lastPoint = simplified.last!
            let currentPoint = points[i]
            
            if distance(from: lastPoint, to: currentPoint) >= tolerance {
                simplified.append(currentPoint)
            }
        }
        
        return simplified
    }
}
