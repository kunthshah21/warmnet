//
//  ReminderScheduler.swift
//  warmnet
//
//  Created on 26/12/2025.
//

import Foundation

/// Core reminder scheduling algorithm implementing random distribution and variance
struct ReminderScheduler {
    
    // MARK: - Contact Creation (Random Distribution)
    
    /// Calculate initial next touch date for a new contact with random distribution
    /// Algorithm: next_touch_date = current_date + RANDOM(0, frequency_days)
    static func scheduleNewContact(_ contact: Contact, currentDate: Date = Date()) {
        // Check for custom schedule override
        if contact.useCustomSchedule {
            if let nextDate = calculateNextCustomDate(contact: contact, from: currentDate) {
                contact.nextTouchDate = nextDate
                contact.lastContacted = nil
                contact.updatedAt = Date()
                return
            }
        }
        
        guard let priority = contact.priority else {
            contact.nextTouchDate = nil
            return
        }
        
        let config = TierConfiguration.forPriority(priority)
        let randomOffset = Int.random(in: 0...config.frequencyDays)
        
        if let nextDate = Calendar.current.date(byAdding: .day, value: randomOffset, to: currentDate) {
            contact.nextTouchDate = nextDate
        }
        
        contact.lastContacted = nil
        contact.updatedAt = Date()
    }
    
    // MARK: - Interaction Logging (Variance Recalculation)
    
    /// Recalculate next touch date after an interaction with variance
    /// Algorithm:
    /// buffer = frequency_days × variance_percent
    /// random_adjustment = RANDOM(-buffer, +buffer)
    /// next_touch_date = current_date + frequency_days + random_adjustment
    static func rescheduleAfterInteraction(_ contact: Contact, interactionDate: Date = Date()) {
        // Check for custom schedule override
        if contact.useCustomSchedule {
            if let nextDate = calculateNextCustomDate(contact: contact, from: interactionDate) {
                contact.nextTouchDate = nextDate
                contact.lastContacted = interactionDate
                contact.updatedAt = Date()
                return
            }
        }
        
        guard let priority = contact.priority else {
            contact.nextTouchDate = nil
            return
        }
        
        let config = TierConfiguration.forPriority(priority)
        
        // Calculate variance buffer
        let buffer = config.varianceBuffer
        let randomAdjustment = Int.random(in: -buffer...buffer)
        
        // Apply base frequency + random adjustment
        let totalDays = config.frequencyDays + randomAdjustment
        
        if let nextDate = Calendar.current.date(byAdding: .day, value: totalDays, to: interactionDate) {
            contact.nextTouchDate = nextDate
        }
        
        contact.lastContacted = interactionDate
        contact.updatedAt = Date()
    }
    
    // MARK: - Custom Schedule Logic
    
    private static func calculateNextCustomDate(contact: Contact, from date: Date) -> Date? {
        guard let freqRaw = contact.scheduleFrequency,
              let interval = contact.scheduleInterval,
              interval > 0 else { return nil }
        
        let calendar = Calendar.current
        
        if freqRaw == "Day(s)" {
            return calendar.date(byAdding: .day, value: interval, to: date)
        }
        
        if freqRaw == "Week(s)" {
            // If no specific days selected, just add weeks
            guard let daysRaw = contact.scheduleDays, !daysRaw.isEmpty else {
                return calendar.date(byAdding: .day, value: interval * 7, to: date)
            }
            
            // Map day names to weekday integers (Sunday=1, Monday=2, ...)
            let targetWeekdays = daysRaw.compactMap { dayName -> Int? in
                switch dayName {
                case "Sunday": return 1
                case "Monday": return 2
                case "Tuesday": return 3
                case "Wednesday": return 4
                case "Thursday": return 5
                case "Friday": return 6
                case "Saturday": return 7
                default: return nil
                }
            }.sorted()
            
            let currentWeekday = calendar.component(.weekday, from: date)
            
            // 1. Check if any target day is later in the SAME week
            for targetDay in targetWeekdays {
                if targetDay > currentWeekday {
                    // Found a day later this week
                    let components = DateComponents(weekday: targetDay)
                    return calendar.nextDate(after: date, matching: components, matchingPolicy: .nextTime)
                }
            }
            
            // 2. If not, we need to jump to the next occurrence in a future week
            // Find the first target day (e.g., Monday)
            if let firstTarget = targetWeekdays.first {
                let components = DateComponents(weekday: firstTarget)
                guard let nextOccurrence = calendar.nextDate(after: date, matching: components, matchingPolicy: .nextTime) else { return nil }
                
                // If interval is 1, nextOccurrence is correct (it's in next week)
                // If interval is 2, we need to add 1 more week (skip 1 week)
                let weeksToAdd = interval - 1
                if weeksToAdd > 0 {
                    return calendar.date(byAdding: .day, value: weeksToAdd * 7, to: nextOccurrence)
                }
                return nextOccurrence
            }
        }
        
        // Fallback for other frequencies if added later
        if freqRaw == "Month(s)" {
            return calendar.date(byAdding: .month, value: interval, to: date)
        }
        
        if freqRaw == "Year(s)" {
            return calendar.date(byAdding: .year, value: interval, to: date)
        }
        
        return nil
    }
    
    // MARK: - Helper Methods
    
    /// Check if a contact is overdue
    static func isOverdue(_ contact: Contact, currentDate: Date = Date()) -> Bool {
        guard let nextTouch = contact.nextTouchDate else {
            return false
        }
        return currentDate > nextTouch
    }
    
    /// Calculate days overdue (0 if not overdue)
    static func daysOverdue(_ contact: Contact, currentDate: Date = Date()) -> Int {
        guard let nextTouch = contact.nextTouchDate else {
            return 0
        }
        
        let days = Calendar.current.dateComponents([.day], from: nextTouch, to: currentDate).day ?? 0
        return max(0, days)
    }
}
