//
//  BirthdayNotificationService.swift
//  warmnet
//
//  Service to manage scheduling of birthday notifications.
//

import Foundation
import SwiftData

@MainActor
final class BirthdayNotificationService {
    
    static let shared = BirthdayNotificationService()
    
    private init() {}
    
    /// Schedule notifications for all contacts with birthdays
    func scheduleAll(contacts: [Contact]) async {
        for contact in contacts {
            await schedule(contact: contact)
        }
    }
    
    /// Schedule notification for a single contact
    func schedule(contact: Contact) async {
        guard contact.birthday != nil else { return }
        await NotificationManager.shared.scheduleBirthdayNotifications(contact: contact)
    }
}
