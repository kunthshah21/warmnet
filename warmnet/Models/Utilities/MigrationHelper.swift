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
}
