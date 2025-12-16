import SwiftUI
import SwiftData
import MapKit

/// Map screen showing contact locations with clustering and filtering
struct MapScreen: View {
    
    // MARK: - Environment
    
    @Query private var contacts: [Contact]
    
    // MARK: - State
    
    @State private var locationService = ContactLocationService()
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedFilterType: FilterType = .all
    @State private var selectedFilterValue: String?
    @State private var selectedAnnotation: ContactAnnotation?
    @State private var hasLoaded = false
    
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
                ToolbarItem(placement: .topBarTrailing) {
                    refreshButton
                }
            }
            .task {
                await loadContactLocations()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var mapView: some View {
        Map(position: $cameraPosition, selection: $selectedAnnotation) {
            ForEach(annotations) { annotation in
                Annotation(
                    annotation.contactName,
                    coordinate: annotation.coordinate,
                    anchor: .bottom
                ) {
                    annotationView(for: annotation)
                }
                .tag(annotation)
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapCompass()
            MapScaleView()
            MapUserLocationButton()
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private func annotationView(for annotation: ContactAnnotation) -> some View {
        VStack(spacing: 0) {
            // Contact initial bubble
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)
                    .shadow(color: .blue.opacity(0.3), radius: 4, y: 2)
                
                Text(annotation.contactName.prefix(1).uppercased())
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            // Pin point
            Image(systemName: "triangle.fill")
                .font(.system(size: 10))
                .foregroundStyle(.blue)
                .rotationEffect(.degrees(180))
                .offset(y: -3)
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
            Task {
                await loadContactLocations()
            }
        } label: {
            Image(systemName: "arrow.clockwise")
                .font(.body)
        }
        .disabled(locationService.isLoading)
    }
    
    // MARK: - Actions
    
    private func loadContactLocations() async {
        await locationService.geocodeContacts(contacts)
        hasLoaded = true
        
        // Fit map to show all pins
        if let region = locationService.regionToFit(filteredLocations) {
            withAnimation(.easeInOut(duration: 0.5)) {
                cameraPosition = .region(region)
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
                    cameraPosition = .region(region)
                }
            }
        } else if let value = selectedFilterValue {
            // Zoom to specific location
            if let coordinate = await locationService.getCoordinate(for: value) {
                let span = locationService.zoomSpan(for: selectedFilterType)
                let region = MKCoordinateRegion(center: coordinate, span: span)
                
                withAnimation(.easeInOut(duration: 0.5)) {
                    cameraPosition = .region(region)
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

