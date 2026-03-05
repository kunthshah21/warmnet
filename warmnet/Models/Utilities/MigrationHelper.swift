//
//  MigrationHelper.swift
//  warmnet
//
//  Created on 26/12/2025.
//

import Foundation
import SwiftData

@MainActor
class MigrationHelper {
    /// Migrates existing contacts with lastContacted to create initial Interaction records
    static func migrateContactInteractions(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Contact>()
        
        do {
            let contacts = try modelContext.fetch(descriptor)
            var migratedCount = 0
            
            for contact in contacts {
                // Check if contact has lastContacted but no interactions
                if let lastDate = contact.lastContacted,
                   contact.interactions.isEmpty {
                    
                    // Create initial interaction from lastInteractionDate
                    let interaction = Interaction(
                        date: lastDate,
                        notes: "Migrated from previous interaction tracking",
                        interactionType: .inPerson, // Default to in-person for legacy data
                        contact: contact
                    )
                    
                    modelContext.insert(interaction)
                    migratedCount += 1
                }
            }
            
            if migratedCount > 0 {
                try modelContext.save()
            }
        } catch { }
    }
    
    /// Checks if migration has already been performed
    static func needsMigration(modelContext: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<Contact>()
        
        do {
            let contacts = try modelContext.fetch(descriptor)
            
            // Check if any contact has lastContacted but no interactions
            return contacts.contains { (contact: Contact) in
                contact.lastContacted != nil && contact.interactions.isEmpty
            }
        } catch {
            return false
        }
    }
    
    /// Migrates existing data to support the Connection Health Engine
    /// - Sets totalInteractionCount from existing interactions
    /// - Calculates initial connectionScore based on interaction recency
    /// - Initializes lastScoreUpdate
    /// - Sets ManualReminder lifecycle fields if missing
    static func migrateConnectionHealth(modelContext: ModelContext) {
        let contactDescriptor = FetchDescriptor<Contact>()
        let reminderDescriptor = FetchDescriptor<ManualReminder>()
        
        do {
            let contacts = try modelContext.fetch(contactDescriptor)
            var migratedContacts = 0
            
            for contact in contacts {
                // Skip if already migrated (has lastScoreUpdate set)
                guard contact.lastScoreUpdate == nil else { continue }
                
                // Set interaction count from existing interactions
                contact.totalInteractionCount = contact.interactions.count
                
                // Calculate initial connection score based on recency
                contact.connectionScore = calculateInitialScore(for: contact)
                
                // Initialize lastScoreUpdate
                contact.lastScoreUpdate = Date()
                
                migratedContacts += 1
            }
            
            // Migrate ManualReminder records
            let reminders = try modelContext.fetch(reminderDescriptor)
            var migratedReminders = 0
            
            for reminder in reminders {
                // Ensure status and source are properly set for legacy records
                if reminder.statusRaw.isEmpty {
                    reminder.statusRaw = ReminderStatus.pending.rawValue
                    migratedReminders += 1
                }
                if reminder.sourceRaw.isEmpty {
                    reminder.sourceRaw = reminder.isUrgent
                        ? ReminderSource.urgent.rawValue
                        : ReminderSource.manual.rawValue
                    migratedReminders += 1
                }
            }
            
            if migratedContacts > 0 || migratedReminders > 0 {
                try modelContext.save()
            }
        } catch { }
    }
    
    /// Calculates initial connection score based on contact data
    private static func calculateInitialScore(for contact: Contact) -> Double {
        let baseScore: Double = 50.0
        let calendar = Calendar.current
        let now = Date()
        
        // If no interactions, return base score
        guard !contact.interactions.isEmpty else {
            return baseScore
        }
        
        // Get most recent interaction date
        guard let lastInteractionDate = contact.interactions.max(by: { $0.date < $1.date })?.date else {
            return baseScore
        }
        
        // Calculate days since last interaction
        let daysSinceInteraction = calendar.dateComponents([.day], from: lastInteractionDate, to: now).day ?? 0
        
        // Get expected frequency for this contact's tier
        let config = TierConfiguration.forPriority(contact.priority ?? .broaderNetwork)
        let expectedFrequency = config.frequencyDays
        
        // Calculate score adjustment based on how recently they were contacted
        // If within expected frequency: boost score
        // If overdue: reduce score proportionally
        if daysSinceInteraction <= expectedFrequency {
            let freshnessBonus = Double(expectedFrequency - daysSinceInteraction) / Double(expectedFrequency) * 15.0
            return min(100.0, baseScore + freshnessBonus)
        } else {
            let overdueRatio = Double(daysSinceInteraction - expectedFrequency) / Double(expectedFrequency)
            let overduePenalty = min(25.0, overdueRatio * 10.0)
            return max(25.0, baseScore - overduePenalty)
        }
    }
    
    /// Checks if connection health migration is needed
    static func needsConnectionHealthMigration(modelContext: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<Contact>()
        
        do {
            let contacts = try modelContext.fetch(descriptor)
            return contacts.contains { $0.lastScoreUpdate == nil && !$0.interactions.isEmpty }
        } catch {
            return false
        }
    }
}
