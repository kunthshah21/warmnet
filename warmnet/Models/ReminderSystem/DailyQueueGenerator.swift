//
//  DailyQueueGenerator.swift
//  warmnet
//
//  Created on 26/12/2025.
//

import Foundation
import SwiftData

/// Generates the daily queue of contacts to reach out to
struct DailyQueueGenerator {
    
    /// Contact with calculated priority score for queue ordering
    struct QueueContact {
        let contact: Contact
        let priorityScore: Double
        let daysOverdue: Int
        let urgencyBonus: Double
        let bonusBreakdown: UrgencyBonusCalculator.BonusBreakdown
    }
    
    // MARK: - Main Queue Generation
    
    /// Generate daily queue with smart prioritization
    /// Algorithm:
    /// 1. Get all contacts where next_touch_date <= current_date
    /// 2. Calculate priority_score = (days_overdue × tier_weight) + urgency_bonus
    /// 3. Ensure top 2 Inner Circle contacts (if available)
    /// 4. Fill remaining slots with highest priority scores
    /// 5. Return up to max_queue_size contacts
    static func generateQueue(
        from contacts: [Contact],
        settings: UserSettings,
        maxQueueSize: Int = 5,
        currentDate: Date = Date()
    ) -> [Contact] {
        // Step 1: Filter overdue contacts
        let overdueContacts = contacts.filter { contact in
            ReminderScheduler.isOverdue(contact, currentDate: currentDate)
        }
        
        guard !overdueContacts.isEmpty else {
            return []
        }
        
        // Step 2: Calculate priority scores for all candidates (with urgency bonus)
        let scoredContacts = overdueContacts.compactMap { contact -> QueueContact? in
            guard let priority = contact.priority else { return nil }
            
            let daysOverdue = ReminderScheduler.daysOverdue(contact, currentDate: currentDate)
            let config = TierConfiguration.forPriority(priority)
            
            // Calculate urgency bonus
            let urgencyBonus = UrgencyBonusCalculator.calculateBonus(
                for: contact,
                settings: settings,
                currentDate: currentDate
            )
            let bonusBreakdown = UrgencyBonusCalculator.getBonusBreakdown(
                for: contact,
                settings: settings,
                currentDate: currentDate
            )
            
            // Priority score = (days_overdue × tier_weight) + urgency_bonus
            let priorityScore = Double(daysOverdue * config.tierWeight) + urgencyBonus
            
            return QueueContact(
                contact: contact,
                priorityScore: priorityScore,
                daysOverdue: daysOverdue,
                urgencyBonus: urgencyBonus,
                bonusBreakdown: bonusBreakdown
            )
        }
        
        // Step 3 & 4: Build queue with Inner Circle priority
        var queue: [Contact] = []
        
        // First, add top 2 Inner Circle contacts
        let innerCircleContacts = scoredContacts
            .filter { $0.contact.priority == .innerCircle }
            .sorted { $0.priorityScore > $1.priorityScore }
        
        let innerCircleToAdd = min(2, innerCircleContacts.count)
        queue.append(contentsOf: innerCircleContacts.prefix(innerCircleToAdd).map { $0.contact })
        
        // Then fill remaining slots with highest priority
        let remainingSlots = maxQueueSize - queue.count
        if remainingSlots > 0 {
            let contactIdsInQueue = Set(queue.map { $0.id })
            
            let remainingContacts = scoredContacts
                .filter { !contactIdsInQueue.contains($0.contact.id) }
                .sorted { $0.priorityScore > $1.priorityScore }
            
            queue.append(contentsOf: remainingContacts.prefix(remainingSlots).map { $0.contact })
        }
        
        return queue
    }
    
    // MARK: - SwiftData Integration
    
    /// Fetch daily queue directly from SwiftData context
    static func fetchDailyQueue(
        from context: ModelContext,
        maxQueueSize: Int? = nil,
        currentDate: Date = Date()
    ) throws -> [Contact] {
        // Fetch user settings for queue size and urgency bonus config
        let settings = UserSettings.getOrCreate(from: context)
        let queueSize = maxQueueSize ?? settings.dailyQueueSize
        
        // Fetch all contacts
        let descriptor = FetchDescriptor<Contact>()
        let allContacts = try context.fetch(descriptor)
        
        // Generate and return queue with urgency bonus calculation
        return generateQueue(
            from: allContacts,
            settings: settings,
            maxQueueSize: queueSize,
            currentDate: currentDate
        )
    }
    
