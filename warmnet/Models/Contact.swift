import Foundation
import SwiftData
import SwiftUI

@Model
final class Contact {
    var id: UUID
    var name: String
    var phoneCountryCode: String
    var phoneNumber: String
    var reference: String
    
    // Advanced details
    var email: String
    var city: String
    var state: String
    var country: String
    var birthday: Date?
    var company: String
    var jobTitle: String
    var notes: String
    var priority: Priority?
    
    // Custom Schedule
    var useCustomSchedule: Bool = false
    var scheduleFrequency: String? // "Day(s)", "Week(s)", etc.
    var scheduleInterval: Int?
    var scheduleDays: [String]? // ["Monday", "Tuesday"]
    
    // Reminder System properties
    var nextTouchDate: Date?
    var lastContacted: Date?
    
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \Interaction.contact)
    var interactions: [Interaction] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Milestone.contact)
    var milestones: [Milestone] = []
    
    init(
        name: String = "",
        phoneCountryCode: String = "+1",
        phoneNumber: String = "",
        reference: String = "",
        email: String = "",
        city: String = "",
        state: String = "",
        country: String = "",
        birthday: Date? = nil,
        company: String = "",
        jobTitle: String = "",
        notes: String = "",
        priority: Priority = .broaderNetwork,
        useCustomSchedule: Bool = false,
        scheduleFrequency: String? = nil,
        scheduleInterval: Int? = nil,
        scheduleDays: [String]? = nil,
        nextTouchDate: Date? = nil,
        lastContacted: Date? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.phoneCountryCode = phoneCountryCode
        self.phoneNumber = phoneNumber
        self.reference = reference
        self.email = email
        self.city = city
        self.state = state
        self.country = country
        self.birthday = birthday
        self.company = company
        self.jobTitle = jobTitle
        self.notes = notes
        self.priority = priority
        self.useCustomSchedule = useCustomSchedule
        self.scheduleFrequency = scheduleFrequency
        self.scheduleInterval = scheduleInterval
        self.scheduleDays = scheduleDays
        self.nextTouchDate = nextTouchDate
        self.lastContacted = lastContacted
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var fullPhoneNumber: String {
        "\(phoneCountryCode) \(phoneNumber)"
    }
    
    var fullLocation: String {
        [city, state, country]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
    
    var reminderInterval: Int {
        switch priority {
        case .innerCircle: return 14
        case .keyRelationships: return 60
        case .broaderNetwork: return 180
        case .none: return 180
        }
    }
    
    var mostRecentInteraction: Interaction? {
        interactions.sorted { $0.date > $1.date }.first
    }
    
    // Legacy support - returns nextTouchDate if set, otherwise calculates from old logic
    var nextReminderDate: Date {
        if let nextTouch = nextTouchDate {
            return nextTouch
        }
        // Fallback for legacy data
        let baseDate = mostRecentInteraction?.date ?? lastContacted ?? createdAt
        return Calendar.current.date(byAdding: .day, value: reminderInterval, to: baseDate) ?? baseDate
    }
    
    var isOverdue: Bool {
        Date() > nextReminderDate
    }
}

enum Priority: String, Codable, CaseIterable {
    case innerCircle = "Inner Circle"
    case keyRelationships = "Key Relationships"
    case broaderNetwork = "Broader Network"
    
    var color: Color {
        switch self {
        case .innerCircle: return .green
        case .keyRelationships: return .blue
        case .broaderNetwork: return .yellow
        }
    }
}

