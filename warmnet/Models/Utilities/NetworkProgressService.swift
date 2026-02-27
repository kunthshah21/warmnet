//
//  NetworkProgressService.swift
//  warmnet
//
//  Created on 07/01/2026.
//

import Foundation
import SwiftUI

/// Represents the progress state for a single network tier
struct TierProgress: Identifiable, Equatable {
    let id: Priority
    let tier: Priority
    let contacted: Int
    let total: Int
    let windowDays: Int
    
    var progress: Double {
        guard total > 0 else { return 0.0 }
        return Double(contacted) / Double(total)
    }
    
    var isComplete: Bool {
        total > 0 && contacted >= total
    }
    
    var displayText: String {
        "\(contacted)/\(total)"
    }
}

/// Pure service for calculating network progress across tiers
enum NetworkProgressService {
    
    /// Window periods in days for each tier
    static func windowDays(for tier: Priority) -> Int {
        switch tier {
        case .innerCircle: return 14
        case .keyRelationships: return 60
        case .broaderNetwork: return 180
        }
    }
    
    /// Calculate progress for all tiers that have contacts
    /// - Parameter contacts: All contacts from SwiftData
    /// - Returns: Array of TierProgress for tiers with at least one contact
    static func calculateAllProgress(contacts: [Contact]) -> [TierProgress] {
        Priority.allCases.compactMap { tier in
            let progress = calculateProgress(contacts: contacts, for: tier)
            // Only include tiers that have contacts
            return progress.total > 0 ? progress : nil
        }
    }
    
    /// Calculate progress for a specific tier
    /// - Parameters:
    ///   - contacts: All contacts from SwiftData
    ///   - tier: The priority tier to calculate for
    /// - Returns: TierProgress with contacted count and total
    static func calculateProgress(contacts: [Contact], for tier: Priority) -> TierProgress {
        let tierContacts = contacts.filter { $0.priority == tier }
        let window = windowDays(for: tier)
        let contactedCount = tierContacts.filter { isContactedWithinWindow($0, days: window) }.count
        
        return TierProgress(
            id: tier,
            tier: tier,
            contacted: contactedCount,
            total: tierContacts.count,
            windowDays: window
        )
    }
    
    /// Check if a contact has been contacted within the specified window
    /// - Parameters:
    ///   - contact: The contact to check
    ///   - days: Number of days to look back
    /// - Returns: True if any interaction exists within the window
    static func isContactedWithinWindow(_ contact: Contact, days: Int) -> Bool {
        let windowStart = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        return contact.interactions.contains { interaction in
            interaction.date >= windowStart
        }
    }
}
