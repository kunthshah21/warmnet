//
//  ConnectionHealthEngine.swift
//  warmnet
//
//  Core engine for tracking and updating connection health scores.
//  Integrates with the reminder system to provide a unified feedback loop.
//

import Foundation
import SwiftData

struct ConnectionHealthEngine {
    
    // MARK: - Scoring Constants
    
    private enum ScoringConstants {
        static let baseOnTimePoints: Double = 8.0
        static let maxOnTimePoints: Double = 15.0
        static let minLatePoints: Double = 3.0
        static let earlyBonusMultiplier: Double = 0.5
        static let latePenaltyMultiplier: Double = 0.5
        static let manualReminderBonus: Double = 2.0
        static let streakMilestone: Int = 3
        static let streakMilestoneBonus: Double = 3.0
        static let maxScore: Double = 100.0
        static let minScore: Double = 0.0
        static let defaultScore: Double = 50.0
    }
    
    private enum DecayConstants {
        static let innerCircleDecay: Double = 0.15
        static let keyRelationshipsDecay: Double = 0.05
        static let broaderNetworkDecay: Double = 0.02
        static let severelyOverdueDecay: Double = 0.5
    }
    
    // MARK: - Record Interaction
    
    /// Records an interaction and updates the contact's connection health score.
    /// This is the primary entry point for the unified reminder system.
    ///
    /// - Parameters:
    ///   - contact: The contact that was interacted with
    ///   - interaction: The interaction that was logged
    ///   - manualReminder: Optional manual reminder that this interaction fulfills
    ///   - settings: Optional user settings for customized scoring behavior
    ///   - currentDate: The current date (defaults to now, injectable for testing)
    static func recordInteraction(
        contact: Contact,
        interaction: Interaction,
        manualReminder: ManualReminder? = nil,
        settings: UserSettings? = nil,
        currentDate: Date = Date()
    ) {
        let interactionDate = interaction.date
        
        // Calculate timing relative to due date
        let dueDate = contact.nextTouchDate ?? contact.nextReminderDate
        let calendar = Calendar.current
        let daysFromDue = calendar.dateComponents([.day], from: interactionDate, to: dueDate).day ?? 0
        let wasOnTime = daysFromDue >= 0
        
        // Calculate points earned based on timing
        var pointsEarned: Double
        
        if wasOnTime {
            let daysEarly = max(0, daysFromDue)
            pointsEarned = min(
                ScoringConstants.maxOnTimePoints,
                ScoringConstants.baseOnTimePoints + Double(daysEarly) * ScoringConstants.earlyBonusMultiplier
            )
            contact.streakCount += 1
        } else {
            let daysLate = abs(daysFromDue)
            pointsEarned = max(
                ScoringConstants.minLatePoints,
                ScoringConstants.baseOnTimePoints - Double(daysLate) * ScoringConstants.latePenaltyMultiplier
            )
            contact.streakCount = 0
        }
        
        // Manual reminder fulfillment bonus
        if manualReminder != nil {
            pointsEarned += ScoringConstants.manualReminderBonus
        }
        
        // Streak milestone bonus (every 3 consecutive on-time interactions)
        if contact.streakCount > 0 && contact.streakCount % ScoringConstants.streakMilestone == 0 {
            pointsEarned += ScoringConstants.streakMilestoneBonus
        }
        
        // Apply scoring gain multiplier from settings (higher = stricter, points worth less)
        // Inverted: user sees "Forgiving" to "Strict", so we divide by the multiplier
        if let settings = settings {
            pointsEarned = pointsEarned / settings.scoringGainMultiplier
        }
        
        // Update connection score (clamped to 0-100)
        contact.connectionScore = min(
            ScoringConstants.maxScore,
            max(ScoringConstants.minScore, contact.connectionScore + pointsEarned)
        )
        
        // Update interaction count
        contact.totalInteractionCount += 1
        
        // Update average response days (rolling average)
        if let nextTouch = contact.nextTouchDate {
            let responseDays = Double(abs(
                calendar.dateComponents([.day], from: nextTouch, to: interactionDate).day ?? 0
            ))
            let count = Double(contact.totalInteractionCount)
            if count > 1 {
                contact.averageResponseDays =
                    ((contact.averageResponseDays * (count - 1)) + responseDays) / count
            } else {
                contact.averageResponseDays = responseDays
            }
        }
        
        // Delegate to ReminderScheduler for next touch date calculation
        ReminderScheduler.rescheduleAfterInteraction(contact, interactionDate: interactionDate, settings: settings)
        
        // Update timestamps
        contact.lastScoreUpdate = currentDate
        contact.updatedAt = currentDate
    }
    
    // MARK: - Apply Decay
    
