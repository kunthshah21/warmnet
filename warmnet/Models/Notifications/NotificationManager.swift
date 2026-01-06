//
//  NotificationManager.swift
//  warmnet
//
//  Handles all local notification operations using UNUserNotificationCenter.
//

import Foundation
import UserNotifications
import UIKit

/// Manages local notification permissions, scheduling, and delivery
@Observable
@MainActor
final class NotificationManager: NSObject {
    
    // MARK: - Singleton
    
    static let shared = NotificationManager()
    
    // MARK: - Types
    
    enum AuthorizationStatus {
        case notDetermined
        case denied
        case authorized
        case provisional
        
        var canSendNotifications: Bool {
            self == .authorized || self == .provisional
        }
    }
    
    enum NotificationCategory: String {
        case locationReminder = "LOCATION_REMINDER"
        case birthdayReminder = "BIRTHDAY_REMINDER"
        
        var identifier: String { rawValue }
    }
    
    enum NotificationAction: String {
        case viewContacts = "VIEW_CONTACTS"
        case snooze = "SNOOZE"
        case dismiss = "DISMISS"
        
        var identifier: String { rawValue }
    }
    
    // MARK: - Properties
    
    nonisolated private let notificationCenter = UNUserNotificationCenter.current()
    
    private(set) var authorizationStatus: AuthorizationStatus = .notDetermined
    
    /// Callback for when user taps a notification action
    var onLocationNotificationAction: ((String, [AnyHashable: Any]) -> Void)?
    
    // MARK: - Init
    
    private override init() {
        super.init()
        setupCategories()
        Task {
            await refreshAuthorizationStatus()
        }
    }
    
    // MARK: - Authorization
    
