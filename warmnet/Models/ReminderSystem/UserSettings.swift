//
//  UserSettings.swift
//  warmnet
//
//  Created on 26/12/2025.
//

import Foundation
import SwiftData

/// Notification cooldown frequency options
enum NotificationCooldown: Int, Codable, CaseIterable {
    case oncePerVisit = 0      // Minimum 1 hour between notifications
    case everyTwelveHours = 12
    case daily = 24
    case everyTwoDays = 48
    case weekly = 168
    
    var displayName: String {
        switch self {
        case .oncePerVisit: return "Once per visit"
        case .everyTwelveHours: return "Every 12 hours"
        case .daily: return "Once daily"
        case .everyTwoDays: return "Every 2 days"
        case .weekly: return "Weekly"
        }
    }
    
    var hours: Int { rawValue }
}

@Model
final class UserSettings {
    var id: UUID
    var dailyQueueSize: Int
    
    // Urgency Bonus Configuration
    var enableUrgencyBonus: Bool
    var birthdayBonusPoints: Double
    var milestoneBonusPoints: Double
    var severelyOverdueBonusPoints: Double
    
    // Location Notification Configuration
    var locationNotificationsEnabled: Bool
    var notificationCooldownHours: Int  // Maps to NotificationCooldown.rawValue
    var quietHoursEnabled: Bool
    var quietHoursStart: Int  // Hour (0-23)
    var quietHoursEnd: Int    // Hour (0-23)
    
    // Advanced Scoring: Per-Tier Frequency Multipliers (0.5 to 2.0)
    // Higher = more frequent reminders (base days are divided by this)
    var innerCircleFrequencyMultiplier: Double = 1.0
    var keyRelationshipsFrequencyMultiplier: Double = 1.0
    var broaderNetworkFrequencyMultiplier: Double = 1.0
    
    // Advanced Scoring: Per-Tier Priority Weight Multipliers (0.5 to 3.0)
    var innerCirclePriorityMultiplier: Double = 1.0
    var keyRelationshipsPriorityMultiplier: Double = 1.0
    var broaderNetworkPriorityMultiplier: Double = 1.0
    
    // Advanced Scoring: Global Multipliers
    var scoringGainMultiplier: Double = 1.0      // 0.5 to 2.0 (higher = stricter)
    var decayRateMultiplier: Double = 1.0        // 0.5 to 2.0 (higher = faster decay)
    var healthPenaltyMultiplier: Double = 1.0   // 0.0 to 2.0 (higher = more boost for low-health)
    
    var createdAt: Date
    var updatedAt: Date
    
    init(
        dailyQueueSize: Int = 5,
        enableUrgencyBonus: Bool = true,
        birthdayBonusPoints: Double = 15.0,
        milestoneBonusPoints: Double = 10.0,
        severelyOverdueBonusPoints: Double = 20.0,
        locationNotificationsEnabled: Bool = true,
        notificationCooldownHours: Int = NotificationCooldown.daily.rawValue,
        quietHoursEnabled: Bool = false,
        quietHoursStart: Int = 22,  // 10 PM
        quietHoursEnd: Int = 8       // 8 AM
    ) {
        self.id = UUID()
        self.dailyQueueSize = min(10, max(3, dailyQueueSize)) // Enforce 3-10 range
        self.enableUrgencyBonus = enableUrgencyBonus
        self.birthdayBonusPoints = birthdayBonusPoints
        self.milestoneBonusPoints = milestoneBonusPoints
        self.severelyOverdueBonusPoints = severelyOverdueBonusPoints
        self.locationNotificationsEnabled = locationNotificationsEnabled
        self.notificationCooldownHours = notificationCooldownHours
        self.quietHoursEnabled = quietHoursEnabled
        self.quietHoursStart = quietHoursStart
        self.quietHoursEnd = quietHoursEnd
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
    
    // MARK: - Location Notification Settings
    
    /// Update location notification enabled state
    func setLocationNotifications(enabled: Bool) {
        self.locationNotificationsEnabled = enabled
        self.updatedAt = Date()
    }
    
    /// Update notification cooldown frequency
    func setNotificationCooldown(_ cooldown: NotificationCooldown) {
        self.notificationCooldownHours = cooldown.rawValue
        self.updatedAt = Date()
    }
    
    /// Update quiet hours settings
    func setQuietHours(enabled: Bool, start: Int? = nil, end: Int? = nil) {
        self.quietHoursEnabled = enabled
        if let start = start {
            self.quietHoursStart = max(0, min(23, start))
        }
        if let end = end {
            self.quietHoursEnd = max(0, min(23, end))
        }
        self.updatedAt = Date()
    }
    
    /// Get the current cooldown enum value
    var notificationCooldown: NotificationCooldown {
        NotificationCooldown(rawValue: notificationCooldownHours) ?? .daily
    }
    
    /// Check if current time is within quiet hours
    var isInQuietHours: Bool {
        guard quietHoursEnabled else { return false }
        
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: Date())
        
        // Handle overnight quiet hours (e.g., 22:00 to 08:00)
        if quietHoursStart > quietHoursEnd {
            return currentHour >= quietHoursStart || currentHour < quietHoursEnd
        } else {
            return currentHour >= quietHoursStart && currentHour < quietHoursEnd
        }
    }
    
