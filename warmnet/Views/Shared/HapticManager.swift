//
//  HapticManager.swift
//  warmnet
//
//  Centralized haptic feedback utility for consistent tactile feedback across the app.
//

import UIKit

enum HapticManager {
    /// Triggers an impact haptic with the specified style
    /// - Parameter style: The intensity of the impact (.light, .medium, .heavy, .soft, .rigid)
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Triggers a notification haptic with the specified type
    /// - Parameter type: The type of notification (.success, .warning, .error)
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    /// Triggers a selection haptic for picker/toggle interactions
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
