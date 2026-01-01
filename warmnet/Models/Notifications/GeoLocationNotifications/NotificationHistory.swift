//
//  NotificationHistory.swift
//  warmnet
//
//  Created for location-based notification tracking.
//

import Foundation
import SwiftData

/// Tracks when location-based notifications were sent to prevent spam
/// and respect user-configured cooldown periods.
@Model
final class NotificationHistory {
    var id: UUID
    var city: String
    var state: String
    var country: String
    var notifiedAt: Date
    var contactIds: [UUID]
    var wasOpened: Bool
    var wasSnoozed: Bool
    var snoozeUntil: Date?
    
    init(
        city: String,
        state: String = "",
        country: String = "",
        contactIds: [UUID] = [],
        notifiedAt: Date = Date()
    ) {
        self.id = UUID()
        self.city = city
        self.state = state
        self.country = country
        self.contactIds = contactIds
        self.notifiedAt = notifiedAt
        self.wasOpened = false
        self.wasSnoozed = false
        self.snoozeUntil = nil
    }
    
    /// Location key for matching (city-level)
    var locationKey: String {
        city.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Mark notification as opened
    func markOpened() {
        wasOpened = true
    }
    
    /// Snooze notifications for this location
    func snooze(until date: Date) {
        wasSnoozed = true
        snoozeUntil = date
    }
    
    /// Check if location is currently snoozed
    var isSnoozed: Bool {
        guard wasSnoozed, let snoozeUntil else { return false }
        return Date() < snoozeUntil
    }
    
    // MARK: - Static Helpers
    
    /// Check if a notification can be sent for the given city based on cooldown
    static func canNotify(
        for city: String,
        cooldownHours: Int,
        context: ModelContext
    ) -> Bool {
        let normalizedCity = city.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Fetch most recent notification for this city
        let descriptor = FetchDescriptor<NotificationHistory>(
            predicate: #Predicate { history in
                history.city.localizedStandardContains(normalizedCity)
            },
            sortBy: [SortDescriptor(\.notifiedAt, order: .reverse)]
        )
        
        guard let histories = try? context.fetch(descriptor),
              let lastNotification = histories.first else {
            // No previous notification, can send
            return true
        }
        
        // Check if snoozed
        if lastNotification.isSnoozed {
            return false
        }
        
        // Check cooldown (0 = once per visit, no time restriction)
        if cooldownHours == 0 {
            // For "once per visit", we'd need exit detection
            // For now, use 1-hour minimum to prevent rapid re-triggers
            let minimumInterval: TimeInterval = 3600 // 1 hour
            return Date().timeIntervalSince(lastNotification.notifiedAt) >= minimumInterval
        }
        
        let cooldownInterval = TimeInterval(cooldownHours * 3600)
        return Date().timeIntervalSince(lastNotification.notifiedAt) >= cooldownInterval
    }
    
    /// Record a new notification
    static func record(
        city: String,
        state: String,
        country: String,
        contactIds: [UUID],
        context: ModelContext
    ) {
        let history = NotificationHistory(
            city: city,
            state: state,
            country: country,
            contactIds: contactIds
        )
        context.insert(history)
        try? context.save()
    }
    
    /// Clean up old notification history (older than 30 days)
    static func cleanupOldRecords(context: ModelContext) {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        
        let descriptor = FetchDescriptor<NotificationHistory>(
            predicate: #Predicate { history in
                history.notifiedAt < thirtyDaysAgo
            }
        )
        
        if let oldRecords = try? context.fetch(descriptor) {
            for record in oldRecords {
                context.delete(record)
            }
            try? context.save()
        }
    }
}

