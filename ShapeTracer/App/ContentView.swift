//
//  ContentView.swift.swift
//  ShapeTracer
//
//  Created by Kenish Raghu on 6/6/25.
//  Main navigation view that manages the app flow
//  Switches between shape selection and tracing modes
//

import SwiftUI

struct ContentView: View {
    // Track which screen the user is currently on (either shape selection or tracing UI)
    @State private var currentScreen: AppScreen = .selection
    
    // Keeps track of which shape (circle/square/cube) the user has picked
    @State private var selectedShape: ShapeType = .circle
    
    var body: some View {
        NavigationView {
            Group {
                switch currentScreen {
                case .selection:
                    ShapeSelectionView(
                        selectedShape: $selectedShape,
                        onStartTracing: {
                            currentScreen = .tracing
                        }
                    )
                case .tracing:
                    TracingCanvasView(
                        shapeType: selectedShape,
                        onBack: {
                            currentScreen = .selection
                        }
                    )
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Ensures single view on all devices
    }
}

// Tracks which main screen is being shown
enum AppScreen {
    case selection
    case tracing
}

#Preview {
    ContentView()
}
