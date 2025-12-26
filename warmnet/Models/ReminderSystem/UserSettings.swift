//
//  UserSettings.swift
//  warmnet
//
//  Created on 26/12/2025.
//

import Foundation
import SwiftData

@Model
final class UserSettings {
    var id: UUID
    var dailyQueueSize: Int
    
    // Urgency Bonus Configuration
    var enableUrgencyBonus: Bool
    var birthdayBonusPoints: Double
    var milestoneBonusPoints: Double
    var severelyOverdueBonusPoints: Double
    
    var createdAt: Date
    var updatedAt: Date
    
    init(
        dailyQueueSize: Int = 5,
        enableUrgencyBonus: Bool = true,
        birthdayBonusPoints: Double = 15.0,
        milestoneBonusPoints: Double = 10.0,
        severelyOverdueBonusPoints: Double = 20.0
    ) {
        self.id = UUID()
        self.dailyQueueSize = min(10, max(3, dailyQueueSize)) // Enforce 3-10 range
        self.enableUrgencyBonus = enableUrgencyBonus
        self.birthdayBonusPoints = birthdayBonusPoints
        self.milestoneBonusPoints = milestoneBonusPoints
        self.severelyOverdueBonusPoints = severelyOverdueBonusPoints
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    /// Singleton instance helper
    static func getOrCreate(from context: ModelContext) -> UserSettings {
        let descriptor = FetchDescriptor<UserSettings>()
        
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        
        let newSettings = UserSettings()
        context.insert(newSettings)
        return newSettings
    }
    
    /// Update daily queue size with validation
    func updateQueueSize(_ newSize: Int) {
        self.dailyQueueSize = min(10, max(3, newSize))
        self.updatedAt = Date()
    }
    
    /// Update urgency bonus settings
    func updateUrgencyBonus(
        enabled: Bool? = nil,
        birthdayPoints: Double? = nil,
        milestonePoints: Double? = nil,
        overduePoints: Double? = nil
    ) {
        if let enabled = enabled {
            self.enableUrgencyBonus = enabled
        }
        if let birthdayPoints = birthdayPoints {
            self.birthdayBonusPoints = max(0, birthdayPoints)
        }
        if let milestonePoints = milestonePoints {
            self.milestoneBonusPoints = max(0, milestonePoints)
        }
        if let overduePoints = overduePoints {
            self.severelyOverdueBonusPoints = max(0, overduePoints)
        }
        self.updatedAt = Date()
    }
}
