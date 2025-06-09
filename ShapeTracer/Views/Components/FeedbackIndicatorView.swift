//
//  FeedbackIndicatorView.swift
//  ShapeTracer
//
//  Created by Kenish Raghu on 6/6/25.
//  Visual indicator that shows when user is tracing correctly
//  Provides immediate visual feedback alongside haptic and audio
//

import SwiftUI

struct FeedbackIndicatorView: View {
    let isOnPath: Bool
    
    // Animation state
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Outer glow effect
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.green.opacity(glowOpacity),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 5,
                        endRadius: 25
                    )
                )
                .frame(width: 50, height: 50)
            
            // Main indicator circle
            Circle()
                .fill(isOnPath ? Color.green : Color.red.opacity(0.7))
                .frame(width: 12, height: 12)
                .scaleEffect(pulseScale)
                .animation(.easeInOut(duration: 0.3), value: isOnPath)
        }
        .onChange(of: isOnPath) { oldValue, newValue in
            if newValue {
                // Animate when on correct path
                withAnimation(.easeInOut(duration: 0.2)) {
                    pulseScale = 1.3
                    glowOpacity = 0.6
                }
                
                // Return to normal size
                withAnimation(.easeInOut(duration: 0.3).delay(0.2)) {
                    pulseScale = 1.0
                    glowOpacity = 0.3
                }
            } else {
                // Quick reset when off path
                withAnimation(.easeInOut(duration: 0.1)) {
                    pulseScale = 1.0
                    glowOpacity = 0.0
                }
            }
        }
        .accessibilityHidden(true) 
    }
}

#Preview {
    VStack(spacing: 50) {
        FeedbackIndicatorView(isOnPath: true)
            .background(Color.gray.opacity(0.1))
        
        FeedbackIndicatorView(isOnPath: false)
            .background(Color.gray.opacity(0.1))
    }
    .frame(width: 200, height: 200)
}
