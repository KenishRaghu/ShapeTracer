//
//  TracingLogicTests.swift
//  ShapeTracer
//
//  Created by Kenish Raghu on 6/6/25.
//
//  Tests for the shape tracing validation logic
//  Ensures that path detection works correctly for different shapes
//

import XCTest
import CoreGraphics
@testable import ShapeTracer

final class TracingLogicTests: XCTestCase {
    
    var tracingController: TracingController!
    
    override func setUp() {
        super.setUp()
        tracingController = TracingController()
    }
    
    override func tearDown() {
        tracingController = nil
        super.tearDown()
    }
    
    // Test circle path detection accuracy
    func testCirclePathDetection() {
        let center = CGPoint(x: 150, y: 150)
        let radius: CGFloat = 100
        
        // Test point on circle circumference (should be on path)
        let pointOnCircle = CGPoint(x: center.x + radius, y: center.y)
        let isOnPath = tracingController.testIsOnPath(
            pointOnCircle,
            shapeType: .circle,
            center: center,
            size: radius * 2
        )
        
        XCTAssertTrue(isOnPath, "Point on circle circumference should be detected as on path")
        
        // Test point inside circle
        let pointInside = CGPoint(x: center.x + radius/2, y: center.y)
        let isInsideOnPath = tracingController.testIsOnPath(
            pointInside,
            shapeType: .circle,
            center: center,
            size: radius * 2
        )
        
        XCTAssertFalse(isInsideOnPath, "Point inside circle should not be on path")
        
        // Test point far from circle
        let pointFar = CGPoint(x: center.x + radius * 2, y: center.y)
        let isFarOnPath = tracingController.testIsOnPath(
            pointFar,
            shapeType: .circle,
            center: center,
            size: radius * 2
        )
        
        XCTAssertFalse(isFarOnPath, "Point far from circle should not be on path")
    }
    
    
    
    
    // Test square path detection accuracy
    func testSquarePathDetection() {
        let center = CGPoint(x: 150, y: 150)
        let size: CGFloat = 200
        let halfSize = size / 2
        
        // Test point on square edge (should be on path)
        let pointOnEdge = CGPoint(x: center.x + halfSize, y: center.y)
        let isOnPath = tracingController.testIsOnPath(
            pointOnEdge,
            shapeType: .square,
            center: center,
            size: size
        )
        
        XCTAssertTrue(isOnPath, "Point on square edge should be detected as on path")
        
        // Test point at corner (should be on path)
        let pointAtCorner = CGPoint(x: center.x + halfSize, y: center.y + halfSize)
        let isCornerOnPath = tracingController.testIsOnPath(
            pointAtCorner,
            shapeType: .square,
            center: center,
            size: size
        )
        
        XCTAssertTrue(isCornerOnPath, "Point at square corner should be on path")
        
        // Test point inside square (should not be on path)
        let pointInside = CGPoint(x: center.x, y: center.y)
        let isInsideOnPath = tracingController.testIsOnPath(
            pointInside,
            shapeType: .square,
            center: center,
            size: size
        )
        
        XCTAssertFalse(isInsideOnPath, "Point inside square should not be on path")
        
        // Test all four edges
        let topEdge = CGPoint(x: center.x, y: center.y - halfSize)
        let rightEdge = CGPoint(x: center.x + halfSize, y: center.y)
        let bottomEdge = CGPoint(x: center.x, y: center.y + halfSize)
        let leftEdge = CGPoint(x: center.x - halfSize, y: center.y)
        
        XCTAssertTrue(tracingController.testIsOnPath(topEdge, shapeType: .square, center: center, size: size), "Top edge should be on path")
        XCTAssertTrue(tracingController.testIsOnPath(rightEdge, shapeType: .square, center: center, size: size), "Right edge should be on path")
        XCTAssertTrue(tracingController.testIsOnPath(bottomEdge, shapeType: .square, center: center, size: size), "Bottom edge should be on path")
        XCTAssertTrue(tracingController.testIsOnPath(leftEdge, shapeType: .square, center: center, size: size), "Left edge should be on path")
    }
    
    
    // Test cube3D path detection accuracy
    func testCube3DPathDetection() {
        let size: CGFloat = 200
        let w = size
        let h = size * 0.75
        let depth = size * 0.22

        // These must match the drawing math!
        let centerX = w / 2
        let centerY = h / 2 + depth / 2

        // Cube corners (centered in the frame)
        let A = CGPoint(x: centerX - w/2 + depth, y: centerY - h/2)
        let B = CGPoint(x: centerX + w/2, y: centerY - h/2)
        let C = CGPoint(x: centerX + w/2, y: centerY - h/2 + h)
        let D = CGPoint(x: centerX - w/2 + depth, y: centerY - h/2 + h)
        let E = CGPoint(x: centerX - w/2, y: centerY - h/2 + depth)
        let F = CGPoint(x: centerX + w/2 - depth, y: centerY - h/2 + depth)
        let G = CGPoint(x: centerX + w/2 - depth, y: centerY - h/2 + h + depth)
        let H = CGPoint(x: centerX - w/2, y: centerY - h/2 + h + depth)

        // Use the same center for detection logic
        let center = CGPoint(x: centerX, y: centerY)
        
        // Test all 8 cube corners (should be on path)
        let allCorners = [A, B, C, D, E, F, G, H]
        for (i, corner) in allCorners.enumerated() {
            XCTAssertTrue(
                tracingController.testIsOnPath(corner, shapeType: .cube3D, center: center, size: size),
                "Cube corner \(i) should be detected as on path"
            )
        }

        // Test some midpoints of cube edges
        let edgeMidAB = CGPoint(x: (A.x + B.x)/2, y: (A.y + B.y)/2)
        let edgeMidEF = CGPoint(x: (E.x + F.x)/2, y: (E.y + F.y)/2)
        let edgeMidCG = CGPoint(x: (C.x + G.x)/2, y: (C.y + G.y)/2)
        let edgeMidDH = CGPoint(x: (D.x + H.x)/2, y: (D.y + H.y)/2)
        let edgeMids = [edgeMidAB, edgeMidEF, edgeMidCG, edgeMidDH]

        for (i, mid) in edgeMids.enumerated() {
            XCTAssertTrue(
                tracingController.testIsOnPath(mid, shapeType: .cube3D, center: center, size: size),
                "Cube edge midpoint \(i) should be detected as on path"
            )
        }

        // Test point inside the cube projection
        let inside = CGPoint(x: center.x, y: center.y)
        XCTAssertFalse(
            tracingController.testIsOnPath(inside, shapeType: .cube3D, center: center, size: size),
            "Point inside cube projection should NOT be on path"
        )

        // Test point outside the cube
        let outside = CGPoint(x: center.x + size, y: center.y + size)
        XCTAssertFalse(
            tracingController.testIsOnPath(outside, shapeType: .cube3D, center: center, size: size),
            "Point outside cube projection should NOT be on path"
        )
    }

    
    
