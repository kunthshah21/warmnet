import Foundation
import MapKit

/// Map annotation representing a contact location
final class ContactAnnotation: NSObject, MKAnnotation, Identifiable {
    
    // MARK: - Properties
    
    let id: UUID
    let contactId: UUID
    let contactName: String
    let coordinate: CLLocationCoordinate2D
    let city: String
    let state: String
    let country: String
    
    // MKAnnotation properties
    var title: String? { contactName }
    var subtitle: String? {
        [city, state].filter { !$0.isEmpty }.joined(separator: ", ")
    }
    
    // Cluster identifier for grouping nearby pins
    static let clusterIdentifier = "contactCluster"
    
    // MARK: - Init
    
    init(from cachedLocation: ContactLocationService.CachedLocation) {
        self.id = cachedLocation.id
        self.contactId = cachedLocation.contactId
        self.contactName = cachedLocation.contactName
        self.coordinate = cachedLocation.coordinate
        self.city = cachedLocation.city
        self.state = cachedLocation.state
        self.country = cachedLocation.country
        super.init()
    }
    
    init(
        contactId: UUID,
        contactName: String,
        coordinate: CLLocationCoordinate2D,
        city: String = "",
        state: String = "",
        country: String = ""
    ) {
        self.id = UUID()
        self.contactId = contactId
        self.contactName = contactName
        self.coordinate = coordinate
        self.city = city
        self.state = state
        self.country = country
        super.init()
    }
}

