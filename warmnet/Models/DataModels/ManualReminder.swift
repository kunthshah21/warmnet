//
//  ManualReminder.swift
//  warmnet
//

import Foundation
import SwiftData

enum ReminderRepeatInterval: String, Codable, CaseIterable {
    case never = "Never"
    case hourly = "Hourly"
    case daily = "Daily"
    case weekdays = "Weekdays"
    case weekends = "Weekends"
    case weekly = "Weekly"
    case biweekly = "Biweekly"
    case monthly = "Monthly"
    case every3Months = "Every 3 Months"
    case every6Months = "Every 6 Months"
}

@Model
final class ManualReminder {
    var id: UUID
    var title: String = ""
    var reminderDate: Date?
    var reminderTime: Date?
    var note: String = ""
    var isUrgent: Bool = false
    var repeatIntervalRaw: String = "Never"
    var hasDate: Bool = false
    var hasTime: Bool = false
    var createdAt: Date
    
    @Relationship var contact: Contact
    
    var repeatInterval: ReminderRepeatInterval {
        get { ReminderRepeatInterval(rawValue: repeatIntervalRaw) ?? .never }
        set { repeatIntervalRaw = newValue.rawValue }
    }

    init(
        contact: Contact,
        title: String? = nil,
        reminderDate: Date? = nil,
        reminderTime: Date? = nil,
        note: String = "",
        isUrgent: Bool = false,
        repeatInterval: ReminderRepeatInterval = .never,
        hasDate: Bool = false,
        hasTime: Bool = false
    ) {
        self.id = UUID()
        self.contact = contact
        self.title = title ?? contact.name
        self.reminderDate = reminderDate
        self.reminderTime = reminderTime
        self.note = note
        self.isUrgent = isUrgent
        self.repeatIntervalRaw = repeatInterval.rawValue
        self.hasDate = hasDate
        self.hasTime = hasTime
        self.createdAt = Date()
    }
    
    var combinedDateTime: Date? {
        guard hasDate, let date = reminderDate else { return nil }
        
        if hasTime, let time = reminderTime {
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
            
            var combined = DateComponents()
            combined.year = dateComponents.year
            combined.month = dateComponents.month
            combined.day = dateComponents.day
            combined.hour = timeComponents.hour
            combined.minute = timeComponents.minute
            
            return calendar.date(from: combined)
        }
        
        return date
    }
}
