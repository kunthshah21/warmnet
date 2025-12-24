import SwiftUI
import SwiftData

struct LocationEnrichmentScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Contact.name) private var allContacts: [Contact]
    
    var onFlowComplete: () -> Void
    
    @State private var selectedContact: Contact?
    @State private var showSuccessSheet = false
    @State private var showMultiSelectSheet = false
    @State private var lastSavedLocation: (city: String, state: String, country: String)?
    @State private var selectedForBulkUpdate: Set<UUID> = []
    @State private var isFirstLocationSaved = true
    
    // Sorted contacts: no location first, then by priority (green > blue > yellow)
    private var sortedContacts: [Contact] {
        allContacts.sorted { contact1, contact2 in
            let hasLocation1 = !contact1.fullLocation.isEmpty
            let hasLocation2 = !contact2.fullLocation.isEmpty
            
            // Contacts without location come first
            if hasLocation1 != hasLocation2 {
                return !hasLocation1
            }
            
            // Then sort by priority (innerCircle > keyRelationships > broaderNetwork)
            let priority1 = priorityOrder(contact1.priority)
            let priority2 = priorityOrder(contact2.priority)
            
            if priority1 != priority2 {
                return priority1 < priority2
            }
            
            // Finally sort by name
            return contact1.name < contact2.name
        }
    }
    
    private func priorityOrder(_ priority: Priority?) -> Int {
        switch priority {
        case .innerCircle: return 0
        case .keyRelationships: return 1
        case .broaderNetwork, .none: return 2
        }
    }
    
    private var contactsWithoutLocation: [Contact] {
        sortedContacts.filter { $0.fullLocation.isEmpty }
    }
    
    private var contactsWithLocation: [Contact] {
        sortedContacts.filter { !$0.fullLocation.isEmpty }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if !contactsWithoutLocation.isEmpty {
                        Section {
                            ForEach(contactsWithoutLocation) { contact in
                                LocationEnrichmentRow(
                                    contact: contact,
                                    onTap: {
                                        selectedContact = contact
                                    }
                                )
                            }
                        } header: {
                            sectionHeader("Needs Location", count: contactsWithoutLocation.count)
                        }
                    }
                    
                    if !contactsWithLocation.isEmpty {
                        Section {
                            ForEach(contactsWithLocation) { contact in
                                LocationEnrichmentRow(
                                    contact: contact,
                                    onTap: {
                                        selectedContact = contact
                                    }
                                )
                            }
                        } header: {
                            sectionHeader("Has Location", count: contactsWithLocation.count)
                        }
                    }
                }
                .padding()
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Location Enrich")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    print("LocationEnrichmentScreen: Done pressed, calling onFlowComplete")
                    onFlowComplete()
                }
                .fontWeight(.semibold)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .sheet(item: $selectedContact) { contact in
            LocationInputSheet(
                contact: contact,
                onSave: { city, state, country in
                    lastSavedLocation = (city, state, country)
                    selectedContact = nil
                    showSuccessSheet = true
                },
                onCancel: {
                    selectedContact = nil
                }
            )
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showSuccessSheet) {
            SuccessSheet(
                isFirstLocation: isFirstLocationSaved,
                onYesMultiple: {
                    isFirstLocationSaved = false
                    showSuccessSheet = false
                    selectedForBulkUpdate.removeAll()
                    showMultiSelectSheet = true
                },
                onNo: {
                    isFirstLocationSaved = false
                    showSuccessSheet = false
                }
            )
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showMultiSelectSheet) {
            if let location = lastSavedLocation {
                MultiSelectLocationSheet(
                    contacts: contactsWithoutLocation.filter { $0.id != selectedContact?.id },
                    location: location,
                    onSave: { selectedIds in
                        applyLocationToContacts(selectedIds, location: location)
                        showMultiSelectSheet = false
                    },
                    onCancel: {
                        showMultiSelectSheet = false
                    }
                )
                .presentationDetents([.large])
            }
        }
    }
    
    private func sectionHeader(_ title: String, count: Int) -> some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text("\(count)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.secondary.opacity(0.2)))
        }
        .padding(.horizontal, 4)
    }
    
    private func applyLocationToContacts(_ ids: Set<UUID>, location: (city: String, state: String, country: String)) {
        for contact in allContacts where ids.contains(contact.id) {
            contact.city = location.city
            contact.state = location.state
            contact.country = location.country
            contact.updatedAt = Date()
        }
    }
}

// MARK: - Location Enrichment Row

struct LocationEnrichmentRow: View {
    let contact: Contact
    let onTap: () -> Void
    
