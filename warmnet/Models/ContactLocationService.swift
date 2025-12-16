import Foundation
import MapKit
import CoreLocation

/// Service for geocoding contact locations and caching coordinates
@Observable
final class ContactLocationService {
    
    // MARK: - Types
    
    struct CachedLocation: Identifiable {
        let id: UUID
        let contactId: UUID
        let contactName: String
        let coordinate: CLLocationCoordinate2D
        let city: String
        let state: String
        let country: String
        
        var locationKey: String {
            [city, state, country]
                .filter { !$0.isEmpty }
                .joined(separator: ", ")
        }
    }
    
    // MARK: - Properties
    
    private let geocoder = CLGeocoder()
    private var coordinateCache: [String: CLLocationCoordinate2D] = [:]
    
    var cachedLocations: [CachedLocation] = []
    var isLoading = false
    var loadingProgress: Double = 0
    
    // Available filter options derived from contacts
    var availableCities: [String] {
        Set(cachedLocations.map(\.city).filter { !$0.isEmpty }).sorted()
    }
    
    var availableStates: [String] {
        Set(cachedLocations.map(\.state).filter { !$0.isEmpty }).sorted()
    }
    
    var availableCountries: [String] {
        Set(cachedLocations.map(\.country).filter { !$0.isEmpty }).sorted()
    }
    
    // MARK: - Public Methods
    
    /// Geocode all contacts and cache their coordinates
    /// - Parameter contacts: Array of contacts to geocode
    func geocodeContacts(_ contacts: [Contact]) async {
        isLoading = true
        loadingProgress = 0
        cachedLocations = []
        
        let contactsWithLocation = contacts.filter { !$0.fullLocation.isEmpty }
        let total = Double(contactsWithLocation.count)
        
        for (index, contact) in contactsWithLocation.enumerated() {
            if let coordinate = await geocodeContact(contact) {
                let cached = CachedLocation(
                    id: UUID(),
                    contactId: contact.id,
                    contactName: contact.name,
                    coordinate: coordinate,
                    city: contact.city,
                    state: contact.state,
                    country: contact.country
                )
                cachedLocations.append(cached)
            }
            
            loadingProgress = Double(index + 1) / total
        }
        
        isLoading = false
    }
    
    /// Get coordinate for a location string (city, state, or country)
    /// - Parameter location: Location string to geocode
    /// - Returns: Coordinate if found
    func getCoordinate(for location: String) async -> CLLocationCoordinate2D? {
        // Check cache first
        if let cached = coordinateCache[location] {
            return cached
        }
        
        // Geocode the location
        do {
            let placemarks = try await geocoder.geocodeAddressString(location)
            if let coordinate = placemarks.first?.location?.coordinate {
                coordinateCache[location] = coordinate
                return coordinate
            }
        } catch {
            // Geocoding failed
        }
        
        return nil
    }
    
    /// Get appropriate zoom span for a filter type
    /// - Parameter filterType: The type of location filter
    /// - Returns: Map span in degrees
    func zoomSpan(for filterType: FilterType) -> MKCoordinateSpan {
        switch filterType {
        case .city:
            return MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        case .state:
            return MKCoordinateSpan(latitudeDelta: 3.0, longitudeDelta: 3.0)
        case .country:
            return MKCoordinateSpan(latitudeDelta: 15.0, longitudeDelta: 15.0)
        case .all:
            return MKCoordinateSpan(latitudeDelta: 60.0, longitudeDelta: 60.0)
        }
    }
    
    /// Filter cached locations by criteria
    /// - Parameters:
    ///   - filterType: Type of filter
    ///   - value: Filter value
    /// - Returns: Filtered locations
    func filterLocations(by filterType: FilterType, value: String?) -> [CachedLocation] {
        guard let value = value, !value.isEmpty else {
            return cachedLocations
        }
        
        switch filterType {
        case .city:
            return cachedLocations.filter { $0.city == value }
        case .state:
            return cachedLocations.filter { $0.state == value }
        case .country:
            return cachedLocations.filter { $0.country == value }
        case .all:
            return cachedLocations
        }
    }
    
    /// Calculate region to fit all given locations
    /// - Parameter locations: Locations to fit
    /// - Returns: Map region that fits all locations
    func regionToFit(_ locations: [CachedLocation]) -> MKCoordinateRegion? {
        guard !locations.isEmpty else { return nil }
        
        let coordinates = locations.map(\.coordinate)
        
        let minLat = coordinates.map(\.latitude).min() ?? 0
        let maxLat = coordinates.map(\.latitude).max() ?? 0
        let minLon = coordinates.map(\.longitude).min() ?? 0
        let maxLon = coordinates.map(\.longitude).max() ?? 0
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.3, 0.1),
            longitudeDelta: max((maxLon - minLon) * 1.3, 0.1)
        )
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    // MARK: - Private Methods
    
    private func geocodeContact(_ contact: Contact) async -> CLLocationCoordinate2D? {
        let locationKey = contact.fullLocation
        
        // Check cache first
        if let cached = coordinateCache[locationKey] {
            return cached
        }
        
        // Rate limit to avoid geocoding throttling
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms delay
        
        do {
            let placemarks = try await geocoder.geocodeAddressString(locationKey)
            if let coordinate = placemarks.first?.location?.coordinate {
                coordinateCache[locationKey] = coordinate
                return coordinate
            }
        } catch {
            // Geocoding failed for this contact
        }
        
        return nil
    }
}

// MARK: - Filter Type

enum FilterType: String, CaseIterable {
    case all = "All"
    case city = "City"
    case state = "State"
    case country = "Country"
}