    /// Applies passive decay to all contacts' connection scores.
    /// Should be called on app activation to simulate relationship cooling.
    ///
    /// - Parameters:
    ///   - contacts: Array of contacts to apply decay to
    ///   - settings: Optional user settings for customized decay behavior
    ///   - currentDate: The current date (defaults to now, injectable for testing)
    static func applyDecay(to contacts: [Contact], settings: UserSettings? = nil, currentDate: Date = Date()) {
        let calendar = Calendar.current
        let decayMultiplier = settings?.decayRateMultiplier ?? 1.0
        
        for contact in contacts {
            guard let lastUpdate = contact.lastScoreUpdate else {
                contact.lastScoreUpdate = currentDate
                continue
            }
            
            let daysSinceUpdate = calendar.dateComponents([.day], from: lastUpdate, to: currentDate).day ?? 0
            guard daysSinceUpdate > 0 else { continue }
            
            // Determine decay rate based on tier
            let baseDecay = decayRateForPriority(contact.priority)
            
            // Check if severely overdue (> 2x frequency)
            let daysOverdue = ReminderScheduler.daysOverdue(contact, currentDate: currentDate)
            let frequencyDays = TierConfiguration.forPriority(contact.priority ?? .broaderNetwork).frequencyDays
            let isSeverelyOverdue = daysOverdue > frequencyDays * 2
            
            let decayRate = isSeverelyOverdue ? DecayConstants.severelyOverdueDecay : baseDecay
            let totalDecay = decayRate * Double(daysSinceUpdate) * decayMultiplier
            
            // Apply decay (clamped to minimum score)
            contact.connectionScore = max(
                ScoringConstants.minScore,
                contact.connectionScore - totalDecay
            )
            
            contact.lastScoreUpdate = currentDate
        }
    }
    
    // MARK: - Health Penalty for Queue
    
    /// Calculates the health penalty to add to priority score in the daily queue.
    /// Low-health contacts get a boost to surface them in the queue.
    ///
    /// - Parameters:
    ///   - contact: The contact to calculate penalty for
    ///   - settings: Optional user settings for customized health boost behavior
    /// - Returns: The penalty value to add to priority score
    static func healthPenalty(for contact: Contact, settings: UserSettings? = nil) -> Double {
        let multiplier = settings?.healthPenaltyMultiplier ?? 1.0
        return max(0, (ScoringConstants.defaultScore - contact.connectionScore) * 0.3 * multiplier)
    }
    
    // MARK: - Helpers
    
    private static func decayRateForPriority(_ priority: Priority?) -> Double {
        switch priority {
        case .innerCircle:
            return DecayConstants.innerCircleDecay
        case .keyRelationships:
            return DecayConstants.keyRelationshipsDecay
        case .broaderNetwork, .none:
            return DecayConstants.broaderNetworkDecay
        }
    }
    
    // MARK: - Repeat Reminder Support
    
    /// Creates the next occurrence of a repeating reminder.
    /// Call this after marking a reminder as completed if it has a repeat interval.
    ///
    /// - Parameters:
    ///   - reminder: The completed reminder to spawn a new occurrence from
    ///   - context: The SwiftData model context
    /// - Returns: The newly created reminder, or nil if the reminder doesn't repeat
    static func createNextOccurrence(
        from reminder: ManualReminder,
        context: ModelContext
    ) -> ManualReminder? {
        guard reminder.repeatInterval != .never else { return nil }
        guard let currentDate = reminder.combinedDateTime else { return nil }
        
        let calendar = Calendar.current
        var nextDate: Date?
        
        switch reminder.repeatInterval {
        case .never:
            return nil
        case .hourly:
            nextDate = calendar.date(byAdding: .hour, value: 1, to: currentDate)
        case .daily:
            nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate)
        case .weekdays:
            nextDate = nextWeekday(from: currentDate, excludeWeekends: true)
        case .weekends:
            nextDate = nextWeekendDay(from: currentDate)
        case .weekly:
            nextDate = calendar.date(byAdding: .day, value: 7, to: currentDate)
        case .biweekly:
            nextDate = calendar.date(byAdding: .day, value: 14, to: currentDate)
        case .monthly:
            nextDate = calendar.date(byAdding: .month, value: 1, to: currentDate)
        case .every3Months:
            nextDate = calendar.date(byAdding: .month, value: 3, to: currentDate)
        case .every6Months:
            nextDate = calendar.date(byAdding: .month, value: 6, to: currentDate)
        }
        
        guard let computedDate = nextDate else { return nil }
        
        let newReminder = ManualReminder(
            contact: reminder.contact,
            title: reminder.title,
            reminderDate: computedDate,
            reminderTime: reminder.reminderTime,
            note: reminder.note,
            isUrgent: reminder.isUrgent,
            repeatInterval: reminder.repeatInterval,
            hasDate: reminder.hasDate,
            hasTime: reminder.hasTime,
            status: .pending,
            source: reminder.source
        )
        
        context.insert(newReminder)
        return newReminder
    }
    
    private static func nextWeekday(from date: Date, excludeWeekends: Bool) -> Date? {
        let calendar = Calendar.current
        var nextDate = calendar.date(byAdding: .day, value: 1, to: date)
        
        while let current = nextDate {
            let weekday = calendar.component(.weekday, from: current)
            if weekday != 1 && weekday != 7 {
                return current
            }
            nextDate = calendar.date(byAdding: .day, value: 1, to: current)
        }
        return nil
    }
    
    private static func nextWeekendDay(from date: Date) -> Date? {
        let calendar = Calendar.current
        var nextDate = calendar.date(byAdding: .day, value: 1, to: date)
        
        while let current = nextDate {
            let weekday = calendar.component(.weekday, from: current)
            if weekday == 1 || weekday == 7 {
                return current
            }
            nextDate = calendar.date(byAdding: .day, value: 1, to: current)
        }
        return nil
    }
}
