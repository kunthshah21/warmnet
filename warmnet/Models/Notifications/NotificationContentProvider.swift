//
//  NotificationContentProvider.swift
//  warmnet
//
//  Centralized registry for all notification titles and bodies.
//  Use this to manage text and structure for different notification types.
//

import Foundation

/// Represents the final text content for a notification
struct NotificationContent {
    let title: String
    let body: String
}

/// Defines all supported notification types and their required data
enum NotificationType {
    /// Triggered when entering a monitored city
    case locationEntry(city: String, contactNames: [String], totalCount: Int)
    
    /// Triggered on the day of the birthday
    case birthdayDayOf(contactName: String)
    
    /// Triggered one week before the birthday
    case birthdayWeekBefore(contactName: String)
}

/// Factory for generating notification content
struct NotificationContentProvider {
    
    /// Returns the localized content (title and body) for a given notification type
    static func content(for type: NotificationType) -> NotificationContent {
        switch type {
        case .locationEntry(let city, let contactNames, let totalCount):
            return locationContent(city: city, contactNames: contactNames, totalCount: totalCount)
            
        case .birthdayDayOf(let name):
            return NotificationContent(
                title: "Happy Birthday \(name)! 🎂",
                body: "It's \(name)'s birthday today. Don't forget to wish them!"
            )
            
        case .birthdayWeekBefore(let name):
            return NotificationContent(
                title: "Upcoming Birthday: \(name)",
                body: "\(name)'s birthday is in one week. Plan something special!"
            )
        }
    }
    
    // MARK: - Helper Logic
    
    private static func locationContent(city: String, contactNames: [String], totalCount: Int) -> NotificationContent {
        let title = "You're in \(city)!"
        let body: String
        
        if totalCount == 1, let firstName = contactNames.first {
            body = "Connect with \(firstName) while you're here."
        } else if totalCount == 2 {
            body = "Connect with \(contactNames.joined(separator: " and ")) while you're here."
        } else if totalCount <= 4 {
            let firstNames = contactNames.prefix(totalCount - 1).joined(separator: ", ")
            let lastName = contactNames.last ?? ""
            body = "Connect with \(firstNames), and \(lastName) while you're here."
        } else {
            let displayedNames = contactNames.prefix(2).joined(separator: ", ")
            let remaining = totalCount - 2
            body = "Connect with \(displayedNames), and \(remaining) others while you're here."
        }
        
        return NotificationContent(title: title, body: body)
    }
}
