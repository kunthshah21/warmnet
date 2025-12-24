import SwiftUI
import Contacts
import SwiftData

struct ContactSelectScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    @State private var deviceContacts: [CNContact] = []
    @State private var selectedContacts: Set<String> = []
    @State private var searchText = ""
    @State private var isLoading = true
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isImporting = false
    @State private var navigateToEnrichment = false
    
    var onFlowComplete: (() -> Void)? = nil
    
    private let minimumSelection = 3
    
    private var filteredContacts: [CNContact] {
        if searchText.isEmpty {
            return deviceContacts
        }
        return deviceContacts.filter { contact in
            contact.fullName.localizedCaseInsensitiveContains(searchText) ||
            contact.phoneNumbers.contains { phone in
                phone.value.stringValue.contains(searchText)
            }
        }
    }
    
    private var canProceed: Bool {
        selectedContacts.count >= minimumSelection
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [backgroundTopColor, backgroundBottomColor],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                if isLoading {
                    loadingView
                } else if deviceContacts.isEmpty {
                    emptyStateView
                } else {
                    contactsListView
                }
                
                // Bottom action button
                if !isLoading && !deviceContacts.isEmpty {
                    bottomActionView
                }
            }
        }
        .navigationTitle("Select Contacts")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search contacts")
        .onAppear {
            loadDeviceContacts()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .navigationDestination(isPresented: $navigateToEnrichment) {
            EnrichInfoScreen(onGetStarted: {
                // Navigation handled internally
            }, onFlowComplete: {
                print("ContactSelectScreen: onFlowComplete called, onFlowComplete is \(onFlowComplete != nil ? "provided" : "nil")")
                // If we're in onboarding mode, dismiss back to ImportContactsScreen
                if let onFlowComplete = onFlowComplete {
                    print("ContactSelectScreen: Dismissing to parent screen")
                    dismiss()
                    // Call the completion handler after dismissing
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        print("ContactSelectScreen: Calling onFlowComplete callback")
                        onFlowComplete()
                    }
                } else {
                    print("ContactSelectScreen: No callback, dismissing navigation")
                    // Default behavior: Dismiss back to the root
                    navigateToEnrichment = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dismiss()
                    }
                }
            })
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Select at least \(minimumSelection) contacts")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("\(selectedContacts.count) selected")
                        .font(.caption)
                        .foregroundStyle(canProceed ? .green : .secondary)
                }
                
                Spacer()
                
                if selectedContacts.count > 0 {
                    Button("Clear All") {
                        selectedContacts.removeAll()
                    }
                    .font(.subheadline)
                    .foregroundStyle(.red)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            Divider()
        }
        .background(Material.ultraThinMaterial)
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading contacts...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.crop.circle.badge.xmark")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Contacts Found")
                .font(.title2.weight(.semibold))
            
            Text("Add contacts to your device and try again")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var contactsListView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(filteredContacts, id: \.identifier) { contact in
                    DeviceContactRow(
                        contact: contact,
                        isSelected: selectedContacts.contains(contact.identifier)
                    ) {
                        toggleSelection(for: contact)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .scrollContentBackground(.hidden)
    }
    
    private var bottomActionView: some View {
        VStack(spacing: 0) {
            Divider()
            
            PrimaryButton(
                isImporting ? "Importing..." : "Import \(selectedContacts.count) Contact\(selectedContacts.count == 1 ? "" : "s")",
                icon: "square.and.arrow.down"
            ) {
                importSelectedContacts()
            }
            .disabled(!canProceed || isImporting)
            .opacity(canProceed && !isImporting ? 1.0 : 0.5)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(Material.ultraThinMaterial)
    }
    
    // MARK: - Methods
    
    private func toggleSelection(for contact: CNContact) {
        if selectedContacts.contains(contact.identifier) {
            selectedContacts.remove(contact.identifier)
        } else {
            selectedContacts.insert(contact.identifier)
        }
    }
    
    private func loadDeviceContacts() {
        isLoading = true
        
        let store = CNContactStore()
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactPostalAddressesKey as CNKeyDescriptor,
            CNContactBirthdayKey as CNKeyDescriptor,
            CNContactOrganizationNameKey as CNKeyDescriptor,
            CNContactJobTitleKey as CNKeyDescriptor,
            CNContactImageDataKey as CNKeyDescriptor
        ]
        
        let request = CNContactFetchRequest(keysToFetch: keysToFetch)
        
        DispatchQueue.global(qos: .userInitiated).async {
            var contacts: [CNContact] = []
            
            do {
                try store.enumerateContacts(with: request) { contact, _ in
                    contacts.append(contact)
                }
                
                DispatchQueue.main.async {
                    self.deviceContacts = contacts.sorted { $0.fullName < $1.fullName }
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to load contacts: \(error.localizedDescription)"
                    self.showError = true
                    self.isLoading = false
                }
            }
        }
    }
    
    private func importSelectedContacts() {
        isImporting = true
        
        let contactsToImport = deviceContacts.filter { selectedContacts.contains($0.identifier) }
        
        DispatchQueue.global(qos: .userInitiated).async {
            for cnContact in contactsToImport {
                let contact = self.convertToContact(cnContact)
                
                DispatchQueue.main.async {
                    modelContext.insert(contact)
                }
            }
            
            DispatchQueue.main.async {
                do {
                    try modelContext.save()
                    
                    // Navigate to enrichment pipeline
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        navigateToEnrichment = true
                        isImporting = false
                    }
                } catch {
                    self.errorMessage = "Failed to save contacts: \(error.localizedDescription)"
                    self.showError = true
                    self.isImporting = false
                }
            }
        }
    }
    
    private func convertToContact(_ cnContact: CNContact) -> Contact {
        // Extract phone number
        var phoneNumber = ""
        var countryCode = "+1"
        
        if let phoneValue = cnContact.phoneNumbers.first?.value.stringValue {
            // Simple extraction - you may want more sophisticated parsing
            let digits = phoneValue.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            phoneNumber = digits
            
            // Try to extract country code if present
            if phoneValue.hasPrefix("+") {
                let components = phoneValue.components(separatedBy: " ")
                if let firstComponent = components.first, firstComponent.hasPrefix("+") {
                    countryCode = firstComponent
                    phoneNumber = digits.replacingOccurrences(of: countryCode.dropFirst(), with: "")
                }
            }
        }
        
        // Extract email
        let email = cnContact.emailAddresses.first?.value as String? ?? ""
        
        // Extract address components
        var city = ""
        var state = ""
        var country = ""
        
        if let address = cnContact.postalAddresses.first?.value {
            city = address.city
            state = address.state
            country = address.country
        }
        
        // Extract birthday
        var birthday: Date?
        if let birthdayComponents = cnContact.birthday {
            birthday = Calendar.current.date(from: birthdayComponents)
        }
        
        // Create and return Contact
        return Contact(
            name: cnContact.fullName,
            phoneCountryCode: countryCode,
            phoneNumber: phoneNumber,
            reference: "",
            email: email,
            city: city,
            state: state,
            country: country,
            birthday: birthday,
            company: cnContact.organizationName,
            jobTitle: cnContact.jobTitle,
            notes: ""
        )
    }
    
    // Background colors based on color scheme
    private var backgroundTopColor: Color {
        colorScheme == .dark ? Color(red: 0.05, green: 0.05, blue: 0.1) : Color(red: 0.95, green: 0.97, blue: 1.0)
    }
    
    private var backgroundBottomColor: Color {
        colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.15) : Color(red: 0.85, green: 0.90, blue: 0.98)
    }
}
