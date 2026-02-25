//
//  LocationNotificationService.swift
//  warmnet
//
//  Core service for location-based notifications using iOS geofencing.
//

import Foundation
import CoreLocation
import SwiftData
import MapKit

/// Manages geofence-based notifications for contact locations
@Observable
@MainActor
final class LocationNotificationService: NSObject {
    
    // MARK: - Singleton
    
    static let shared = LocationNotificationService()
    
    // MARK: - Types
    
    enum LocationAuthorizationStatus {
        case notDetermined
        case denied
        case whenInUse
        case always
        
        var canUseGeofencing: Bool {
            self == .always
        }
        
        var displayText: String {
            switch self {
            case .notDetermined: return "Not Requested"
            case .denied: return "Denied"
            case .whenInUse: return "When In Use"
            case .always: return "Always"
            }
        }
    }
    
    struct MonitoredCity: Identifiable {
        let id = UUID()
        let city: String
        let state: String
        let country: String
        let coordinate: CLLocationCoordinate2D
        let contactCount: Int
        let regionIdentifier: String
    }
    
    // MARK: - Configuration
    
    /// Geofence radius in meters (~15km for city-level)
    private let geofenceRadius: CLLocationDistance = 15000
    
    /// Maximum regions iOS allows per app
    private let maxRegions = 20
    
    // MARK: - Properties
    
    private let locationManager = CLLocationManager()
    
    private(set) var authorizationStatus: LocationAuthorizationStatus = .notDetermined
    private(set) var monitoredCities: [MonitoredCity] = []
    private(set) var isSettingUpGeofences = false
    
    /// Model context for database operations (set during app initialization)
    var modelContext: ModelContext?
    
    // MARK: - Init
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = true
        updateAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    /// Request "When In Use" authorization first (required before "Always")
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Request "Always" authorization for geofencing
    /// Note: Must have "When In Use" first
    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    /// Update the current authorization status
    private func updateAuthorizationStatus() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            authorizationStatus = .notDetermined
        case .restricted, .denied:
            authorizationStatus = .denied
        case .authorizedWhenInUse:
            authorizationStatus = .whenInUse
        case .authorizedAlways:
            authorizationStatus = .always
        @unknown default:
            authorizationStatus = .notDetermined
        }
    }
    
    // MARK: - Geofencing Setup
    
    /// Setup geofences for contact cities
    /// - Parameter contacts: All contacts to analyze
    func setupGeofences(for contacts: [Contact]) async {
        guard authorizationStatus.canUseGeofencing else { return }
        
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else { return }
        
        isSettingUpGeofences = true
        
        // Clear existing monitored regions
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        monitoredCities = []
        
        // Get prioritized cities (top 20)
        let prioritizedCities = ContactLocationMatcher.prioritizeCitiesForGeofencing(contacts)
        
        // Geocode cities to get coordinates
        let geocodedCities = await ContactLocationMatcher.geocodeCities(prioritizedCities)
        
        // Setup geofences for cities with valid coordinates
        for cityPriority in geocodedCities {
            guard let coordinate = cityPriority.coordinate else { continue }
            
            // Create region identifier
            let identifier = createRegionIdentifier(for: cityPriority.city)
            
            // Create circular region
            let region = CLCircularRegion(
                center: coordinate,
                radius: geofenceRadius,
                identifier: identifier
            )
            region.notifyOnEntry = true
            region.notifyOnExit = false  // Only notify on entry
            
            // Start monitoring
            locationManager.startMonitoring(for: region)
            
            // Track monitored city
            let monitoredCity = MonitoredCity(
                city: cityPriority.city,
                state: cityPriority.state,
                country: cityPriority.country,
                coordinate: coordinate,
                contactCount: cityPriority.contactCount,
                regionIdentifier: identifier
            )
            monitoredCities.append(monitoredCity)
            
        }
        
        isSettingUpGeofences = false
    }
    
    /// Stop all geofence monitoring
    func stopAllMonitoring() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        monitoredCities = []
    }
    
    /// Refresh geofences (call when contacts change)
    func refreshGeofences(contacts: [Contact]) async {
        await setupGeofences(for: contacts)
    }
    
    // MARK: - Region Entry Handling
    
    /// Handle entry into a monitored region
    private func handleRegionEntry(_ region: CLRegion) {
        guard region is CLCircularRegion else { return }
        
        // Find the monitored city for this region
        guard let monitoredCity = monitoredCities.first(where: { $0.regionIdentifier == region.identifier }) else { return }
        
        Task {
            await processRegionEntry(for: monitoredCity)
        }
    }
    
    /// Process region entry and potentially send notification
    private func processRegionEntry(for city: MonitoredCity) async {
        guard let context = modelContext else { return }
        
        let settings = UserSettings.getOrCreate(from: context)
        
        guard settings.locationNotificationsEnabled else { return }
        
        if settings.isInQuietHours { return }
        
        let canNotify = NotificationHistory.canNotify(
            for: city.city,
            cooldownHours: settings.notificationCooldownHours,
            context: context
        )
        
        guard canNotify else { return }
        
        let contacts = await fetchContactsInCity(city.city, context: context)
        guard !contacts.isEmpty else { return }
        
        // Get display names for notification
        let displayNames = ContactLocationMatcher.getDisplayNames(from: contacts, maxNames: 3)
        
        // Send notification
        await NotificationManager.shared.scheduleLocationNotification(
            city: city.city,
            contactNames: displayNames,
            contactCount: contacts.count,
            userInfo: [
                "city": city.city,
                "state": city.state,
                "country": city.country,
                "contactIds": contacts.map { $0.id.uuidString }
            ]
        )
        
        // Record notification history
        NotificationHistory.record(
            city: city.city,
            state: city.state,
            country: city.country,
            contactIds: contacts.map(\.id),
            context: context
        )
        
    
    }
    
    /// Fetch contacts for a specific city
    private func fetchContactsInCity(_ city: String, context: ModelContext) async -> [Contact] {
        let normalizedCity = city.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        let descriptor = FetchDescriptor<Contact>(
            predicate: #Predicate { contact in
                contact.city.localizedStandardContains(normalizedCity)
            }
        )
        
        do {
            let contacts = try context.fetch(descriptor)
            // Sort by priority
            return contacts.sorted { lhs, rhs in
                let lhsWeight = priorityWeight(for: lhs.priority)
                let rhsWeight = priorityWeight(for: rhs.priority)
                return lhsWeight > rhsWeight
            }
        } catch {
            return []
        }
    }
    
    // MARK: - Helpers
    
    /// Create a unique region identifier for a city
    private func createRegionIdentifier(for city: String) -> String {
        "warmnet_city_\(city.lowercased().replacingOccurrences(of: " ", with: "_"))"
    }
    
    /// Get priority weight for sorting
    private func priorityWeight(for priority: Priority?) -> Int {
        switch priority {
        case .innerCircle: return 3
        case .keyRelationships: return 2
        case .broaderNetwork: return 1
        case .none: return 1
        }
    }
    
    // MARK: - Testing / Debug
    
    /// Manually trigger a region entry for testing
    func simulateRegionEntry(city: String) {
        guard let monitoredCity = monitoredCities.first(where: {
            $0.city.lowercased() == city.lowercased()
        }) else { return }
        
        Task {
            await processRegionEntry(for: monitoredCity)
        }
    }
    
    /// Get current monitored region count
    var activeRegionCount: Int {
        locationManager.monitoredRegions.count
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationNotificationService: CLLocationManagerDelegate {
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            updateAuthorizationStatus()
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        Task { @MainActor in
            handleRegionEntry(region)
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
}

