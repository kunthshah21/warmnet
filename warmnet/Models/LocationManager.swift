import Foundation
import CoreLocation

/// Manages device location services for approximate location detection (city/state level)
@Observable
@MainActor
final class LocationManager: NSObject {
    
    // MARK: - Types
    
    enum AuthorizationStatus {
        case notDetermined
        case denied
        case authorized
    }
    
    enum LocationError: LocalizedError {
        case permissionDenied
        case serviceUnavailable
        case locationUnavailable
        case timeout
        
        var errorDescription: String? {
            switch self {
            case .permissionDenied:
                return "Location permission was denied. Please enable it in Settings."
            case .serviceUnavailable:
                return "Location services are unavailable on this device."
            case .locationUnavailable:
                return "Unable to determine your location. Please try again."
            case .timeout:
                return "Location request timed out. Please try again."
            }
        }
    }
    
    // MARK: - Properties
    
    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    private var authorizationContinuation: CheckedContinuation<Void, Never>?
    
    var authorizationStatus: AuthorizationStatus {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return .notDetermined
        case .restricted, .denied:
            return .denied
        case .authorizedWhenInUse, .authorizedAlways:
            return .authorized
        @unknown default:
            return .notDetermined
        }
    }
    
    var isAuthorized: Bool {
        authorizationStatus == .authorized
    }
    
    // MARK: - Init
    
    override init() {
        super.init()
        locationManager.delegate = self
        // Use kilometer accuracy for approximate location (city/state level)
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    // MARK: - Public Methods
    
    /// Request location permission from the user
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Get the current device location
    /// - Returns: The current CLLocation
    /// - Throws: LocationError if location cannot be determined
    func getCurrentLocation() async throws -> CLLocation {
        // Check location services availability (non-blocking static check)
        guard CLLocationManager.locationServicesEnabled() else {
            throw LocationError.serviceUnavailable
        }

        // Check authorization status once and handle accordingly
        // If not determined, wait for delegate callback to avoid blocking main thread
        let initialStatus = locationManager.authorizationStatus
        
        if initialStatus == .notDetermined {
            requestPermission()
            // Wait for delegate callback to update authorization status
            // This avoids synchronous authorization checks that can block the main thread
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                self.authorizationContinuation = continuation
            }
            // Check final status after delegate callback
            let finalStatus = locationManager.authorizationStatus
            if finalStatus == .denied || finalStatus == .restricted {
                throw LocationError.permissionDenied
            }
        } else if initialStatus == .denied || initialStatus == .restricted {
            throw LocationError.permissionDenied
        }

        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            locationManager.requestLocation()

            // Timeout after 10 seconds
            Task { [weak self] in
                try? await Task.sleep(nanoseconds: 10_000_000_000)
                guard let self, self.locationContinuation != nil else { return }
                self.locationContinuation?.resume(throwing: LocationError.timeout)
                self.locationContinuation = nil
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            locationContinuation?.resume(throwing: LocationError.locationUnavailable)
            locationContinuation = nil
            return
        }
        
        locationContinuation?.resume(returning: location)
        locationContinuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: LocationError.locationUnavailable)
        locationContinuation = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Resume any pending authorization wait if status is now determined
        if authorizationStatus != .notDetermined {
            authorizationContinuation?.resume()
            authorizationContinuation = nil
        }
    }
}