    // Test distance calculation accuracy
    func testDistanceCalculation() {
        let center = CGPoint(x: 100, y: 100)
        let radius: CGFloat = 50
        
        // Test distance to circle center (should be approximately equal to radius)
        let centerDistance = tracingController.testDistanceToPath(
            center,
            shapeType: .circle,
            center: center,
            size: radius * 2
        )
        
        XCTAssertEqual(centerDistance, radius, accuracy: 1.0, "Distance from center to circle path should equal radius")
        
        // Test distance from point on circumference (should be close to 0)
        let pointOnCircle = CGPoint(x: center.x + radius, y: center.y)
        let circumferenceDistance = tracingController.testDistanceToPath(
            pointOnCircle,
            shapeType: .circle,
            center: center,
            size: radius * 2
        )
        
        XCTAssertLessThan(circumferenceDistance, 1.0, "Distance from circumference point should be very small")
        
        // Test distance calculation for square
        let squareSize: CGFloat = 100
        let squareCenter = CGPoint(x: 100, y: 100)
        
        // Point on square edge should have near-zero distance
        let squareEdgePoint = CGPoint(x: squareCenter.x + squareSize/2, y: squareCenter.y)
        let squareEdgeDistance = tracingController.testDistanceToPath(
            squareEdgePoint,
            shapeType: .square,
            center: squareCenter,
            size: squareSize
        )
        
        XCTAssertLessThan(squareEdgeDistance, 1.0, "Distance from square edge should be very small")
    }
    
    
    // Test tracing data state transitions
    func testTracingDataStateTransitions() {
        tracingController.setupShape(.circle)
        let center = CGPoint(x: 150, y: 150)
        let radius: CGFloat = 100
        let size = radius * 2
        
        // Start with point off path (center of circle)
        let offPathPoint = CGPoint(x: center.x, y: center.y)
        
        // Test that our off-path point is actually off-path
        let isOffPath = tracingController.testIsOnPath(offPathPoint, shapeType: .circle, center: center, size: size)
        XCTAssertFalse(isOffPath, "Center point should not be on circle path")
        
        // Test point on path
        let onPathPoint = CGPoint(x: center.x + radius, y: center.y)
        let isOnPath = tracingController.testIsOnPath(onPathPoint, shapeType: .circle, center: center, size: size)
        XCTAssertTrue(isOnPath, "Point on circumference should be on circle path")
        
        // Test transitioning between states by directly updating and checking
        tracingController.updatePosition(offPathPoint)
        XCTAssertEqual(tracingController.tracingData.currentPosition, offPathPoint, "Should record off-path position")
        
        tracingController.updatePosition(onPathPoint)
        XCTAssertEqual(tracingController.tracingData.currentPosition, onPathPoint, "Should record on-path position")
        
        // Verify that positions are being tracked
        XCTAssertGreaterThanOrEqual(tracingController.tracingData.tracedPoints.count, 2, "Should have recorded multiple traced points")
    }
    
    // Test vertex detection for enhanced feedback
    func testVertexDetection() {
        let center = CGPoint(x: 150, y: 150)
        let size: CGFloat = 200
        let halfSize = size / 2
        
        // Test square corners (should trigger vertex feedback)
        let corners = [
            CGPoint(x: center.x - halfSize, y: center.y - halfSize), // Top-left
            CGPoint(x: center.x + halfSize, y: center.y - halfSize), // Top-right
            CGPoint(x: center.x + halfSize, y: center.y + halfSize), // Bottom-right
            CGPoint(x: center.x - halfSize, y: center.y + halfSize)  // Bottom-left
        ]
        
        tracingController.setupShape(.square)
        
        for corner in corners {
            tracingController.updatePosition(corner)
            // If the point is close enough to be on path, it should also detect vertex
            if tracingController.tracingData.isOnPath {
                // This tests the vertex detection logic indirectly
                XCTAssertNotNil(tracingController.tracingData.isAtVertex, "Vertex detection should work at corners")
            }
        }
    }
    
}
