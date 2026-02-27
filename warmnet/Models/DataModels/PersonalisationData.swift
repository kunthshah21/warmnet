//
//  PersonalisationData.swift
//  warmnet
//
//  Created on 24 December 2025.
//

import Foundation
import SwiftData

@Model
class PersonalisationData {
    var id: UUID
    
    // Profile fields
    var name: String?
    var email: String?
    var birthday: Date?
    @Attribute(.externalStorage) var profilePhoto: Data?
    
    // Onboarding fields
    var relationshipGoal: RelationshipGoal?
    var challenges: [Challenge]
    var connectionSize: ConnectionSize?
    var communicationStyle: CommunicationStyle?
    var completedAt: Date?
    
    init(
        id: UUID = UUID(),
        name: String? = nil,
        email: String? = nil,
        birthday: Date? = nil,
        profilePhoto: Data? = nil,
        relationshipGoal: RelationshipGoal? = nil,
        challenges: [Challenge] = [],
        connectionSize: ConnectionSize? = nil,
        communicationStyle: CommunicationStyle? = nil,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.birthday = birthday
        self.profilePhoto = profilePhoto
        self.relationshipGoal = relationshipGoal
        self.challenges = challenges
        self.connectionSize = connectionSize
        self.communicationStyle = communicationStyle
        self.completedAt = completedAt
    }
    
    var isComplete: Bool {
        relationshipGoal != nil &&
        !challenges.isEmpty &&
        connectionSize != nil &&
        communicationStyle != nil
    }
}

// MARK: - Enums for Question Responses

enum RelationshipGoal: String, Codable, CaseIterable {
    case closeFriendsFamily = "Stay in touch with close friends & family"
    case professionalNetwork = "Build my professional network"
    case businessClients = "Maintain business/client relationships"
    case allOfAbove = "All of the above"
}

enum Challenge: String, Codable, CaseIterable {
    case forgetToReachOut = "I forget to reach out regularly"
    case dontKnowWhatToSay = "I don't know what to say when I reach out"
    case alwaysInitiating = "I feel like I'm always the one initiating"
    case wantToAddValue = "I want to add value, not just \"catch up\""
    case tooManyRelationships = "I have too many relationships to manage"
}

enum ConnectionSize: String, Codable, CaseIterable {
    case small = "10-25 (Close circle only)"
    case medium = "25-50 (Core network)"
    case large = "50-100 (Active professional network)"
    case extraLarge = "100-200 (Extensive network)"
    case superConnector = "200+ (I'm a super-connector)"
    
    var range: String {
        switch self {
        case .small: return "10-25"
        case .medium: return "25-50"
        case .large: return "50-100"
        case .extraLarge: return "100-200"
        case .superConnector: return "200+"
        }
    }
    
    var description: String {
        switch self {
        case .small: return "Close circle only"
        case .medium: return "Core network"
        case .large: return "Active professional network"
        case .extraLarge: return "Extensive network"
        case .superConnector: return "I'm a super-connector"
        }
    }
}

enum CommunicationStyle: String, Codable, CaseIterable {
    case quickTexter = "Quick texter"
    case deepConversationalist = "Deep conversationalist"
    case thoughtfulGiftGiver = "Thoughtful gift-giver"
    case strategicConnector = "Strategic connector"
    case cheerleader = "Cheerleader"
    
    var emoji: String {
        switch self {
        case .quickTexter: return "📱"
        case .deepConversationalist: return "☕"
        case .thoughtfulGiftGiver: return "🎁"
        case .strategicConnector: return "🤝"
        case .cheerleader: return "🎉"
        }
    }
    
    var description: String {
        switch self {
        case .quickTexter: return "I prefer short, frequent check-ins"
        case .deepConversationalist: return "I like longer, meaningful conversations"
        case .thoughtfulGiftGiver: return "I show I care through actions & gestures"
        case .strategicConnector: return "I add value by making introductions"
        case .cheerleader: return "I celebrate others' wins publicly"
        }
    }
}
