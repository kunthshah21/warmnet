//
//  ManualReminder.swift
//  warmnet
//

import Foundation
import SwiftData

@Model
final class ManualReminder {
    var id: UUID
    var reminderDate: Date
    var note: String
    var createdAt: Date
    
    @Relationship var contact: Contact

    init(contact: Contact, reminderDate: Date, note: String = "") {
        self.id = UUID()
        self.contact = contact
        self.reminderDate = reminderDate
        self.note = note
        self.createdAt = Date()
    }
}
