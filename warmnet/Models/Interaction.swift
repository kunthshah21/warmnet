//
//  Interaction.swift
//  warmnet
//
//  Created on 26/12/2025.
//

import Foundation
import SwiftData

@Model
final class Interaction {
    var id: UUID
    var date: Date
    var notes: String
    var interactionType: InteractionType
    var contact: Contact?
    
    init(
        id: UUID = UUID(),
        date: Date,
        notes: String = "",
        interactionType: InteractionType,
        contact: Contact? = nil
    ) {
        self.id = id
        self.date = date
        self.notes = notes
        self.interactionType = interactionType
        self.contact = contact
    }
}

enum InteractionType: String, Codable, CaseIterable {
    case call = "Call"
    case text = "Text"
    case inPerson = "In Person"
    case email = "Email"
    case videoCall = "Video Call"
    
    var icon: String {
        switch self {
        case .call:
            return "phone.fill"
        case .text:
            return "message.fill"
        case .inPerson:
            return "person.2.fill"
        case .email:
            return "envelope.fill"
        case .videoCall:
            return "video.fill"
        }
    }
    
    var color: String {
        switch self {
        case .call:
            return "blue"
        case .text:
            return "green"
        case .inPerson:
            return "purple"
        case .email:
            return "orange"
        case .videoCall:
            return "mint"
        }
    }
}
