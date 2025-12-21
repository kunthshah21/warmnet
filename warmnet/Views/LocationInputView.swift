import SwiftUI
import MapKit

/// A unified location input component with autocomplete and current location support
struct LocationInputView: View {
    
    // MARK: - Bindings
    
    @Binding var city: String
    @Binding var state: String
    @Binding var country: String
    
    // MARK: - State
    
    @State private var inputText = ""
    @State private var inputState: InputState = .empty
    @State private var showSuggestions = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    // Lazy initialization: only create services when actually needed
    @State private var locationManager: LocationManager?
    @State private var geocodingService: GeocodingService?
    
    // MARK: - Types
    
    private enum InputState: Equatable {
        case empty
        case typing
        case searching
        case found(displayName: String)
        case error
    }
    
    // MARK: - Computed Properties
    
    private var showCurrentLocationButton: Bool {
        (locationManager?.authorizationStatus != .denied) ?? false
    }
    
    private var displayText: String {
        if case .found(let displayName) = inputState {
            return displayName
        }
        return inputText
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Location")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if showCurrentLocationButton {
                    currentLocationButton
                }
            }
            
            // Input field
            locationInputField
            
            // Autocomplete suggestions
            if showSuggestions && !(geocodingService?.suggestions.isEmpty ?? true) {
                suggestionsView
            }
            
            // Status indicator
            statusIndicator
        }
        .alert("Location Error", isPresented: $showError) {
            Button("Try Again", role: .cancel) {
                inputState = .typing
            }
        } message: {
            Text(errorMessage ?? "An error occurred")
        }
        .onAppear {
            // Initialize services asynchronously on appear to avoid blocking main thread
            // This ensures services are ready when user interacts with the field
            Task { @MainActor in
                ensureServices()
            }
            
            // Only initialize from bindings if we have existing values to show
            let existingLocation = [city, state, country]
                .filter { !$0.isEmpty }
                .joined(separator: ", ")
            
            if !existingLocation.isEmpty {
                ensureServices()
                initializeFromBindings()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var currentLocationButton: some View {
        Button {
            Task {
                await useCurrentLocation()
            }
        } label: {
            HStack(spacing: 4) {
                if inputState == .searching {
                    ProgressView()
                        .scaleEffect(0.7)
                } else {
                    Image(systemName: "location.fill")
                        .font(.caption)
                }
                
                Text("Use Current")
                    .font(.caption.weight(.medium))
            }
            .foregroundStyle(.blue)
        }
        .disabled(inputState == .searching)
        .buttonStyle(.plain)
    }
    
    private var locationInputField: some View {
        HStack(spacing: 12) {
            Image(systemName: "mappin.circle.fill")
                .font(.title3)
                .foregroundStyle(inputStateColor)
            
            TextField("Enter city, state, or country", text: $inputText)
                .textContentType(.addressCity)
                .autocorrectionDisabled()
                .onChange(of: inputText) { _, newValue in
                    handleInputChange(newValue)
                }
                .onSubmit {
                    Task {
                        await geocodeInput()
                    }
                }
            
            // Clear button
            if !inputText.isEmpty {
                Button {
                    clearInput()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            // Status icon
            statusIcon
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(inputStateBorderColor, lineWidth: inputStateBorderWidth)
        )
    }
    
    @ViewBuilder
    private var statusIcon: some View {
        switch inputState {
        case .empty, .typing:
            EmptyView()
        case .searching:
            ProgressView()
                .scaleEffect(0.8)
        case .found:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        case .error:
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.red)
        }
    }
    
    private var suggestionsView: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(geocodingService?.suggestions.prefix(5) ?? []) { suggestion in
                Button {
                    Task {
                        await selectSuggestion(suggestion)
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(suggestion.title)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.primary)
                            
                            if !suggestion.subtitle.isEmpty {
                                Text(suggestion.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.left")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                if suggestion.id != geocodingService?.suggestions.prefix(5).last?.id {
                    Divider()
                        .padding(.leading, 16)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        )
    }
    
    @ViewBuilder
    private var statusIndicator: some View {
        switch inputState {
        case .found(let displayName):
            HStack(spacing: 6) {
                Image(systemName: "checkmark")
                    .font(.caption.weight(.semibold))
                
                Text(displayName)
                    .font(.caption)
            }
            .foregroundStyle(.green)
            
        case .error:
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.caption.weight(.semibold))
                
                Text("Invalid location")
                    .font(.caption)
            }
            .foregroundStyle(.red)
            
        default:
            EmptyView()
        }
    }
    
    // MARK: - Styling
    
    private var inputStateColor: Color {
        switch inputState {
        case .empty, .typing, .searching:
            return .secondary
        case .found:
            return .green
        case .error:
            return .red
        }
    }
    
    private var inputStateBorderColor: Color {
        switch inputState {
        case .found:
            return .green.opacity(0.5)
        case .error:
            return .red.opacity(0.5)
        default:
            return .clear
        }
    }
    
    private var inputStateBorderWidth: CGFloat {
        switch inputState {
        case .found, .error:
            return 1.5
        default:
            return 0
        }
    }
    
    // MARK: - Actions
    
    /// Lazy initialization: create services only when needed
    private func ensureServices() {
        if locationManager == nil {
            locationManager = LocationManager()
        }
        if geocodingService == nil {
            geocodingService = GeocodingService()
        }
    }
    
    private func initializeFromBindings() {
        let existingLocation = [city, state, country]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
        
        if !existingLocation.isEmpty {
            inputText = existingLocation
            inputState = .found(displayName: existingLocation)
        }
    }
    
    private func handleInputChange(_ newValue: String) {
        // Ensure services are initialized (non-blocking - initialize asynchronously if needed)
        if geocodingService == nil {
            // Initialize asynchronously to avoid blocking input
            Task { @MainActor in
                ensureServices()
            }
        }
        
        if newValue.isEmpty {
            inputState = .empty
            showSuggestions = false
            geocodingService?.clearSuggestions()
            clearBindings()
        } else {
            // Check if this is a programmatic update from selection
            // If we are in .found state and the text matches, we should stay in .found state
            if case .found(let displayName) = inputState, displayName == newValue {
                return
            }

            // Check if we had a valid result BEFORE changing state
            let hadValidResult: Bool
            if case .found = inputState {
                hadValidResult = true
            } else {
                hadValidResult = false
            }
            
            inputState = .typing
            showSuggestions = true
            
            // Only update search query if service is ready
            // If not ready yet, it will be initialized asynchronously above
            if let service = geocodingService {
                service.updateSearchQuery(newValue)
            } else {
                // Service not ready yet, ensure it's initialized and try again
                ensureServices()
                geocodingService?.updateSearchQuery(newValue)
            }
            
            // Only clear bindings if we previously had a valid result
            // This prevents clearing on every keystroke, which causes excessive parent view updates
            if hadValidResult {
                clearBindings()
            }
        }
    }
    
    private func clearInput() {
        inputText = ""
        inputState = .empty
        showSuggestions = false
        geocodingService?.clearSuggestions()
        clearBindings()
    }
    
    private func clearBindings() {
        city = ""
        state = ""
        country = ""
    }
    
    private func selectSuggestion(_ suggestion: GeocodingService.SearchSuggestion) async {
        ensureServices()
        inputState = .searching
        showSuggestions = false
        
        do {
            guard let geocodingService = geocodingService else { return }
            let result = try await geocodingService.geocode(completion: suggestion.completion)
            applyResult(result)
        } catch let error as GeocodingService.GeocodingError {
            handleError(error)
        } catch {
            handleError(GeocodingService.GeocodingError.networkError)
        }
    }
    
    private func geocodeInput() async {
        ensureServices()
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        inputState = .searching
        showSuggestions = false
        
        do {
            guard let geocodingService = geocodingService else { return }
            let result = try await geocodingService.geocode(text: inputText)
            applyResult(result)
        } catch let error as GeocodingService.GeocodingError {
            handleError(error)
        } catch {
            handleError(GeocodingService.GeocodingError.networkError)
        }
    }
    
    private func useCurrentLocation() async {
        ensureServices()
        inputState = .searching
        showSuggestions = false
        
        do {
            guard let locationManager = locationManager,
                  let geocodingService = geocodingService else { return }
            let location = try await locationManager.getCurrentLocation()
            let result = try await geocodingService.reverseGeocode(location: location)
            applyResult(result)
        } catch let error as LocationManager.LocationError {
            errorMessage = error.localizedDescription
            inputState = .error
            showError = true
        } catch let error as GeocodingService.GeocodingError {
            handleError(error)
        } catch {
            errorMessage = "Unable to get location. Please try again."
            inputState = .error
            showError = true
        }
    }
    
    private func applyResult(_ result: GeocodingService.LocationResult) {
        city = result.city
        state = result.state
        country = result.country
        inputText = result.displayName
        inputState = .found(displayName: result.displayName)
    }
    
    private func handleError(_ error: GeocodingService.GeocodingError) {
        errorMessage = error.localizedDescription
        inputState = .error
        showError = true
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var city = ""
        @State private var state = ""
        @State private var country = ""
        
        var body: some View {
            VStack {
                LocationInputView(
                    city: $city,
                    state: $state,
                    country: $country
                )
                .padding()
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("City: \(city)")
                    Text("State: \(state)")
                    Text("Country: \(country)")
                }
                .padding()
            }
        }
    }
    
    return PreviewWrapper()
}

