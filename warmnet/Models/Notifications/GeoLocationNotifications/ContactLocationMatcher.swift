//
//  ContactLocationMatcher.swift
//  warmnet
//
//  Utility for matching contacts by city and prioritizing cities for geofencing.
//

import Foundation
import CoreLocation
import MapKit

/// Utility for finding contacts in specific locations and prioritizing cities for geofencing
struct ContactLocationMatcher {
    
    // MARK: - Types
    
    /// Represents a city with its priority score and contacts
    struct CityPriority: Identifiable {
        let id = UUID()
        let city: String
        let state: String
        let country: String
        var coordinate: CLLocationCoordinate2D?
        let contacts: [Contact]
        let priorityScore: Int
        
        var locationKey: String {
            [city, state, country]
                .filter { !$0.isEmpty }
                .joined(separator: ", ")
        }
        
        var contactCount: Int { contacts.count }
    }
    
    // MARK: - Contact Matching
    
    /// Find all contacts in a specific city
    /// - Parameters:
    ///   - city: The city name to match (case-insensitive)
    ///   - contacts: Array of contacts to search
    /// - Returns: Contacts whose city matches the given city
    static func findContacts(in city: String, from contacts: [Contact]) -> [Contact] {
        let normalizedCity = city.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        return contacts.filter { contact in
            contact.city.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == normalizedCity
        }
    }
    
    /// Find all contacts in a specific city, ordered by priority
    /// - Parameters:
    ///   - city: The city name to match
    ///   - contacts: Array of contacts to search
    /// - Returns: Contacts sorted by priority (Inner Circle first)
    static func findContactsSortedByPriority(in city: String, from contacts: [Contact]) -> [Contact] {
        findContacts(in: city, from: contacts).sorted { lhs, rhs in
            let lhsWeight = priorityWeight(for: lhs.priority)
            let rhsWeight = priorityWeight(for: rhs.priority)
            return lhsWeight > rhsWeight
        }
    }
    
    // MARK: - City Prioritization for Geofencing
    
    /// Get prioritized list of cities for geofencing (max 20 due to iOS limit)
    /// Cities are prioritized by:
    /// 1. Sum of contact priority weights in that city
    /// 2. Number of contacts as tiebreaker
    ///
    /// - Parameter contacts: All contacts to analyze
    /// - Returns: Top 20 cities sorted by priority
    static func prioritizeCitiesForGeofencing(_ contacts: [Contact]) -> [CityPriority] {
        // Filter contacts with valid city data
        let contactsWithCity = contacts.filter { !$0.city.isEmpty }
        
        // Group contacts by normalized city key
        var cityGroups: [String: [Contact]] = [:]
        
        for contact in contactsWithCity {
            let key = contact.city.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            cityGroups[key, default: []].append(contact)
        }
        
        // Calculate priority for each city
        var cityPriorities: [CityPriority] = []
        
        for (_, groupContacts) in cityGroups {
            guard let firstContact = groupContacts.first else { continue }
            
            // Calculate total priority score for city
            let priorityScore = groupContacts.reduce(0) { sum, contact in
                sum + priorityWeight(for: contact.priority)
            }
            
            let cityPriority = CityPriority(
                city: firstContact.city,
                state: firstContact.state,
                country: firstContact.country,
                coordinate: nil, // Will be geocoded later
                contacts: groupContacts,
                priorityScore: priorityScore
            )
            
            cityPriorities.append(cityPriority)
        }
        
        // Sort by priority score (descending), then by contact count (descending)
        cityPriorities.sort { lhs, rhs in
            if lhs.priorityScore != rhs.priorityScore {
                return lhs.priorityScore > rhs.priorityScore
            }
            return lhs.contactCount > rhs.contactCount
        }
        
        // Return top 20 (iOS geofencing limit)
        return Array(cityPriorities.prefix(20))
    }
    
    /// Get all unique cities from contacts (not limited to 20)
    /// - Parameter contacts: All contacts to analyze
    /// - Returns: All cities with their contacts and priorities
    static func getAllCities(_ contacts: [Contact]) -> [CityPriority] {
        let contactsWithCity = contacts.filter { !$0.city.isEmpty }
        
        var cityGroups: [String: [Contact]] = [:]
        
        for contact in contactsWithCity {
            let key = contact.city.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            cityGroups[key, default: []].append(contact)
        }
        
        return cityGroups.compactMap { _, groupContacts in
            guard let firstContact = groupContacts.first else { return nil }
            
            let priorityScore = groupContacts.reduce(0) { sum, contact in
                sum + priorityWeight(for: contact.priority)
            }
            
            return CityPriority(
                city: firstContact.city,
                state: firstContact.state,
                country: firstContact.country,
                coordinate: nil,
                contacts: groupContacts,
                priorityScore: priorityScore
            )
        }.sorted { $0.priorityScore > $1.priorityScore }
    }
    
    // MARK: - Helpers
    
    /// Get weight for a priority tier
    private static func priorityWeight(for priority: Priority?) -> Int {
        switch priority {
        case .innerCircle: return 3
        case .keyRelationships: return 2
        case .broaderNetwork: return 1
        case .none: return 1
        }
    }
    
    /// Get contact names for notification display
    /// - Parameters:
    ///   - contacts: Contacts to get names from
    ///   - maxNames: Maximum number of names to return
    /// - Returns: Array of first names
    static func getDisplayNames(from contacts: [Contact], maxNames: Int = 3) -> [String] {
        contacts
            .prefix(maxNames)
            .map { contact in
                // Get first name only for notification brevity
                contact.name.components(separatedBy: " ").first ?? contact.name
            }
    }
}

// MARK: - Geocoding Extension

extension ContactLocationMatcher {
    
    /// Geocode coordinates for cities that need them
    /// - Parameters:
    ///   - cities: Cities to geocode
    ///   - geocoder: Optional CLGeocoder to use
    /// - Returns: Cities with coordinates populated
    static func geocodeCities(
        _ cities: [CityPriority]
    ) async -> [CityPriority] {
        var geocodedCities: [CityPriority] = []
        
        for city in cities {
            let searchQuery = city.locationKey
            
            // Use MapKit local search for geocoding
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchQuery
            request.resultTypes = [.address]
            
            let search = MKLocalSearch(request: request)
            
            do {
                let response = try await search.start()
                if let mapItem = response.mapItems.first {
                    let coordinate: CLLocationCoordinate2D
                    if #available(iOS 26.0, *) {
                        coordinate = mapItem.location.coordinate
                    } else {
                        coordinate = mapItem.placemark.coordinate
                    }
                    
                    var geocodedCity = city
                    geocodedCity.coordinate = coordinate
                    geocodedCities.append(geocodedCity)
                } else {
                    // Keep city without coordinate
                    geocodedCities.append(city)
                }
            } catch {
                // Keep city without coordinate on error
                geocodedCities.append(city)
            }
            
            // Small delay to avoid rate limiting
            try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
        }
        
        return geocodedCities
    }
}

