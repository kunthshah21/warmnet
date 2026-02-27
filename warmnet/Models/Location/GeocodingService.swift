import Foundation
import MapKit
import CoreLocation

/// Handles geocoding operations using MapKit for location search and validation
@Observable
final class GeocodingService: NSObject {
    
    // MARK: - Types
    
    struct LocationResult: Identifiable, Equatable {
        let id = UUID()
        let city: String
        let state: String
        let country: String
        let displayName: String
        
        var isComplete: Bool {
            !city.isEmpty && !state.isEmpty && !country.isEmpty
        }
        
        var isPartial: Bool {
            !isEmpty && !isComplete
        }
        
        var isEmpty: Bool {
            city.isEmpty && state.isEmpty && country.isEmpty
        }
        
        static func == (lhs: LocationResult, rhs: LocationResult) -> Bool {
            lhs.city == rhs.city && lhs.state == rhs.state && lhs.country == rhs.country
        }
    }
    
    struct SearchSuggestion: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let completion: MKLocalSearchCompletion
        
        var displayName: String {
            subtitle.isEmpty ? title : "\(title), \(subtitle)"
        }
    }
    
    enum GeocodingError: LocalizedError {
        case notFound
        case networkError
        case serviceUnavailable
        
        var errorDescription: String? {
            switch self {
            case .notFound:
                return "Location not found. Please check spelling and try again."
            case .networkError:
                return "Unable to verify location. Please check your connection."
            case .serviceUnavailable:
                return "Location service unavailable. Please try again later."
            }
        }
    }
    
    // MARK: - Properties
    
    // Legacy geocoder for iOS < 26 fallback paths
    @available(iOS, deprecated: 26.0, message: "Use MKGeocodingRequest or MKReverseGeocodingRequest on iOS 26+")
    private let legacyGeocoder = CLGeocoder()
    private let searchCompleter = MKLocalSearchCompleter()
    
    var suggestions: [SearchSuggestion] = []
    var isSearching = false
    
    /// Debounce task to prevent excessive search queries
    private var debounceTask: Task<Void, Never>?
    
    // MARK: - Init
    
    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .address
    }
    
    // MARK: - Public Methods
    
    /// Update autocomplete suggestions based on query (debounced)
    /// - Parameter query: The search query string
    func updateSearchQuery(_ query: String) {
        // Cancel previous debounce task if any
        debounceTask?.cancel()
        
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            suggestions = []
            isSearching = false
            return
        }
        
        // Debounce: wait 400ms after user stops typing before triggering search
        // This prevents blocking the main thread on every keystroke
        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 400_000_000) // 400ms
            guard let self, !Task.isCancelled else { return }
            
            await MainActor.run {
                self.isSearching = true
                self.searchCompleter.queryFragment = query
            }
        }
    }
    
    /// Clear current suggestions
    func clearSuggestions() {
        debounceTask?.cancel()
        debounceTask = nil
        suggestions = []
        isSearching = false
    }
    
    /// Geocode a search completion to get location details
    /// - Parameter completion: The MKLocalSearchCompletion to geocode
    /// - Returns: LocationResult with city, state, country
    func geocode(completion: MKLocalSearchCompletion) async throws -> LocationResult {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            guard let mapItem = response.mapItems.first else {
                throw GeocodingError.notFound
            }

            if #available(iOS 26, *) {
                return parseLocationResult(from: mapItem)
            } else {
                return parseLocationResult(from: mapItem.placemark)
            }
        } catch let error as GeocodingError {
            throw error
        } catch {
            throw GeocodingError.networkError
        }
    }
    
    /// Geocode a text string to get location details
    /// - Parameter text: The location text to geocode
    /// - Returns: LocationResult with city, state, country
    func geocode(text: String) async throws -> LocationResult {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            throw GeocodingError.notFound
        }
        
        if #available(iOS 26, *) {
            guard let request = MKGeocodingRequest(addressString: trimmedText) else {
                throw GeocodingError.notFound
            }
            do {
                let mapItems = try await request.mapItems
                guard let mapItem = mapItems.first else {
                    throw GeocodingError.notFound
                }
                return parseLocationResult(from: mapItem)
            } catch {
                throw GeocodingError.networkError
            }
        } else {
            do {
                let placemarks = try await legacyGeocoder.geocodeAddressString(trimmedText)
                guard let placemark = placemarks.first else {
                    throw GeocodingError.notFound
                }
                
                return parseLocationResult(from: placemark)
            } catch let error as GeocodingError {
                throw error
            } catch let error as CLError {
                switch error.code {
                case .network:
                    throw GeocodingError.networkError
                case .geocodeFoundNoResult, .geocodeFoundPartialResult:
                    throw GeocodingError.notFound
                default:
                    throw GeocodingError.serviceUnavailable
                }
            } catch {
                throw GeocodingError.networkError
            }
        }
    }
    
    /// Reverse geocode coordinates to get location details
    /// - Parameter location: The CLLocation to reverse geocode
    /// - Returns: LocationResult with city, state, country
    func reverseGeocode(location: CLLocation) async throws -> LocationResult {
        if #available(iOS 26, *) {
            guard let request = MKReverseGeocodingRequest(location: location) else {
                throw GeocodingError.notFound
            }
            do {
                let mapItems = try await request.mapItems
                guard let mapItem = mapItems.first else {
                    throw GeocodingError.notFound
                }
                return parseLocationResult(from: mapItem)
            } catch {
                throw GeocodingError.networkError
            }
        } else {
            do {
                let placemarks = try await legacyGeocoder.reverseGeocodeLocation(location)
                guard let placemark = placemarks.first else {
                    throw GeocodingError.notFound
                }
                
                return parseLocationResult(from: placemark)
            } catch let error as GeocodingError {
                throw error
            } catch let error as CLError {
                switch error.code {
                case .network:
                    throw GeocodingError.networkError
                case .geocodeFoundNoResult, .geocodeFoundPartialResult:
                    throw GeocodingError.notFound
                default:
                    throw GeocodingError.serviceUnavailable
                }
            } catch {
                throw GeocodingError.networkError
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func parseLocationResult(from placemark: CLPlacemark) -> LocationResult {
        let city = placemark.locality ?? ""
        let state = placemark.administrativeArea ?? ""
        let country = placemark.country ?? ""
        
        // Build display name from available components
        let components = [city, state, country].filter { !$0.isEmpty }
        let displayName = components.joined(separator: ", ")
        
        return LocationResult(
            city: city,
            state: state,
            country: country,
            displayName: displayName
        )
    }

    @available(iOS 26, *)
    private func parseLocationResult(from mapItem: MKMapItem) -> LocationResult {
        let addressText = mapItem.address?.fullAddress
            ?? mapItem.address?.shortAddress
            ?? mapItem.name
            ?? ""

        let components = addressText
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }

        let country = components.last ?? ""
        let state = components.dropLast().last ?? ""
        let city = components.dropLast(2).last ?? ""

        let displayName = addressText.isEmpty ? [city, state, country].filter { !$0.isEmpty }.joined(separator: ", ") : addressText

        return LocationResult(
            city: city,
            state: state,
            country: country,
            displayName: displayName
        )
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension GeocodingService: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        isSearching = false
        suggestions = completer.results.map { result in
            SearchSuggestion(
                title: result.title,
                subtitle: result.subtitle,
                completion: result
            )
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        isSearching = false
        suggestions = []
    }
}

