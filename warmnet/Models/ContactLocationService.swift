import Foundation
import SwiftData
import MapKit
import CoreLocation

/// Service for geocoding contact locations and caching coordinates
@Observable
final class ContactLocationService {
    
    // MARK: - Shared
    
    /// Shared instance so the preview map can reflect the last refreshed results from the Map screen.
    static let shared = ContactLocationService()
    
    // MARK: - Configuration
    /// Delay before starting bulk geocoding to allow initial map layout to stabilize
    private let initialStartDelay: UInt64 = 200_000_000 // 200ms
    /// Maximum number of concurrent geocoding operations
    private let maxConcurrentGeocodes: Int = 3
    /// Yield frequency to keep the main thread responsive during progress updates
    private let yieldEveryNItems: Int = 5
    /// Maximum time to wait for the map to become ready before proceeding
    private let mapReadyWaitTimeout: UInt64 = 1_000_000_000 // 1s
    
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
    
    private var coordinateCache: [String: CLLocationCoordinate2D] = [:]
    
    /// Optional region to bias geocoding/search results
    var biasRegion: MKCoordinateRegion?
    
    var cachedLocations: [CachedLocation] = []
    var isLoading = false
    var loadingProgress: Double = 0
    
    /// Indicates when the map view has a stable, non-zero size and can accept updates
    private var mapIsReady: Bool = false
    /// Continuations waiting for the map to become ready
    @MainActor
    private struct MapReadyWaiter {
        let id: UUID
        let continuation: CheckedContinuation<Void, Never>
    }
    /// Continuations waiting for the map to become ready (MainActor-only)
    @MainActor
    private var mapReadyWaiters: [MapReadyWaiter] = []
    
    /// Debounced task for bulk geocoding, allowing cancellation when view changes
    private var debouncedGeocodeTask: Task<Void, Never>? = nil
    
    /// Update the bias region used for geocoding
    func setBiasRegion(center: CLLocationCoordinate2D, span: MKCoordinateSpan) {
        biasRegion = MKCoordinateRegion(center: center, span: span)
    }
    
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
    
    /// Call when the map view has a non-zero, stable size so heavy updates can proceed
    func notifyMapReady() {
        Task { @MainActor in
            guard mapIsReady == false else { return }
            mapIsReady = true
            // Resume any waiters
            let waiters = mapReadyWaiters
            mapReadyWaiters.removeAll()
            waiters.forEach { $0.continuation.resume() }
        }
    }

    /// Call when the map is being torn down or may become zero-sized (e.g., during navigation)
    func notifyMapNotReady() {
        Task { @MainActor in
            mapIsReady = false
        }
    }
    
    /// Debounced trigger to geocode contacts without blocking initial UI setup
    /// Cancels any in-flight debounced task and schedules a new one with a slight delay
    func debouncedGeocodeContacts(_ contacts: [Contact]) {
        // Cancel previous debounced task if any
        debouncedGeocodeTask?.cancel()
        debouncedGeocodeTask = Task { [weak self] in
            // Small debounce to coalesce rapid updates (e.g., during navigation)
            try? await Task.sleep(nanoseconds: 150_000_000)
            guard let self else { return }
            await self.geocodeContacts(contacts)
        }
    }
    
    /// Cancel any in-flight geocoding work and reset loading UI state.
    /// This does NOT clear `cachedLocations` so the preview can keep showing the last refreshed results.
    func cancelGeocoding() {
        debouncedGeocodeTask?.cancel()
        debouncedGeocodeTask = nil
        
        Task { @MainActor in
            isLoading = false
            loadingProgress = 0
        }
    }
    
