//
//  UrgencyBonusCalculator.swift
//  warmnet
//
//  Created on 26/12/2025.
//

import Foundation
import SwiftData

/// Calculates urgency bonuses for contacts based on time-sensitive events
struct UrgencyBonusCalculator {
    
    // MARK: - Main Calculation
    
    /// Calculate total urgency bonus for a contact using user settings
    /// Returns 0 if urgency bonuses are disabled or no urgent conditions are met
    static func calculateBonus(
        for contact: Contact,
        settings: UserSettings,
        currentDate: Date = Date()
    ) -> Double {
        guard settings.enableUrgencyBonus else {
            return 0.0
        }
        
        var totalBonus: Double = 0.0
        
        // Birthday bonus
        totalBonus += calculateBirthdayBonus(
            for: contact,
            bonusPoints: settings.birthdayBonusPoints,
            currentDate: currentDate
        )
        
        // Milestone bonus
        totalBonus += calculateMilestoneBonus(
            for: contact,
            bonusPoints: settings.milestoneBonusPoints,
            currentDate: currentDate
        )
        
        // Severely overdue bonus
        totalBonus += calculateSeverelyOverdueBonus(
            for: contact,
            bonusPoints: settings.severelyOverdueBonusPoints,
            currentDate: currentDate
        )
        
        return totalBonus
    }
    
    // MARK: - Individual Bonus Calculations
    
    /// Check for upcoming birthday within 7 days
    private static func calculateBirthdayBonus(
        for contact: Contact,
        bonusPoints: Double,
        currentDate: Date
    ) -> Double {
        guard let birthday = contact.birthday else {
            return 0.0
        }
        
        // Get days until next birthday
        guard let daysUntil = daysUntilNextOccurrence(of: birthday, from: currentDate) else {
            return 0.0
        }
        
        // Bonus if birthday is within the next 7 days
        if daysUntil >= 0 && daysUntil <= 7 {
            return bonusPoints
        }
        
        return 0.0
    }
    
    /// Check for upcoming milestones within 14 days
    private static func calculateMilestoneBonus(
        for contact: Contact,
        bonusPoints: Double,
        currentDate: Date
    ) -> Double {
        let calendar = Calendar.current
        
        for milestone in contact.milestones {
            // Calculate days until milestone
            let components = calendar.dateComponents([.day], from: currentDate, to: milestone.date)
            if let daysUntil = components.day, daysUntil >= 0 && daysUntil <= 14 {
                return bonusPoints // Return on first matching milestone
            }
        }
        
        return 0.0
    }
    
    /// Check if contact is severely overdue (2x past their frequency)
    private static func calculateSeverelyOverdueBonus(
        for contact: Contact,
        bonusPoints: Double,
        currentDate: Date
    ) -> Double {
        guard let _ = contact.nextTouchDate,
              let priority = contact.priority else {
            return 0.0
        }
        
        let config = TierConfiguration.forPriority(priority)
        let daysOverdue = ReminderScheduler.daysOverdue(contact, currentDate: currentDate)
        
        // Severely overdue = more than 2x the frequency period
        let severelyOverdueThreshold = config.frequencyDays * 2
        
        if daysOverdue > severelyOverdueThreshold {
            return bonusPoints
        }
        
        return 0.0
    }
    
    // MARK: - Helper Methods
    
