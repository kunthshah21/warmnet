import SwiftUI
import SwiftData

struct ContactDetailScreen: View {
    @Bindable var contact: Contact
    @State private var showEditSheet = false
    @State private var showHistory = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Contact Info
                if hasContactInfo {
                    contactInfoSection
                }
                
                // Location
                if !contact.fullLocation.isEmpty {
                    locationSection
                }
                
                // Work & Personal
                if hasWorkOrPersonalInfo {
                    workAndPersonalSection
                }
                
                // Notes
                if !contact.notes.isEmpty {
                    notesSection
                }
                
                // Reference
                if !contact.reference.isEmpty {
                    referenceSection
                }
                
                // Interaction History
                interactionHistorySection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .scrollContentBackground(.visible)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            AddContactSheet(contactToEdit: contact)
        }
    }
    
    // MARK: - Computed Properties
    
    private var hasContactInfo: Bool {
        !contact.phoneNumber.isEmpty || !contact.email.isEmpty
    }
    
    private var hasWorkOrPersonalInfo: Bool {
        !contact.company.isEmpty || !contact.jobTitle.isEmpty || contact.birthday != nil
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            AvatarView(name: contact.name, size: 100)
            
            VStack(spacing: 4) {
                Text(contact.name)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                
                if !contact.jobTitle.isEmpty {
                    Text(contact.jobTitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                if !contact.company.isEmpty {
                    Text(contact.company)
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }
    
    private var contactInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Contact Info")
            
            VStack(spacing: 0) {
                if !contact.phoneNumber.isEmpty {
                    detailRow(icon: "phone.fill", title: "Phone", value: contact.fullPhoneNumber)
                }
                
                if !contact.phoneNumber.isEmpty && !contact.email.isEmpty {
                    Divider()
                        .padding(.leading, 44)
                }
                
                if !contact.email.isEmpty {
                    detailRow(icon: "envelope.fill", title: "Email", value: contact.email)
                }
            }
            .background(cardBackground)
        }
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Location")
            
            VStack(spacing: 0) {
                detailRow(icon: "mappin.circle.fill", title: "Address", value: contact.fullLocation)
            }
            .background(cardBackground)
        }
    }
    
    private var workAndPersonalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Personal Details")
            
            VStack(spacing: 0) {
                if !contact.company.isEmpty {
                    detailRow(icon: "building.2.fill", title: "Company", value: contact.company)
                }
                
                if !contact.company.isEmpty && !contact.jobTitle.isEmpty {
                    Divider()
                        .padding(.leading, 44)
                }
                
                if !contact.jobTitle.isEmpty {
                    detailRow(icon: "briefcase.fill", title: "Job Title", value: contact.jobTitle)
                }
                
                if (!contact.company.isEmpty || !contact.jobTitle.isEmpty) && contact.birthday != nil {
                    Divider()
                        .padding(.leading, 44)
                }
                
                if let birthday = contact.birthday {
                    detailRow(icon: "gift.fill", title: "Birthday", value: birthday.formatted(date: .long, time: .omitted))
                }
            }
            .background(cardBackground)
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Notes")
            
            Text(contact.notes)
                .font(.body)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(cardBackground)
        }
    }
    
    private var referenceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Reference")
            
            HStack(spacing: 12) {
                Image(systemName: "person.text.rectangle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Reference")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(contact.reference)
                        .font(.body)
                        .foregroundStyle(.primary)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
        }
    }
    
    private var interactionHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                sectionHeader("Interaction History")
                
                Spacer()
                
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showHistory.toggle()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(showHistory ? "Hide" : "Show")
                            .font(.subheadline.weight(.medium))
                        Image(systemName: showHistory ? "chevron.up" : "chevron.down")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(.blue)
                }
            }
            
            if showHistory {
                VStack(spacing: 0) {
                    if contact.interactions.isEmpty {
                        HStack(spacing: 12) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.secondary)
                                .frame(width: 24)
                            
                            Text("No interactions logged yet")
                                .font(.body)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                        }
                        .padding(16)
                    } else {
                        ForEach(contact.interactions.sorted(by: { $0.date > $1.date }), id: \.id) { interaction in
                            VStack(spacing: 0) {
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: interaction.interactionType.icon)
                                        .font(.system(size: 18))
                                        .foregroundStyle(colorForType(interaction.interactionType.color))
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(interaction.interactionType.rawValue)
                                                .font(.subheadline.weight(.medium))
                                                .foregroundStyle(.primary)
                                            
                                            Spacer()
                                            
                                            Text(interaction.date, style: .date)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        if !interaction.notes.isEmpty {
                                            Text(interaction.notes)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                                .lineLimit(3)
                                                .padding(.top, 2)
                                        }
                                    }
                                }
                                .padding(16)
                                
                                if interaction.id != contact.interactions.sorted(by: { $0.date > $1.date }).last?.id {
                                    Divider()
                                        .padding(.leading, 52)
                                }
                            }
                        }
                    }
                }
                .background(cardBackground)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    // MARK: - Helpers
    
    private func colorForType(_ colorName: String) -> Color {
        switch colorName {
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "orange": return .orange
        case "mint": return .mint
        default: return .blue
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.secondary)
            .padding(.leading, 4)
    }
    
    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.body)
                    .foregroundStyle(.primary)
            }
            
            Spacer()
        }
        .padding(16)
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color(.systemBackground))
            .shadow(color: .black.opacity(0.03), radius: 8, y: 2)
    }
}

#Preview {
    NavigationStack {
        ContactDetailScreen(contact: Contact(
            name: "John Doe",
            phoneCountryCode: "+1",
            phoneNumber: "555-0123",
            reference: "Met at conference",
            email: "john@example.com",
            city: "San Francisco",
            state: "CA",
            country: "USA",
            company: "Tech Corp",
            jobTitle: "Developer",
            notes: "Great guy, loves coffee."
        ))
    }
}