    /// Geocode all contacts and cache their coordinates
    /// - Parameter contacts: Array of contacts to geocode
    func geocodeContacts(_ contacts: [Contact]) async {
        // Wait for the map to report a stable size (or time out) to avoid zero-sized drawables
        await waitForMapReady(timeoutNanoseconds: mapReadyWaitTimeout)
        if Task.isCancelled { return }
        // Small additional delay to avoid competing with initial render
        try? await Task.sleep(nanoseconds: initialStartDelay)
        if Task.isCancelled { return }

        await MainActor.run {
            isLoading = true
            loadingProgress = 0
            cachedLocations = []
        }

        let contactsWithLocation = contacts.filter { !$0.fullLocation.isEmpty }
        let totalCount = contactsWithLocation.count
        if totalCount == 0 {
            await MainActor.run { isLoading = false }
            return
        }

        // Concurrency control using a simple semaphore
        let semaphore = AsyncSemaphore(value: maxConcurrentGeocodes)
        var processed = 0
        var newCached: [CachedLocation] = []

        await withTaskGroup(of: CachedLocation?.self) { group in
            for contact in contactsWithLocation {
                if Task.isCancelled { break }
                await semaphore.wait()
                group.addTask { [weak self] in
                    defer { Task { await semaphore.signal() } }
                    guard let self else { return nil }
                    if Task.isCancelled { return nil }
                    if let coordinate = await self.geocodeContact(contact) {
                        return CachedLocation(
                            id: UUID(),
                            contactId: contact.id,
                            contactName: contact.name,
                            coordinate: coordinate,
                            city: contact.city,
                            state: contact.state,
                            country: contact.country
                        )
                    }
                    return nil
                }
            }

            for await result in group {
                if Task.isCancelled { break }
                if let cached = result {
                    newCached.append(cached)
                }
                processed += 1

                // Periodically yield and update progress on main thread
                if processed % yieldEveryNItems == 0 || processed == totalCount {
                    let progress = Double(processed) / Double(totalCount)
                    let batch = newCached
                    newCached.removeAll(keepingCapacity: true)
                    await MainActor.run {
                        self.cachedLocations.append(contentsOf: batch)
                        loadingProgress = progress
                    }
                    await Task.yield()
                }
            }
        }

        // Flush any remaining items and finish
        let finalBatch = newCached
        await MainActor.run {
            self.cachedLocations.append(contentsOf: finalBatch)
            self.loadingProgress = 1.0
            self.isLoading = false
        }
    }
    
    /// Get coordinate for a location string (city, state, or country)
    /// - Parameter location: Location string to geocode
    /// - Returns: Coordinate if found
    func getCoordinate(for location: String) async -> CLLocationCoordinate2D? {
        // Check cache first
        if let cached = coordinateCache[location] {
            return cached
        }
        // Use MapKit search to geocode
        if let coordinate = await geocodeAddressString(location) {
            coordinateCache[location] = coordinate
            return coordinate
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
    
    /// Lightweight async semaphore for concurrency control without blocking threads
    private actor AsyncSemaphore {
        private var value: Int
        private var waiters: [CheckedContinuation<Void, Never>] = []

        init(value: Int) { self.value = max(1, value) }

        func wait() async {
            if value > 0 {
                value -= 1
                return
            }
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                waiters.append(continuation)
            }
        }

        func signal() {
            if waiters.isEmpty {
                value += 1
            } else {
                let next = waiters.removeFirst()
                next.resume()
            }
        }
    }
    
    /// Wait until the map is marked ready or until timeout elapses
    private func waitForMapReady(timeoutNanoseconds: UInt64) async {
        if await MainActor.run(body: { mapIsReady }) { return }
        // Race a readiness continuation against a timeout sleep
        await withTaskGroup(of: Void.self) { group in
            group.addTask { [weak self] in
                guard let self else { return }
                await self.awaitMapReady()
            }
            group.addTask {
                try? await Task.sleep(nanoseconds: timeoutNanoseconds)
            }
            // Return after the first completes
            await group.next()
            // Cancel the other task
            group.cancelAll()
        }
    }

    /// Suspend until `notifyMapReady()` is called (or return immediately if already ready).
    /// Cancellation removes the registered waiter to avoid leaking continuations.
    @MainActor
    private func awaitMapReady() async {
        if mapIsReady { return }
        let id = UUID()
        await withTaskCancellationHandler(operation: {
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                // If ready already flipped while scheduling, resume immediately
                if mapIsReady {
                    continuation.resume()
                } else {
                    mapReadyWaiters.append(.init(id: id, continuation: continuation))
                }
            }
        }, onCancel: {
            Task { @MainActor in
                mapReadyWaiters.removeAll { $0.id == id }
            }
        })
    }
    
    /// Forward geocode a textual location using MapKit search
    /// - Parameter query: A human-readable place string (city, state, country, etc.)
    /// - Returns: The best matching coordinate if available
    private func geocodeAddressString(_ query: String) async -> CLLocationCoordinate2D? {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        // Apply regional bias if available
        if let region = biasRegion {
            request.region = region
        }
        // Prefer broader context since inputs are often city/state/country
        request.resultTypes = [.address, .pointOfInterest]
        let search = MKLocalSearch(request: request)
        do {
            let response = try await search.start()
            // Prefer the first map item that has a coordinate
            if let item = response.mapItems.first {
                if #available(iOS 26.0, *) {
                    return item.location.coordinate
                } else {
                    return item.placemark.coordinate
                }
            }
        } catch {
            // Search failed; fall through to return nil
        }
        return nil
    }
    
    private func geocodeContact(_ contact: Contact) async -> CLLocationCoordinate2D? {
        let locationKey = contact.fullLocation
        // Check cache first
        if let cached = coordinateCache[locationKey] {
            return cached
        }
        // Rate limit to avoid throttling (removed explicit 100ms delay for concurrency control)
        if let coordinate = await geocodeAddressString(locationKey) {
            coordinateCache[locationKey] = coordinate
            return coordinate
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

