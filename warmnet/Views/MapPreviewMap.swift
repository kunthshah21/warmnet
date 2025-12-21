import SwiftUI
import SwiftData
import MapKit

/// Lightweight, non-interactive map preview used inside the Home map card.
struct MapPreviewMap: View {
    @Query private var contacts: [Contact]

    @State private var locationService = ContactLocationService()
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var hasLoaded = false

    private var cachedLocations: [ContactLocationService.CachedLocation] {
        locationService.cachedLocations
    }

    private var annotations: [ContactAnnotation] {
        cachedLocations.map { ContactAnnotation(from: $0) }
    }

    var body: some View {
        ZStack {
            Map(position: $cameraPosition, interactionModes: []) {
                ForEach(annotations) { annotation in
                    Annotation(
                        annotation.contactName,
                        coordinate: annotation.coordinate,
                        anchor: .bottom
                    ) {
                        markerView(for: annotation)
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .background(mapReadyReporter)

            if locationService.isLoading {
                loadingOverlay
            } else if hasLoaded && cachedLocations.isEmpty {
                emptyOverlay
            }
        }
        .onAppear {
            locationService.debouncedGeocodeContacts(contacts)
        }
        .onDisappear {
            locationService.notifyMapNotReady()
        }
        .onChange(of: locationService.isLoading) { isLoading in
            if !isLoading {
                hasLoaded = true
                if let region = locationService.regionToFit(cachedLocations) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        cameraPosition = .region(region)
                    }
                }
            } else {
                hasLoaded = false
            }
        }
        .onChange(of: contacts) { _ in
            locationService.debouncedGeocodeContacts(contacts)
        }
    }

    private var mapReadyReporter: some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear {
                    let size = proxy.size
                    if size.width > 0 && size.height > 0 {
                        locationService.notifyMapReady()
                    }
                }
                .onChange(of: proxy.size) { newSize in
                    if newSize.width > 0 && newSize.height > 0 {
                        locationService.notifyMapReady()
                    }
                }
        }
    }

    private func markerView(for annotation: ContactAnnotation) -> some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.blue, .blue.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 24, height: 24)

            Text(annotation.contactName.prefix(1).uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white)
        }
        .shadow(color: .blue.opacity(0.25), radius: 3, y: 2)
        .accessibilityHidden(true)
    }

    private var loadingOverlay: some View {
        VStack(spacing: 8) {
            ProgressView()
            Text("Loading locations…")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }

    private var emptyOverlay: some View {
        VStack(spacing: 6) {
            Image(systemName: "map")
                .font(.title3)
                .foregroundStyle(.tertiary)

            Text("No locations yet")
                .font(.caption.weight(.semibold))

            Text("Add a contact with a city/state/country.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview {
    MapPreviewMap()
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .padding()
        .modelContainer(for: Contact.self, inMemory: true)
}