    // MARK: - Statistics
    
    /// Get queue statistics for display
    static func getQueueStatistics(
        from contacts: [Contact],
        currentDate: Date = Date()
    ) -> QueueStatistics {
        let overdueContacts = contacts.filter { contact in
            ReminderScheduler.isOverdue(contact, currentDate: currentDate)
        }
        
        let innerCircleOverdue = overdueContacts.filter { $0.priority == .innerCircle }.count
        let keyRelationshipsOverdue = overdueContacts.filter { $0.priority == .keyRelationships }.count
        let broaderNetworkOverdue = overdueContacts.filter { $0.priority == .broaderNetwork }.count
        
        return QueueStatistics(
            totalOverdue: overdueContacts.count,
            innerCircleOverdue: innerCircleOverdue,
            keyRelationshipsOverdue: keyRelationshipsOverdue,
            broaderNetworkOverdue: broaderNetworkOverdue
        )
    }
    
    struct QueueStatistics {
        let totalOverdue: Int
        let innerCircleOverdue: Int
        let keyRelationshipsOverdue: Int
        let broaderNetworkOverdue: Int
    }
    
    // MARK: - Queue with Bonus Details (for UI)
    
    /// Fetch daily queue with detailed urgency bonus information for UI display
    static func fetchDailyQueueWithDetails(
        from context: ModelContext,
        maxQueueSize: Int? = nil,
        currentDate: Date = Date()
    ) throws -> [QueueContact] {
        // Fetch user settings
        let settings = UserSettings.getOrCreate(from: context)
        let queueSize = maxQueueSize ?? settings.dailyQueueSize
        
        // Fetch all contacts
        let descriptor = FetchDescriptor<Contact>()
        let allContacts = try context.fetch(descriptor)
        
        // Filter overdue contacts
        let overdueContacts = allContacts.filter { contact in
            ReminderScheduler.isOverdue(contact, currentDate: currentDate)
        }
        
        guard !overdueContacts.isEmpty else {
            return []
        }
        
        // Calculate priority scores with urgency bonuses
        let scoredContacts = overdueContacts.compactMap { contact -> QueueContact? in
            guard let priority = contact.priority else { return nil }
            
            let daysOverdue = ReminderScheduler.daysOverdue(contact, currentDate: currentDate)
            let config = TierConfiguration.forPriority(priority)
            
            let urgencyBonus = UrgencyBonusCalculator.calculateBonus(
                for: contact,
                settings: settings,
                currentDate: currentDate
            )
            let bonusBreakdown = UrgencyBonusCalculator.getBonusBreakdown(
                for: contact,
                settings: settings,
                currentDate: currentDate
            )
            
            let priorityScore = Double(daysOverdue * config.tierWeight) + urgencyBonus
            
            return QueueContact(
                contact: contact,
                priorityScore: priorityScore,
                daysOverdue: daysOverdue,
                urgencyBonus: urgencyBonus,
                bonusBreakdown: bonusBreakdown
            )
        }
        
        // Build queue with Inner Circle priority
        var queue: [QueueContact] = []
        
        let innerCircleContacts = scoredContacts
            .filter { $0.contact.priority == .innerCircle }
            .sorted { $0.priorityScore > $1.priorityScore }
        
        let innerCircleToAdd = min(2, innerCircleContacts.count)
        queue.append(contentsOf: innerCircleContacts.prefix(innerCircleToAdd))
        
        let remainingSlots = queueSize - queue.count
        if remainingSlots > 0 {
            let contactIdsInQueue = Set(queue.map { $0.contact.id })
            
            let remainingContacts = scoredContacts
                .filter { !contactIdsInQueue.contains($0.contact.id) }
                .sorted { $0.priorityScore > $1.priorityScore }
            
            queue.append(contentsOf: remainingContacts.prefix(remainingSlots))
        }
        
        return queue
    }
}
