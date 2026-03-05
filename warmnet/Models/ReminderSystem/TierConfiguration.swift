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
    
    /// Get configuration for a specific priority tier (using default values)
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
    
    /// Get configuration for a specific priority tier with user-customized multipliers
    /// - Parameters:
    ///   - priority: The contact priority tier
    ///   - settings: User settings containing frequency and priority multipliers
    /// - Returns: Configuration with adjusted frequency and weight values
    static func forPriority(_ priority: Priority, settings: UserSettings) -> TierConfiguration {
        let base = forPriority(priority)
        let freqMultiplier = settings.frequencyMultiplier(for: priority)
        let prioMultiplier = settings.priorityMultiplier(for: priority)
        
        return TierConfiguration(
            name: base.name,
            frequencyDays: max(1, Int(Double(base.frequencyDays) / freqMultiplier)),
            tierWeight: max(1, Int(round(Double(base.tierWeight) * prioMultiplier))),
            variancePercent: base.variancePercent
        )
    }
    
    /// Get base (default) frequency days for a tier without any multipliers applied
    static func baseFrequencyDays(for priority: Priority) -> Int {
        forPriority(priority).frequencyDays
    }
    
    /// Get base (default) tier weight for a tier without any multipliers applied
    static func baseTierWeight(for priority: Priority) -> Int {
        forPriority(priority).tierWeight
    }
    
    /// Calculate the variance buffer in days for this tier
    var varianceBuffer: Int {
        Int(Double(frequencyDays) * variancePercent)
    }
}
