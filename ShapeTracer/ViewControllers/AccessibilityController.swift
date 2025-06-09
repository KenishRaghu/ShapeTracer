//
//  AccessibilityController.swift
//  ShapeTracer
//
//  Created by Kenish Raghu on 6/6/25.
//  Manages accessibility features and VoiceOver support
//  Ensures the app works well for users with different abilities
//

import Foundation
import SwiftUI
import UIKit

class AccessibilityController: ObservableObject {
    @Published var isVoiceOverEnabled: Bool = false
    @Published var preferredContentSize: UIContentSizeCategory = .medium
    
    init() {
        // Check initial accessibility settings
        updateAccessibilityStatus()
        
        // Listen for accessibility changes
        setupAccessibilityNotifications()
    }
    
    // Update current accessibility status
    private func updateAccessibilityStatus() {
        isVoiceOverEnabled = UIAccessibility.isVoiceOverRunning
        preferredContentSize = UIApplication.shared.preferredContentSizeCategory
    }
    
    // Set up notifications for accessibility changes
    private func setupAccessibilityNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIAccessibility.voiceOverStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAccessibilityStatus()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIContentSizeCategory.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAccessibilityStatus()
        }
    }
    
    // Announce when user moves on or off the correct path
    func announcePathStatus(isOnPath: Bool, isAtVertex: Bool = false) {
        let message: String
        
        if isOnPath {
            if isAtVertex {
                message = "Good! You're at a corner point"
            } else {
                message = "Good! You're on the correct path"
            }
        } else {
            message = "Move back to the dotted line"
        }
        
        UIAccessibility.post(
            notification: .announcement,
            argument: message
        )
    }
    
    func getRecommendedFontSize(for textStyle: Font.TextStyle) -> Font {
        return Font.system(textStyle)
    }
    
    func getRecommendedTouchTargetSize() -> CGFloat {
        return max(44, preferredContentSize.isAccessibilityCategory ? 60 : 44)
    }
    
    // Check if we should use larger UI elements
    var shouldUseLargerElements: Bool {
        return preferredContentSize.isAccessibilityCategory || isVoiceOverEnabled
    }
    
    // Get accessibility-friendly color contrast
    func getContrastAwareColor(foreground: Color, background: Color) -> Color {
        return foreground
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// Extension for UIContentSizeCategory helpers
extension UIContentSizeCategory {
    var isAccessibilityCategory: Bool {
        switch self {
        case .accessibilityMedium,
             .accessibilityLarge,
             .accessibilityExtraLarge,
             .accessibilityExtraExtraLarge,
             .accessibilityExtraExtraExtraLarge:
            return true
        default:
            return false
        }
    }
}