    /// Request notification permission from the user
    /// - Returns: Whether permission was granted
    @discardableResult
    func requestPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            await refreshAuthorizationStatus()
            return granted
        } catch {
            print("NotificationManager: Failed to request authorization: \(error)")
            return false
        }
    }
    
    /// Refresh the current authorization status
    func refreshAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        
        switch settings.authorizationStatus {
        case .notDetermined:
            authorizationStatus = .notDetermined
        case .denied:
            authorizationStatus = .denied
        case .authorized:
            authorizationStatus = .authorized
        case .provisional:
            authorizationStatus = .provisional
        case .ephemeral:
            authorizationStatus = .authorized
        @unknown default:
            authorizationStatus = .notDetermined
        }
    }
    
    /// Open the app's notification settings in System Settings
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    // MARK: - Notification Categories
    
    private func setupCategories() {
        // Location reminder category with actions
        let viewAction = UNNotificationAction(
            identifier: NotificationAction.viewContacts.identifier,
            title: "View Contacts",
            options: [.foreground]
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: NotificationAction.snooze.identifier,
            title: "Snooze 2 Hours",
            options: []
        )
        
        let dismissAction = UNNotificationAction(
            identifier: NotificationAction.dismiss.identifier,
            title: "Dismiss",
            options: [.destructive]
        )
        
        let locationCategory = UNNotificationCategory(
            identifier: NotificationCategory.locationReminder.identifier,
            actions: [viewAction, snoozeAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Birthday Reminder Category
        let birthdayCategory = UNNotificationCategory(
            identifier: NotificationCategory.birthdayReminder.identifier,
            actions: [viewAction, snoozeAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        notificationCenter.setNotificationCategories([locationCategory, birthdayCategory])
    }
    
    // MARK: - Schedule Notifications
    
    /// Schedule a location-based contact reminder notification
    /// - Parameters:
    ///   - city: The city name for the notification
    ///   - contactNames: Names of contacts in the city
    ///   - contactCount: Total number of contacts
    ///   - userInfo: Additional data to attach to the notification
    func scheduleLocationNotification(
        city: String,
        contactNames: [String],
        contactCount: Int,
        userInfo: [String: Any] = [:]
    ) async {
        guard authorizationStatus.canSendNotifications else {
            print("NotificationManager: Cannot send notification - not authorized")
            return
        }
        
        let notifContent = NotificationContentProvider.content(
            for: .locationEntry(city: city, contactNames: contactNames, totalCount: contactCount)
        )
        
        let content = UNMutableNotificationContent()
        content.title = notifContent.title
        content.body = notifContent.body
        
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.locationReminder.identifier
        
        // Attach user info for handling actions
        var fullUserInfo = userInfo
        fullUserInfo["city"] = city
        fullUserInfo["contactCount"] = contactCount
        content.userInfo = fullUserInfo
        
        // Create trigger (immediate)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // Create request with unique identifier
        let identifier = "location_\(city.lowercased().replacingOccurrences(of: " ", with: "_"))_\(Date().timeIntervalSince1970)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
            print("NotificationManager: Scheduled notification for \(city)")
        } catch {
            print("NotificationManager: Failed to schedule notification: \(error)")
        }
    }

    /// Schedule birthday notifications for a contact
    func scheduleBirthdayNotifications(contact: Contact) async {
        guard let birthday = contact.birthday, authorizationStatus.canSendNotifications else {
            // No birthday set or permission denied
            return
        }
        
        let calendar = Calendar.current
        
        // --- Notification 1 (Day Of) ---
        // Trigger: On the birthday month and day at 12:00 AM (00:00).
        let dayOfComponents = calendar.dateComponents([.month, .day], from: birthday)
        
        var trigger1Components = DateComponents()
        trigger1Components.month = dayOfComponents.month
        trigger1Components.day = dayOfComponents.day
        trigger1Components.hour = 0
        trigger1Components.minute = 0
        
        let dayOfContent = NotificationContentProvider.content(for: .birthdayDayOf(contactName: contact.name))
        
        let content1 = UNMutableNotificationContent()
        content1.title = dayOfContent.title
        content1.body = dayOfContent.body
        content1.sound = .default
        content1.categoryIdentifier = NotificationCategory.birthdayReminder.identifier
        content1.userInfo = ["contactId": contact.id.uuidString]
        
        let trigger1 = UNCalendarNotificationTrigger(dateMatching: trigger1Components, repeats: true)
        let id1 = "birthday_day_\(contact.id.uuidString)"
        let request1 = UNNotificationRequest(identifier: id1, content: content1, trigger: trigger1)
        
        do {
            try await notificationCenter.add(request1)
            print("NotificationManager: Scheduled birthday (day of) notification for \(contact.name)")
        } catch {
            print("NotificationManager: Failed to schedule birthday (day of) notification: \(error)")
        }
        
        // --- Notification 2 (1 Week Before) ---
        // Trigger: 7 days before the birthday at 9:00 AM.
        // We calculate the date 7 days before the supplied birthday using a fixed leap year (2024)
        // to handle Feb 29 correctly, then subtract 7 days.
        var tempComponents = dayOfComponents
        tempComponents.year = 2024
        
        if let tempDate = calendar.date(from: tempComponents),
           let weekBeforeDate = calendar.date(byAdding: .day, value: -7, to: tempDate) {
            
            let weekBeforeComponents = calendar.dateComponents([.month, .day], from: weekBeforeDate)
            
            var trigger2Components = DateComponents()
            trigger2Components.month = weekBeforeComponents.month
            trigger2Components.day = weekBeforeComponents.day
            trigger2Components.hour = 9
            trigger2Components.minute = 0
            
            let weekBeforeContent = NotificationContentProvider.content(for: .birthdayWeekBefore(contactName: contact.name))
            
            let content2 = UNMutableNotificationContent()
            content2.title = weekBeforeContent.title
            content2.body = weekBeforeContent.body
            content2.sound = .default
            content2.categoryIdentifier = NotificationCategory.birthdayReminder.identifier
            content2.userInfo = ["contactId": contact.id.uuidString]
            
            let trigger2 = UNCalendarNotificationTrigger(dateMatching: trigger2Components, repeats: true)
            let id2 = "birthday_week_\(contact.id.uuidString)"
            let request2 = UNNotificationRequest(identifier: id2, content: content2, trigger: trigger2)
            
            do {
                try await notificationCenter.add(request2)
                print("NotificationManager: Scheduled birthday (1 week before) notification for \(contact.name)")
            } catch {
                print("NotificationManager: Failed to schedule birthday (1 week before) notification: \(error)")
            }
        }
    }

    /// Trigger an immediate birthday notification for testing purposes
    /// - Parameters:
    ///   - contactName: The name to display
    ///   - isWeekBefore: If true, shows the "Upcoming Birthday" message. If false, shows "Happy Birthday".
    func testBirthdayNotification(contactName: String, isWeekBefore: Bool = false) async {
        guard authorizationStatus.canSendNotifications else { return }
        
        let notifContent: NotificationContent
        if isWeekBefore {
            notifContent = NotificationContentProvider.content(for: .birthdayWeekBefore(contactName: contactName))
        } else {
            notifContent = NotificationContentProvider.content(for: .birthdayDayOf(contactName: contactName))
        }
        
        let content = UNMutableNotificationContent()
        content.title = notifContent.title
        content.body = notifContent.body
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.birthdayReminder.identifier
        
        // Trigger 5 seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let identifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        try? await notificationCenter.add(request)
    }
    
    // MARK: - Pending Notifications
    
    /// Remove all pending location notifications
    func removeAllPendingLocationNotifications() {
        notificationCenter.getPendingNotificationRequests { requests in
            let locationIds = requests
                .filter { $0.identifier.hasPrefix("location_") }
                .map(\.identifier)
            
            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: locationIds)
        }
    }
    
    /// Remove all delivered notifications
    func removeAllDeliveredNotifications() {
        notificationCenter.removeAllDeliveredNotifications()
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    /// Handle notification when app is in foreground
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        // Show notification even when app is in foreground
        return [.banner, .sound]
    }
    
    /// Handle notification action response
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let actionIdentifier = response.actionIdentifier
        let userInfo = response.notification.request.content.userInfo
        
        // Wrapper to pass dictionary across actor boundary safely
        // UNNotification userInfo contains plist types which are effectively thread-safe
        struct SendableUserInfo: @unchecked Sendable {
            let content: [AnyHashable: Any]
        }
        let safeUserInfo = SendableUserInfo(content: userInfo)
        
        // Handle action on main actor
        await MainActor.run {
            let info = safeUserInfo.content
            
            switch actionIdentifier {
            case NotificationAction.viewContacts.identifier,
                 UNNotificationDefaultActionIdentifier:
                // User tapped notification or View Contacts
                onLocationNotificationAction?(NotificationAction.viewContacts.identifier, info)
                
            case NotificationAction.snooze.identifier:
                // User snoozed
                onLocationNotificationAction?(NotificationAction.snooze.identifier, info)
                
            case NotificationAction.dismiss.identifier,
                 UNNotificationDismissActionIdentifier:
                // User dismissed
                onLocationNotificationAction?(NotificationAction.dismiss.identifier, info)
                
            default:
                break
            }
        }
    }
}

