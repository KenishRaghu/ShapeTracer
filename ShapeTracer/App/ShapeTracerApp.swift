//
//  ShapeTracerApp.swift
//  ShapeTracer
//
//  Created by Kenish Raghu on 6/6/25.
//  Main entry point for the Shape Tracing application
//  This app helps users learn shapes through interactive tracing with multimodal feedback
//


import SwiftUI

@main
struct ShapeTracerApp: App {
    var body: some Scene {
        WindowGroup {
            // Launch the app with our main content view.
            ContentView()
                .preferredColorScheme(.light) // Kept it simple for accessibility
        }
    }
}
