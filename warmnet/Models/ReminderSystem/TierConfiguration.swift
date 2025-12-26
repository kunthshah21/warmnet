//
//  TierConfiguration.swift
//  warmnet
//
//  Created on 26/12/2025.
//

import Foundation

/// Configuration for each contact tier defining reminder frequency and priority
struct TierConfiguration {
    let name: String
    let frequencyDays: Int
    let tierWeight: Int
    let variancePercent: Double
    
    /// Get configuration for a specific priority tier
    static func forPriority(_ priority: Priority) -> TierConfiguration {
        switch priority {
        case .innerCircle:
            return TierConfiguration(
                name: "Inner Circle",
                frequencyDays: 14,
                tierWeight: 3,
                variancePercent: 0.15
            )
        case .keyRelationships:
            return TierConfiguration(
                name: "Key Relationships",
                frequencyDays: 60,
                tierWeight: 2,
                variancePercent: 0.15
            )
        case .broaderNetwork:
            return TierConfiguration(
                name: "Broader Network",
                frequencyDays: 180,
                tierWeight: 1,
                variancePercent: 0.15
            )
        }
    }
    
    /// Calculate the variance buffer in days for this tier
    var varianceBuffer: Int {
        Int(Double(frequencyDays) * variancePercent)
    }
}
