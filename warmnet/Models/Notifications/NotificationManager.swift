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
        
        var identifier: String { rawValue }
    }
    
    enum NotificationAction: String {
        case viewContacts = "VIEW_CONTACTS"
        case snooze = "SNOOZE"
        case dismiss = "DISMISS"
        
        var identifier: String { rawValue }
    }
    
    // MARK: - Properties
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
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
        
        notificationCenter.setNotificationCategories([locationCategory])
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
        
        let content = UNMutableNotificationContent()
        content.title = "You're in \(city)!"
        
        // Build body based on contact count
        if contactCount == 1, let firstName = contactNames.first {
            content.body = "Connect with \(firstName) while you're here."
        } else if contactCount == 2 {
            content.body = "Connect with \(contactNames.joined(separator: " and ")) while you're here."
        } else if contactCount <= 4 {
            let firstNames = contactNames.prefix(contactCount - 1).joined(separator: ", ")
            let lastName = contactNames.last ?? ""
            content.body = "Connect with \(firstNames), and \(lastName) while you're here."
        } else {
            let displayedNames = contactNames.prefix(2).joined(separator: ", ")
            let remaining = contactCount - 2
            content.body = "Connect with \(displayedNames), and \(remaining) others while you're here."
        }
        
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
        
        // Handle action on main actor
        await MainActor.run {
            switch actionIdentifier {
            case NotificationAction.viewContacts.identifier,
                 UNNotificationDefaultActionIdentifier:
                // User tapped notification or View Contacts
                onLocationNotificationAction?(NotificationAction.viewContacts.identifier, userInfo)
                
            case NotificationAction.snooze.identifier:
                // User snoozed
                onLocationNotificationAction?(NotificationAction.snooze.identifier, userInfo)
                
            case NotificationAction.dismiss.identifier,
                 UNNotificationDismissActionIdentifier:
                // User dismissed
                onLocationNotificationAction?(NotificationAction.dismiss.identifier, userInfo)
                
            default:
                break
            }
        }
    }
}

