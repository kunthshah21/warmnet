import SwiftUI

/// Filter bar for map location filtering by City, State, or Country
struct MapFilterBar: View {
    
    // MARK: - Bindings
    
    @Binding var selectedFilterType: FilterType
    @Binding var selectedValue: String?
    
    // MARK: - Properties
    
    let availableCities: [String]
    let availableStates: [String]
    let availableCountries: [String]
    
    var onFilterChanged: () -> Void
    
    // MARK: - Computed
    
    private var currentOptions: [String] {
        switch selectedFilterType {
        case .all:
            return []
        case .city:
            return availableCities
        case .state:
            return availableStates
        case .country:
            return availableCountries
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 12) {
            // Filter type selector
            filterTypeSelector
            
            // Value picker (when not "All")
            if selectedFilterType != .all && !currentOptions.isEmpty {
                valuePicker
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Subviews
    
    private var filterTypeSelector: some View {
        HStack(spacing: 8) {
            ForEach(FilterType.allCases, id: \.self) { type in
                filterTypeButton(for: type)
            }
        }
    }
    
    private func filterTypeButton(for type: FilterType) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedFilterType = type
                if type == .all {
                    selectedValue = nil
                } else {
                    // Auto-select first option when switching filter types
                    selectedValue = nil
                }
                onFilterChanged()
            }
        } label: {
            Text(type.rawValue)
                .font(.subheadline.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(selectedFilterType == type ? Color.blue : Color(.systemGray5))
                )
                .foregroundStyle(selectedFilterType == type ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
    
    private var valuePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "All [Type]" option
                allTypeButton
                
                // Divider
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(width: 1, height: 24)
                
                // Value options
                ForEach(currentOptions, id: \.self) { option in
                    valueButton(for: option)
                }
            }
            .padding(.horizontal, 4)
        }
        .scrollContentBackground(.visible)
    }
    
    private var allTypeButton: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedValue = nil
                onFilterChanged()
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "map")
                    .font(.caption)
                Text("All \(selectedFilterType.rawValue.lowercased())s")
            }
            .font(.caption.weight(.medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(selectedValue == nil ? Color.blue.opacity(0.15) : Color(.systemGray6))
            )
            .foregroundStyle(selectedValue == nil ? .blue : .secondary)
        }
        .buttonStyle(.plain)
    }
    
    private func valueButton(for value: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedValue = value
                onFilterChanged()
            }
        } label: {
            Text(value)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(selectedValue == value ? Color.blue.opacity(0.15) : Color(.systemGray6))
                )
                .foregroundStyle(selectedValue == value ? .blue : .primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var filterType: FilterType = .all
        @State private var selectedValue: String?
        
        var body: some View {
            VStack {
                MapFilterBar(
                    selectedFilterType: $filterType,
                    selectedValue: $selectedValue,
                    availableCities: ["New York", "Los Angeles", "Chicago", "Houston"],
                    availableStates: ["California", "Texas", "New York", "Florida"],
                    availableCountries: ["United States", "Canada", "Mexico"],
                    onFilterChanged: {}
                )
                
                Spacer()
                
                Text("Filter: \(filterType.rawValue)")
                Text("Value: \(selectedValue ?? "None")")
            }
        }
    }
    
    return PreviewWrapper()
}