    /// Calculate days until the next occurrence of an annual date (like a birthday)
    private static func daysUntilNextOccurrence(
        of date: Date,
        from currentDate: Date
    ) -> Int? {
        let calendar = Calendar.current
        
        // Get the birthday components (month and day)
        let birthdayComponents = calendar.dateComponents([.month, .day], from: date)
        
        guard let month = birthdayComponents.month,
              let day = birthdayComponents.day else {
            return nil
        }
        
        // Get current year's birthday
        let currentYear = calendar.component(.year, from: currentDate)
        var nextBirthdayComponents = DateComponents()
        nextBirthdayComponents.year = currentYear
        nextBirthdayComponents.month = month
        nextBirthdayComponents.day = day
        
        guard var nextBirthday = calendar.date(from: nextBirthdayComponents) else {
            return nil
        }
        
        // If birthday already passed this year, use next year
        if nextBirthday < currentDate {
            nextBirthdayComponents.year = currentYear + 1
            guard let nextYearBirthday = calendar.date(from: nextBirthdayComponents) else {
                return nil
            }
            nextBirthday = nextYearBirthday
        }
        
        // Calculate days between
        let components = calendar.dateComponents([.day], from: currentDate, to: nextBirthday)
        return components.day
    }
    
    // MARK: - Debug Information (for UI display)
    
    /// Get detailed breakdown of bonus calculations for a contact
    static func getBonusBreakdown(
        for contact: Contact,
        settings: UserSettings,
        currentDate: Date = Date()
    ) -> BonusBreakdown {
        guard settings.enableUrgencyBonus else {
            return BonusBreakdown(
                birthdayBonus: 0,
                birthdayDaysUntil: nil,
                milestoneBonus: 0,
                upcomingMilestone: nil,
                severelyOverdueBonus: 0,
                totalBonus: 0
            )
        }
        
        let birthdayBonus = calculateBirthdayBonus(
            for: contact,
            bonusPoints: settings.birthdayBonusPoints,
            currentDate: currentDate
        )
        
        let birthdayDaysUntil: Int? = contact.birthday != nil ?
            daysUntilNextOccurrence(of: contact.birthday!, from: currentDate) : nil
        
        let milestoneBonus = calculateMilestoneBonus(
            for: contact,
            bonusPoints: settings.milestoneBonusPoints,
            currentDate: currentDate
        )
        
        let upcomingMilestone = contact.milestones.first { milestone in
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: currentDate, to: milestone.date)
            if let daysUntil = components.day {
                return daysUntil >= 0 && daysUntil <= 14
            }
            return false
        }
        
        let overdueBonus = calculateSeverelyOverdueBonus(
            for: contact,
            bonusPoints: settings.severelyOverdueBonusPoints,
            currentDate: currentDate
        )
        
        return BonusBreakdown(
            birthdayBonus: birthdayBonus,
            birthdayDaysUntil: birthdayDaysUntil,
            milestoneBonus: milestoneBonus,
            upcomingMilestone: upcomingMilestone,
            severelyOverdueBonus: overdueBonus,
            totalBonus: birthdayBonus + milestoneBonus + overdueBonus
        )
    }
    
    struct BonusBreakdown {
        let birthdayBonus: Double
        let birthdayDaysUntil: Int?
        let milestoneBonus: Double
        let upcomingMilestone: Milestone?
        let severelyOverdueBonus: Double
        let totalBonus: Double
        
        var hasBirthday: Bool { birthdayBonus > 0 }
        var hasMilestone: Bool { milestoneBonus > 0 }
        var isSeverelyOverdue: Bool { severelyOverdueBonus > 0 }
        var hasAnyBonus: Bool { totalBonus > 0 }
        
        /// UI-friendly description of urgency reasons
        var urgencyDescription: String {
            var reasons: [String] = []
            
            if let days = birthdayDaysUntil, hasBirthday {
                reasons.append("🎂 Birthday in \(days) day\(days == 1 ? "" : "s")")
            }
            
            if let milestone = upcomingMilestone, hasMilestone {
                let calendar = Calendar.current
                let components = calendar.dateComponents([.day], from: Date(), to: milestone.date)
                if let days = components.day {
                    reasons.append("🎯 \(milestone.title) in \(days) day\(days == 1 ? "" : "s")")
                }
            }
            
            if isSeverelyOverdue {
                reasons.append("⚠️ Very overdue")
            }
            
            return reasons.isEmpty ? "" : reasons.joined(separator: " • ")
        }
    }
}
