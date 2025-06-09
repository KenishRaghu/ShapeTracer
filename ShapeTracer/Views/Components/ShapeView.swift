//
//  ShapeView.swift
//  ShapeTracer
//
//  Created by Kenish Raghu on 6/6/25.
//  Displays the shape to trace and handles touch interactions
//  This is where the actual drawing and detection happens
//

import SwiftUI

struct ShapeView: View {
    let shapeType: ShapeType
    let tracingData: TracingData
    var onPositionChanged: (CGPoint) -> Void
    var setShapeFrame: ((CGPoint, CGFloat) -> Void)
    
    @State private var userPath = Path()
    
    var body: some View {
        GeometryReader { geometry in
            // Calculate shape frame
            let shapeSize = min(geometry.size.width, geometry.size.height) * (shapeType == .cube3D ? 0.9 : 0.7)
            let shapeCenter = CGPoint(
                x: geometry.size.width / 2,
                y: geometry.size.height / 2
            )
            
            ZStack {
                // Draw the target shape
                targetShape(size: shapeSize, center: shapeCenter)

                
                // Draw the user's traced path
                userPath
                    .stroke(Color.blue.opacity(0.7), lineWidth: 4)
                
                // Feedback dot always at current finger position
                FeedbackIndicatorView(isOnPath: tracingData.isOnPath)
                    .position(tracingData.currentPosition)
                
                // Touch area captures finger drags
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if userPath.isEmpty {
                                    userPath.move(to: value.location)
                                } else {
                                    userPath.addLine(to: value.location)
                                }
                                onPositionChanged(value.location)
                            }
                            .onEnded { _ in }
                    )
                    .accessibilityLabel("Tracing area for \(shapeType.description)")
                    .accessibilityHint("Drag your finger along the black line to trace the shape")
            }
            .onAppear {
                setShapeFrame(shapeCenter, shapeSize)
            }
            .onChange(of: geometry.size) {
                setShapeFrame(shapeCenter, shapeSize)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .padding(40)
    }
    
    struct Cube3DView: View {
        let size: CGFloat
        let center: CGPoint

        var body: some View {
            let w = size
            let h = size * 0.75
            let depth = size * 0.22

            // Center of the frame
            let centerX = center.x
            let centerY = center.y

            // Cube corners (centered)
            let A = CGPoint(x: centerX - w/2 + depth, y: centerY - h/2)
            let B = CGPoint(x: centerX + w/2, y: centerY - h/2)
            let C = CGPoint(x: centerX + w/2, y: centerY - h/2 + h)
            let D = CGPoint(x: centerX - w/2 + depth, y: centerY - h/2 + h)
            let E = CGPoint(x: centerX - w/2, y: centerY - h/2 + depth)
            let F = CGPoint(x: centerX + w/2 - depth, y: centerY - h/2 + depth)
            let G = CGPoint(x: centerX + w/2 - depth, y: centerY - h/2 + h + depth)
            let H = CGPoint(x: centerX - w/2, y: centerY - h/2 + h + depth)

            return ZStack {
                // Back face
                Path { path in
                    path.move(to: E)
                    path.addLine(to: F)
                    path.addLine(to: G)
                    path.addLine(to: H)
                    path.closeSubpath()
                }.stroke(Color.primary.opacity(0.5), style: StrokeStyle(lineWidth: 20, lineCap: .round, dash: [8, 4]))

                // Front face
                Path { path in
                    path.move(to: A)
                    path.addLine(to: B)
                    path.addLine(to: C)
                    path.addLine(to: D)
                    path.closeSubpath()
                }.stroke(Color.primary, style: StrokeStyle(lineWidth: 20, lineCap: .round, dash: [10, 5]))

                // Connecting edges
                Path { path in
                    path.move(to: A); path.addLine(to: E)
                    path.move(to: B); path.addLine(to: F)
                    path.move(to: C); path.addLine(to: G)
                    path.move(to: D); path.addLine(to: H)
                }.stroke(Color.secondary, style: StrokeStyle(lineWidth: 20))
            }
            .frame(width: size, height: size * 1.1)
        }
    }
    private func targetShape(size: CGFloat, center: CGPoint) -> some View {

        if shapeType == .circle {
            return AnyView(
                Circle()
                    .stroke(
                        Color.primary.opacity(0.6),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round, dash: [10, 5])
                    )
                    .frame(width: size, height: size)
            )
        } else if shapeType == .square {
            return AnyView(
                Rectangle()
                    .stroke(
                        Color.primary.opacity(0.6),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round, dash: [10, 5])
                    )
                    .frame(width: size, height: size)
            )
        } else if shapeType == .cube3D {
            return AnyView(
                Cube3DView(size: size, center: center)
            )
        } else {
            // fallback if ever needed
            return AnyView(EmptyView())
        }
    }
}
#Preview {
    ShapeView(
        shapeType: .cube3D,
        tracingData: TracingData(),
        onPositionChanged: { _ in },
        setShapeFrame: { _, _ in }
    )
    .frame(width: 300, height: 300)
}
