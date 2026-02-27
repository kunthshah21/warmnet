//
//  Milestone.swift
//  warmnet
//
//  Created on 26/12/2025.
//

import Foundation
import SwiftData

@Model
final class Milestone {
    var id: UUID
    var title: String
    var date: Date
    var notes: String
    var contact: Contact?
    
    init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        notes: String = "",
        contact: Contact? = nil
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.notes = notes
        self.contact = contact
    }
}