    // MARK: - Advanced Scoring Settings
    
    /// Get frequency multiplier for a specific priority tier
    func frequencyMultiplier(for priority: Priority) -> Double {
        switch priority {
        case .innerCircle:
            return innerCircleFrequencyMultiplier
        case .keyRelationships:
            return keyRelationshipsFrequencyMultiplier
        case .broaderNetwork:
            return broaderNetworkFrequencyMultiplier
        }
    }
    
    /// Get priority weight multiplier for a specific priority tier
    func priorityMultiplier(for priority: Priority) -> Double {
        switch priority {
        case .innerCircle:
            return innerCirclePriorityMultiplier
        case .keyRelationships:
            return keyRelationshipsPriorityMultiplier
        case .broaderNetwork:
            return broaderNetworkPriorityMultiplier
        }
    }
    
    /// Update frequency multiplier for a tier (clamped to 0.5-2.0)
    func setFrequencyMultiplier(_ value: Double, for priority: Priority) {
        let clamped = min(2.0, max(0.5, value))
        switch priority {
        case .innerCircle:
            innerCircleFrequencyMultiplier = clamped
        case .keyRelationships:
            keyRelationshipsFrequencyMultiplier = clamped
        case .broaderNetwork:
            broaderNetworkFrequencyMultiplier = clamped
        }
        self.updatedAt = Date()
    }
    
    /// Update priority weight multiplier for a tier (clamped to 0.5-3.0)
    func setPriorityMultiplier(_ value: Double, for priority: Priority) {
        let clamped = min(3.0, max(0.5, value))
        switch priority {
        case .innerCircle:
            innerCirclePriorityMultiplier = clamped
        case .keyRelationships:
            keyRelationshipsPriorityMultiplier = clamped
        case .broaderNetwork:
            broaderNetworkPriorityMultiplier = clamped
        }
        self.updatedAt = Date()
    }
    
    /// Update global scoring gain multiplier (clamped to 0.5-2.0)
    func setScoringGainMultiplier(_ value: Double) {
        scoringGainMultiplier = min(2.0, max(0.5, value))
        self.updatedAt = Date()
    }
    
    /// Update global decay rate multiplier (clamped to 0.5-2.0)
    func setDecayRateMultiplier(_ value: Double) {
        decayRateMultiplier = min(2.0, max(0.5, value))
        self.updatedAt = Date()
    }
    
    /// Update health penalty multiplier (clamped to 0.0-2.0)
    func setHealthPenaltyMultiplier(_ value: Double) {
        healthPenaltyMultiplier = min(2.0, max(0.0, value))
        self.updatedAt = Date()
    }
    
    /// Reset all advanced scoring settings to defaults
    func resetAdvancedToDefaults() {
        innerCircleFrequencyMultiplier = 1.0
        keyRelationshipsFrequencyMultiplier = 1.0
        broaderNetworkFrequencyMultiplier = 1.0
        innerCirclePriorityMultiplier = 1.0
        keyRelationshipsPriorityMultiplier = 1.0
        broaderNetworkPriorityMultiplier = 1.0
        scoringGainMultiplier = 1.0
        decayRateMultiplier = 1.0
        healthPenaltyMultiplier = 1.0
        self.updatedAt = Date()
    }
    
    /// Check if any advanced settings have been modified from defaults
    var hasCustomAdvancedSettings: Bool {
        innerCircleFrequencyMultiplier != 1.0 ||
        keyRelationshipsFrequencyMultiplier != 1.0 ||
        broaderNetworkFrequencyMultiplier != 1.0 ||
        innerCirclePriorityMultiplier != 1.0 ||
        keyRelationshipsPriorityMultiplier != 1.0 ||
        broaderNetworkPriorityMultiplier != 1.0 ||
        scoringGainMultiplier != 1.0 ||
        decayRateMultiplier != 1.0 ||
        healthPenaltyMultiplier != 1.0
    }
}
