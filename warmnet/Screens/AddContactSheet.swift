import SwiftUI
import SwiftData

struct AddContactSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var contactToEdit: Contact?
    
    // Basic info
    @State private var name = ""
    @State private var selectedCountryCode = CountryCode.all[0]
    @State private var phoneNumber = ""
    @State private var reference = ""
    
    // Advanced info
    @State private var showAdvanced = false
    @State private var email = ""
    @State private var city = ""
    @State private var state = ""
    @State private var country = ""
    @State private var birthday: Date? = nil
    @State private var showBirthdayPicker = false
    @State private var company = ""
    @State private var jobTitle = ""
    @State private var notes = ""
    
    init(contactToEdit: Contact? = nil) {
        self.contactToEdit = contactToEdit
        
        if let contact = contactToEdit {
            _name = State(initialValue: contact.name)
            
            if let match = CountryCode.all.first(where: { $0.code == contact.phoneCountryCode }) {
                _selectedCountryCode = State(initialValue: match)
            }
            
            _phoneNumber = State(initialValue: contact.phoneNumber)
            _reference = State(initialValue: contact.reference)
            _email = State(initialValue: contact.email)
            _city = State(initialValue: contact.city)
            _state = State(initialValue: contact.state)
            _country = State(initialValue: contact.country)
            _birthday = State(initialValue: contact.birthday)
            _company = State(initialValue: contact.company)
            _jobTitle = State(initialValue: contact.jobTitle)
            _notes = State(initialValue: contact.notes)
            
            let hasAdvanced = !contact.email.isEmpty || !contact.city.isEmpty ||
                              !contact.state.isEmpty || !contact.country.isEmpty ||
                              contact.birthday != nil || !contact.company.isEmpty ||
                              !contact.jobTitle.isEmpty || !contact.notes.isEmpty
            _showAdvanced = State(initialValue: hasAdvanced)
        }
    }
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header avatar
                    headerSection
                    
                    // Basic fields
                    basicInfoSection
                    
                    // Advanced toggle
                    advancedToggle
                    
                    // Advanced fields
                    if showAdvanced {
                        advancedInfoSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .scrollContentBackground(.visible)
            .background(Color(.systemGroupedBackground))
            .navigationTitle(contactToEdit == nil ? "New Contact" : "Edit Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveContact()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
            .safeAreaInset(edge: .bottom) {
                saveButtonSection
            }
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            AvatarView(name: name.isEmpty ? "?" : name, size: 100)
            
            Text(name.isEmpty ? (contactToEdit == nil ? "New Contact" : "Edit Contact") : name)
                .font(.title2.weight(.semibold))
                .foregroundStyle(name.isEmpty ? .secondary : .primary)
        }
        .padding(.top, 20)
    }
    
    private var basicInfoSection: some View {
        VStack(spacing: 16) {
            sectionHeader("Basic Information")
            
            VStack(spacing: 12) {
                FormTextField(
                    title: "Name",
                    text: $name,
                    placeholder: "Full name",
                    autocapitalization: .words
                )
                
                phoneField
                
                FormTextField(
                    title: "Reference",
                    text: $reference,
                    placeholder: "How do you know this person?"
                )
            }
            .padding(16)
            .background(cardBackground)
        }
    }
    
    private var phoneField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Phone")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            
            HStack(spacing: 8) {
                // Country code picker
                Menu {
                    ForEach(CountryCode.all) { code in
                        Button {
                            selectedCountryCode = code
                        } label: {
                            Text(code.fullDisplayName)
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(selectedCountryCode.displayName)
                            .font(.body)
                        Image(systemName: "chevron.down")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.systemGray5))
                    )
                }
                
                // Phone number field
                TextField("Phone number", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.systemGray6))
                    )
            }
        }
    }
    
    private var advancedToggle: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                showAdvanced.toggle()
            }
        } label: {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .font(.body.weight(.medium))
                
                Text("Advanced Details")
                    .font(.subheadline.weight(.medium))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .rotationEffect(.degrees(showAdvanced ? 90 : 0))
            }
            .foregroundStyle(.secondary)
            .padding(16)
            .background(cardBackground)
        }
        .buttonStyle(.plain)
    }
    
    private var advancedInfoSection: some View {
        VStack(spacing: 16) {
            // Contact details
            VStack(spacing: 16) {
                sectionHeader("Contact Details")
                
                VStack(spacing: 12) {
                    FormTextField(
                        title: "Email",
                        text: $email,
                        placeholder: "email@example.com",
                        keyboardType: .emailAddress,
                        autocapitalization: .never
                    )
                }
                .padding(16)
                .background(cardBackground)
            }
            
            // Location
            VStack(spacing: 16) {
                sectionHeader("Location")
                
                LocationInputView(
                    city: $city,
                    state: $state,
                    country: $country
                )
                .padding(16)
                .background(cardBackground)
            }
            
            // Personal details
            VStack(spacing: 16) {
                sectionHeader("Personal Details")
                
                VStack(spacing: 12) {
                    // Birthday
                    birthdayField
                    
                    FormTextField(
                        title: "Company",
                        text: $company,
                        placeholder: "Company name",
                        autocapitalization: .words
                    )
                    
                    FormTextField(
                        title: "Job Title",
                        text: $jobTitle,
                        placeholder: "Job title",
                        autocapitalization: .words
                    )
                    
                    notesField
                }
                .padding(16)
                .background(cardBackground)
            }
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    private var birthdayField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Birthday")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            
            Button {
                showBirthdayPicker.toggle()
                if birthday == nil {
                    birthday = Date()
                }
            } label: {
                HStack {
                    if let birthday = birthday {
                        Text(birthday, style: .date)
                            .foregroundStyle(.primary)
                    } else {
                        Text("Add birthday")
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "calendar")
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemGray6))
                )
            }
            .buttonStyle(.plain)
            
            if showBirthdayPicker, let _ = birthday {
                DatePicker(
                    "Birthday",
                    selection: Binding(
                        get: { birthday ?? Date() },
                        set: { birthday = $0 }
                    ),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemGray6))
                )
            }
        }
    }
    
    private var notesField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            
            TextEditor(text: $notes)
                .frame(minHeight: 80)
                .padding(12)
                .scrollContentBackground(.hidden)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemGray6))
                )
        }
    }
    
    private var saveButtonSection: some View {
        VStack {
            PrimaryButton(contactToEdit == nil ? "Save Contact" : "Update Contact", icon: "checkmark") {
                saveContact()
            }
            .disabled(!isValid)
            .opacity(isValid ? 1 : 0.6)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Helpers
    
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            Spacer()
        }
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color(.systemBackground))
            .shadow(color: .black.opacity(0.03), radius: 8, y: 2)
    }
    
    // MARK: - Actions
    
    private func saveContact() {
        if let contact = contactToEdit {
            contact.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            contact.phoneCountryCode = selectedCountryCode.code
            contact.phoneNumber = phoneNumber
            contact.reference = reference
            contact.email = email
            contact.city = city
            contact.state = state
            contact.country = country
            contact.birthday = birthday
            contact.company = company
            contact.jobTitle = jobTitle
            contact.notes = notes
            contact.updatedAt = Date()
        } else {
            let contact = Contact(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                phoneCountryCode: selectedCountryCode.code,
                phoneNumber: phoneNumber,
                reference: reference,
                email: email,
                city: city,
                state: state,
                country: country,
                birthday: birthday,
                company: company,
                jobTitle: jobTitle,
                notes: notes
            )
            
            modelContext.insert(contact)
        }
        dismiss()
    }
}

#Preview {
    AddContactSheet()
        .modelContainer(for: Contact.self, inMemory: true)
}
