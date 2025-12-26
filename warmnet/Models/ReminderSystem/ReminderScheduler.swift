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
