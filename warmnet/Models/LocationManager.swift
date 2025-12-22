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
        guard CLLocationManager.locationServicesEnabled() else {
            throw LocationError.serviceUnavailable
        }

        // Ensure we have authorization without blocking the main thread
        switch authorizationStatus {
        case .notDetermined:
            requestPermission()
            // Await delegate-driven authorization change instead of sleeping
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                self.authorizationContinuation = continuation
            }
            if authorizationStatus == .denied {
                throw LocationError.permissionDenied
            }
        case .denied:
            throw LocationError.permissionDenied
        case .authorized:
            break
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

