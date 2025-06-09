//
//  ShapeSelectionView.swift
//  ShapeTracer
//
//  Created by Kenish Raghu on 6/6/25.
//  Lets users pick which shape they want to practice tracing
//  Includes large buttons for accessibility
//

import SwiftUI

struct ShapeSelectionView: View {
    @Binding var selectedShape: ShapeType
    var onStartTracing: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            // Title section
            VStack(spacing: 10) {
                Text("Shape Tracer")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Choose a shape to practice tracing")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Shape Tracer app. Choose a shape to practice tracing")
            
            Spacer()
            
            // Shape selection buttons
            VStack(spacing: 20) {
                ForEach(ShapeType.allCases, id: \.self) { shape in
                    ShapeSelectionButton(
                        shape: shape,
                        isSelected: selectedShape == shape,
                        onTap: {
                            selectedShape = shape
                        }
                    )
                }
            }
            
            Spacer()
            
            // Start button
            Button(action: onStartTracing) {
                HStack {
                    Image(systemName: "hand.draw")
                        .font(.title2)
                    Text("Start Tracing")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color.blue)
                .cornerRadius(15)
            }
            .accessibilityLabel("Start tracing \(selectedShape.description)")
            .accessibilityHint("Double tap to begin tracing practice")
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 40)
    }
}

// Individual shape selection button
struct ShapeSelectionButton: View {
    let shape: ShapeType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 20) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 60, height: 60)

                    if shape == .circle {
                        Circle().stroke(Color.primary, lineWidth: 3).frame(width: 35, height: 35)
                    } else if shape == .square {
                        Rectangle().stroke(Color.primary, lineWidth: 3).frame(width: 35, height: 35)
                    } else if shape == .cube3D {
                        Cube3DIconView(size: 35)
                    }
                }

                // Shape name
                Text(shape.description)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Spacer()

                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .green : .gray)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                    )
            )
            .accessibilityLabel(shape.accessibilityDescription)
            .accessibilityHint(isSelected ? "Currently selected" : "Double tap to select")
            .accessibilityAddTraits(isSelected ? .isSelected : [])
        }
    }
}

// Cube icon
struct Cube3DIconView: View {
    let size: CGFloat

    var body: some View {
        let w = size
        let h = size * 0.62
        let depth = size * 0.38

        // 8 cube points
        let A = CGPoint(x: depth, y: 0)
        let B = CGPoint(x: w, y: 0)
        let C = CGPoint(x: w, y: h)
        let D = CGPoint(x: depth, y: h)
        let E = CGPoint(x: 0, y: depth)
        let F = CGPoint(x: w - depth, y: depth)
        let G = CGPoint(x: w - depth, y: h + depth)
        let H = CGPoint(x: 0, y: h + depth)

        return ZStack {
            // Top face
            Path { path in
                path.move(to: A)
                path.addLine(to: B)
                path.addLine(to: F)
                path.addLine(to: E)
                path.closeSubpath()
            }
            .stroke(Color.black, lineWidth: 2)

            // Right face
            Path { path in
                path.move(to: B)
                path.addLine(to: F)
                path.addLine(to: G)
                path.addLine(to: C)
                path.closeSubpath()
            }
            .stroke(Color.black, lineWidth: 2)

            // Left face
            Path { path in
                path.move(to: A)
                path.addLine(to: E)
                path.addLine(to: H)
                path.addLine(to: D)
                path.closeSubpath()
            }
            .stroke(Color.black, lineWidth: 2)

            // Bottom face outline
            Path { path in
                path.move(to: D)
                path.addLine(to: C)
                path.addLine(to: G)
                path.addLine(to: H)
                path.closeSubpath()
            }
            .stroke(Color.black, lineWidth: 2)

            // Vertical edges
            Path { path in
                path.move(to: A)
                path.addLine(to: D)
                path.move(to: F)
                path.addLine(to: G)
                path.move(to: E)
                path.addLine(to: H)
            }
            .stroke(Color.black, lineWidth: 2)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    ShapeSelectionView(
        selectedShape: .constant(.circle),
        onStartTracing: {}
    )
}
