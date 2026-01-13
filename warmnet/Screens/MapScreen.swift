import SwiftUI
import SwiftData
import MapKit

/// Map screen showing contact locations with clustering and filtering
struct MapScreen: View {
    
    // MARK: - Environment
    
    @Query private var contacts: [Contact]
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    
    @State private var locationService = ContactLocationService.shared
    @State private var mapRegion: MKCoordinateRegion?
    @State private var selectedFilterType: FilterType = .all
    @State private var selectedFilterValue: String?
    @State private var selectedContactId: UUID?
    @State private var hasLoaded = false

    // MARK: - Configuration

    let showsDismissButton: Bool

    init(showsDismissButton: Bool = false) {
        self.showsDismissButton = showsDismissButton
    }
    
    // MARK: - Computed
    
    private var filteredLocations: [ContactLocationService.CachedLocation] {
        locationService.filterLocations(by: selectedFilterType, value: selectedFilterValue)
    }
    
    private var annotations: [ContactAnnotation] {
        filteredLocations.map { ContactAnnotation(from: $0) }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Map
                mapView
                
                // Filter bar overlay
                VStack {
                    MapFilterBar(
                        selectedFilterType: $selectedFilterType,
                        selectedValue: $selectedFilterValue,
                        availableCities: locationService.availableCities,
                        availableStates: locationService.availableStates,
                        availableCountries: locationService.availableCountries,
                        onFilterChanged: handleFilterChanged
                    )
                    
                    Spacer()
                }
                
                // Loading overlay
                if locationService.isLoading {
                    loadingOverlay
                }
                
                // Empty state
                if !locationService.isLoading && filteredLocations.isEmpty && hasLoaded {
                    emptyState
                }
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if showsDismissButton {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    refreshButton
                }
            }
            .onDisappear {
                // Map may be torn down; pause heavy updates
                locationService.cancelGeocoding()
                locationService.notifyMapNotReady()
            }
            .onChange(of: locationService.isLoading) { _, isLoading in
                if !isLoading {
                    hasLoaded = true
                    if let region = locationService.regionToFit(filteredLocations) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            mapRegion = region
                        }
                    }
                } else {
                    hasLoaded = false
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var mapView: some View {
        ClusteredMapView(
            annotations: annotations,
            region: $mapRegion,
            onAnnotationSelected: { annotation in
                // Navigate to contact detail
                selectedContactId = annotation.contactId
            },
            onClusterTapped: { cluster in
                // Zoom into the cluster
                zoomToCluster(cluster)
            }
        )
        .ignoresSafeArea(edges: .bottom)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(minHeight: 300)
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        let size = proxy.size
                        if size.width > 0 && size.height > 0 {
                            locationService.notifyMapReady()
                        }
                    }
                    .onChange(of: proxy.size) { _, newSize in
                        if newSize.width > 0 && newSize.height > 0 {
                            locationService.notifyMapReady()
                        }
                    }
            }
        )
        .navigationDestination(item: $selectedContactId) { contactId in
            if let contact = contacts.first(where: { $0.id == contactId }) {
                ContactDetailScreen(contact: contact)
            }
        }
    }
    
    /// Zooms the map to show all annotations within a cluster
    private func zoomToCluster(_ cluster: MKClusterAnnotation) {
        let memberAnnotations = cluster.memberAnnotations
        guard !memberAnnotations.isEmpty else { return }
        
        // Calculate bounding region for all cluster members
        var minLat = CLLocationDegrees.greatestFiniteMagnitude
        var maxLat = -CLLocationDegrees.greatestFiniteMagnitude
        var minLon = CLLocationDegrees.greatestFiniteMagnitude
        var maxLon = -CLLocationDegrees.greatestFiniteMagnitude
        
        for annotation in memberAnnotations {
            let coord = annotation.coordinate
            minLat = min(minLat, coord.latitude)
            maxLat = max(maxLat, coord.latitude)
            minLon = min(minLon, coord.longitude)
            maxLon = max(maxLon, coord.longitude)
        }
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        // Add padding and ensure minimum zoom
        let latDelta = max((maxLat - minLat) * 1.5, 0.01)
        let lonDelta = max((maxLon - minLon) * 1.5, 0.01)
        
        let span = MKCoordinateSpan(
            latitudeDelta: latDelta,
            longitudeDelta: lonDelta
        )
        
        withAnimation {
            mapRegion = MKCoordinateRegion(center: center, span: span)
        }
    }
    
    private var loadingOverlay: some View {
        VStack(spacing: 16) {
            Spacer()
            
            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.2)
                
                Text("Loading contact locations...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                ProgressView(value: locationService.loadingProgress)
                    .frame(width: 200)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            
            Spacer()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            
            VStack(spacing: 12) {
                Image(systemName: "map")
                    .font(.system(size: 48))
                    .foregroundStyle(.tertiary)
                
                Text("No Contacts to Display")
                    .font(.headline)
                
                Text(emptyStateMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    private var emptyStateMessage: String {
        if selectedFilterValue != nil {
            return "No contacts found for the selected \(selectedFilterType.rawValue.lowercased())."
        } else if contacts.isEmpty {
            return "Add contacts with location info to see them on the map."
        } else {
            return "Add location info to your contacts to see them on the map."
        }
    }
    
    private var refreshButton: some View {
        Button {
            locationService.debouncedGeocodeContacts(contacts)
        } label: {
            Image(systemName: "arrow.clockwise")
                .font(.body)
        }
        .scaleEffect(0.5)
        .disabled(locationService.isLoading)
    }
    
    // MARK: - Actions
    
    private func loadContactLocations() async {
        await locationService.geocodeContacts(contacts)
        hasLoaded = true
        
        // Fit map to show all pins
        if let region = locationService.regionToFit(filteredLocations) {
            withAnimation(.easeInOut(duration: 0.5)) {
                mapRegion = region
            }
        }
    }
    
    private func handleFilterChanged() {
        Task {
            await animateToFilteredRegion()
        }
    }
    
    private func animateToFilteredRegion() async {
        if selectedFilterType == .all || selectedFilterValue == nil {
            // Show all contacts
            if let region = locationService.regionToFit(filteredLocations) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    mapRegion = region
                }
            }
        } else if let value = selectedFilterValue {
            // Zoom to specific location
            if let coordinate = await locationService.getCoordinate(for: value) {
                let span = locationService.zoomSpan(for: selectedFilterType)
                let region = MKCoordinateRegion(center: coordinate, span: span)
                
                withAnimation(.easeInOut(duration: 0.5)) {
                    mapRegion = region
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MapScreen()
        .modelContainer(for: Contact.self, inMemory: true)
}