    private var hasLocation: Bool {
        !contact.fullLocation.isEmpty
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Circle()
                    .fill(contact.priority?.color ?? .gray)
                    .frame(width: 10, height: 10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(contact.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    if hasLocation {
                        Text(contact.fullLocation)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    } else {
                        Text("Tap to add location")
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                    }
                }
                
                Spacer()
                
                Image(systemName: hasLocation ? "checkmark.circle.fill" : "plus.circle")
                    .font(.title3)
                    .foregroundStyle(hasLocation ? .green : .blue)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.secondary.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Location Input Sheet

struct LocationInputSheet: View {
    @Bindable var contact: Contact
    let onSave: (String, String, String) -> Void
    let onCancel: () -> Void
    
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var country: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Add Location for")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(contact.name)
                    .font(.title2.weight(.bold))
                
                LocationInputView(city: $city, state: $state, country: $country)
                    .padding(.horizontal)
                
                Spacer()
                
                PrimaryButton("Save Location", icon: "checkmark") {
                    contact.city = city
                    contact.state = state
                    contact.country = country
                    contact.updatedAt = Date()
                    onSave(city, state, country)
                }
                .disabled(city.isEmpty && state.isEmpty && country.isEmpty)
                .opacity((city.isEmpty && state.isEmpty && country.isEmpty) ? 0.5 : 1.0)
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Add Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
            }
        }
        .onAppear {
            city = contact.city
            state = contact.state
            country = contact.country
        }
    }
}

// MARK: - Success Sheet

struct SuccessSheet: View {
    let isFirstLocation: Bool
    let onYesMultiple: () -> Void
    let onNo: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)
            
            Text(isFirstLocation ? "Hooray!" : "Location Saved!")
                .font(.largeTitle.weight(.bold))
            
            Text(isFirstLocation ? "Your first location was updated successfully." : "The location has been saved.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            Text("Are there multiple people who share the same location?")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
            
            Spacer()
            
            VStack(spacing: 12) {
                PrimaryButton("Yes, Select Others", icon: "person.2.fill") {
                    onYesMultiple()
                }
                
                Button("No, Continue") {
                    onNo()
                }
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.vertical, 12)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding()
    }
}

// MARK: - Multi Select Location Sheet

struct MultiSelectLocationSheet: View {
    let contacts: [Contact]
    let location: (city: String, state: String, country: String)
    let onSave: (Set<UUID>) -> Void
    let onCancel: () -> Void
    
    @State private var selectedIds: Set<UUID> = []
    
    private var locationDisplay: String {
        [location.city, location.state, location.country]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text("Applying location:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(.red)
                        Text(locationDisplay)
                            .font(.headline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    )
                }
                .padding()
                
                Divider()
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(contacts) { contact in
                            MultiSelectRow(
                                contact: contact,
                                isSelected: selectedIds.contains(contact.id),
                                onToggle: {
                                    if selectedIds.contains(contact.id) {
                                        selectedIds.remove(contact.id)
                                    } else {
                                        selectedIds.insert(contact.id)
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                }
                .scrollContentBackground(.hidden)
                
                Divider()
                
                PrimaryButton("Save \(selectedIds.count) Contact\(selectedIds.count == 1 ? "" : "s")", icon: "checkmark") {
                    onSave(selectedIds)
                }
                .disabled(selectedIds.isEmpty)
                .opacity(selectedIds.isEmpty ? 0.5 : 1.0)
                .padding()
            }
            .navigationTitle("Select Contacts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(selectedIds.count == contacts.count ? "Deselect All" : "Select All") {
                        if selectedIds.count == contacts.count {
                            selectedIds.removeAll()
                        } else {
                            selectedIds = Set(contacts.map { $0.id })
                        }
                    }
                    .font(.subheadline)
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }
}

struct MultiSelectRow: View {
    let contact: Contact
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? .blue : .secondary)
                
                Circle()
                    .fill(contact.priority?.color ?? .gray)
                    .frame(width: 10, height: 10)
                
                Text(contact.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color.blue : Color.secondary.opacity(0.1), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, configurations: config)
    
    let contact1 = Contact(name: "Alice Smith", priority: .innerCircle)
    let contact2 = Contact(name: "Bob Jones", priority: .keyRelationships)
    let contact3 = Contact(name: "Charlie Brown", city: "New York", state: "NY", country: "USA", priority: .broaderNetwork)
    
    container.mainContext.insert(contact1)
    container.mainContext.insert(contact2)
    container.mainContext.insert(contact3)
    
    return NavigationStack {
        LocationEnrichmentScreen(onFlowComplete: {})
            .modelContainer(container)
    }
}
