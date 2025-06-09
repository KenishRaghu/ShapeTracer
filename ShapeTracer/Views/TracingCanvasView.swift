//
//  TracingCanvasView.swift
//  ShapeTracer
//
//  Created by Kenish Raghu on 6/6/25.
//  Main tracing interface where users practice drawing shapes
//  Handles touch input and coordinates with feedback systems
//

import SwiftUI

struct TracingCanvasView: View {
    let shapeType: ShapeType
    var onBack: () -> Void
    
    // Controllers for managing different aspects
    @StateObject private var tracingController = TracingController()
    @StateObject private var feedbackController = FeedbackController()
    
    // UI state
    @State private var showingInstructions = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with back button
            headerView
            
            // Main tracing area
            ZStack {
                // Background
                Color.gray.opacity(0.05)
                
                // The shape to trace and user's path
                ShapeView(
                    shapeType: shapeType,
                    tracingData: tracingController.tracingData,
                    onPositionChanged: handlePositionChange,
                    setShapeFrame: { center, size in
                        tracingController.setShapeFrame(center: center, size: size)
                    }
                )
            }
            .clipped()
            
            // Bottom controls
            bottomControls
        }
        .navigationBarHidden(true)
        .onAppear {
            setupForShape()
        }
        .alert("How to Trace", isPresented: $showingInstructions) {
            Button("Got it!") {
                showingInstructions = false
            }
        } message: {
            Text("Place your finger on the shape outline and slowly trace along the path. You'll feel vibrations and hear sounds when you're on the right track!")
        }
    }
    
    // Header section with navigation
    private var headerView: some View {
        HStack {
            // Back button
            Button(action: onBack) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .font(.title3)
                .foregroundColor(.blue)
            }
            .accessibilityLabel("Go back to shape selection")
            
            Spacer()
            
            // Current shape indicator
            Text("Tracing: \(shapeType.description)")
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(Color(.systemBackground))
    }
    
    // Bottom control buttons
    private var bottomControls: some View {
        HStack(spacing: 30) {
            // Help button
            Button(action: { showingInstructions = true }) {
                VStack(spacing: 5) {
                    Image(systemName: "questionmark.circle")
                        .font(.title2)
                    Text("Help")
                        .font(.caption)
                }
                .foregroundColor(.blue)
            }
            .accessibilityLabel("Show tracing instructions")
            
            Spacer()
            
            // Sound toggle button
            Button(action: toggleFeedback) {
                VStack(spacing: 5) {
                    Image(systemName: feedbackController.isEnabled ? "speaker.wave.2" : "speaker.slash")
                        .font(.title2)
                    Text("Sound")
                        .font(.caption)
                }
                .foregroundColor(feedbackController.isEnabled ? .green : .gray)
            }
            .accessibilityLabel(feedbackController.isEnabled ? "Turn off sound feedback" : "Turn on sound feedback")
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 20)
        .background(Color(.systemBackground))
    }
    
    // Setup the tracing environment for the selected shape
    private func setupForShape() {
        tracingController.setupShape(shapeType)
        feedbackController.prepareForTracing()
    }
    
    private func handlePositionChange(_ position: CGPoint) {
        // Update tracing data
        tracingController.updatePosition(position)
        
        // Provides feedback
        let feedbackTypes = determineFeedbackTypes()
        feedbackController.provideFeedback(feedbackTypes)
    }
    
    // Determine what kind of feedback to give based on current state
    private func determineFeedbackTypes() -> [FeedbackType] {
        var feedbacks: [FeedbackType] = []
        
        let data = tracingController.tracingData
        
        if data.isOnPath {
            // Haptic feedback for being on path
            let intensity: HapticIntensity = data.isAtVertex ? .heavy : .medium
            feedbacks.append(.haptic(intensity: intensity))
            
            // Audio feedback with higher pitch at vertices
            let frequency = data.isAtVertex ? 800.0 : 440.0
            feedbacks.append(.audio(frequency: frequency))
            
            // Visual feedback
            feedbacks.append(.visual)
        }
        
        return feedbacks
    }
    
    // Reset the current tracing session
    private func resetTracing() {
        tracingController.reset()
        feedbackController.stopAllFeedback()
    }
    
    // Toggle audio feedback on/off
    private func toggleFeedback() {
        feedbackController.toggleEnabled()
    }
}

#Preview {
    TracingCanvasView(
        shapeType: .circle,
        onBack: {}
    )
}
