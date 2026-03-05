import SwiftUI
import SwiftData

struct LogInteractionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Contact.name) private var contacts: [Contact]
    @Query private var manualReminders: [ManualReminder]
    
    @State private var selectedContact: Contact?
    @State private var interactionDate = Date()
    @State private var interactionType: InteractionType = .inPerson
    @State private var notes: String = ""
    @State private var scrollID: Int?
    
    private let interactionTypes = InteractionType.allCases
    private let infiniteMultiplier = 50
    
    private let initialContact: Contact?
    
    init(preSelectedContact: Contact? = nil) {
        self.initialContact = preSelectedContact
        _selectedContact = State(initialValue: preSelectedContact)
    }
    
    var body: some View {
        NavigationStack {
            contentView
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
        }
        .onAppear {
            if let initial = initialContact {
                selectedContact = initial
            }
            // Initialize scroll position to the middle set
            let middleSetIndex = infiniteMultiplier / 2
            let typeIndex = interactionTypes.firstIndex(of: interactionType) ?? 0
            scrollID = (middleSetIndex * interactionTypes.count) + typeIndex
        }
        .onChange(of: scrollID) { _, newValue in
            if let index = newValue {
                let typeIndex = index % interactionTypes.count
                let newType = interactionTypes[typeIndex]
                if interactionType != newType {
                    withAnimation {
                        interactionType = newType
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if let selected = selectedContact {
            formContent(for: selected)
        } else {
            contactListContent
                .navigationTitle("Log Interaction")
        }
    }
    
    private var contactListContent: some View {
        List {
            if contacts.isEmpty {
                ContentUnavailableView("No Contacts", systemImage: "person.2.slash", description: Text("Add contacts first to log interactions."))
            } else {
                ForEach(Priority.allCases, id: \.self) { priority in
                    let priorityContacts = contacts.filter { $0.priority == priority }
                    if !priorityContacts.isEmpty {
                        Section(priority.rawValue) {
                            ForEach(priorityContacts) { contact in
                                contactRow(for: contact)
                            }
                        }
                    }
                }
                
                if !noPriorityContacts.isEmpty {
                    Section("No Priority") {
                        ForEach(noPriorityContacts) { contact in
                            contactRow(for: contact)
                        }
                    }
                }
            }
        }
    }
    
    private func formContent(for contact: Contact) -> some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 6) {
                Text("Log Interaction")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(1)
                
                Text(contact.name)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding(.top)
            
            ScrollView {
                VStack(spacing: 30) {
                    // Date
                    HStack {
                        Text("Date")
                            .font(.headline)
                        Spacer()
                        DatePicker("", selection: $interactionDate, displayedComponents: .date)
                            .labelsHidden()
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal)
                    
                    // Interaction Type Picker
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Interaction Type")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 0) {
                                ForEach(0..<(interactionTypes.count * infiniteMultiplier), id: \.self) { index in
                                    let type = interactionTypes[index % interactionTypes.count]
                                    VStack(spacing: 12) {
                                        Image(systemName: type.icon)
                                            .font(.system(size: 28, weight: .semibold))
                                            .foregroundStyle(interactionType == type ? .white : .primary)
                                            .frame(width: 64, height: 64)
                                            .background(
                                                Circle()
                                                    .fill(interactionType == type ? Color.accentColor : Color(.secondarySystemBackground))
                                            )
                                            .shadow(color: interactionType == type ? Color.accentColor.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                                        
                                        Text(type.rawValue)
                                            .font(.subheadline)
                                            .fontWeight(interactionType == type ? .semibold : .regular)
                                            .foregroundStyle(interactionType == type ? .primary : .secondary)
                                    }
                                    .containerRelativeFrame(.horizontal, count: 3, spacing: 0)
                                    .id(index)
                                    .onTapGesture {
                                        withAnimation {
                                            scrollID = index
                                        }
                                    }
                                }
                            }
                            .scrollTargetLayout()
                        }
                        .scrollTargetBehavior(.viewAligned)
                        .scrollPosition(id: $scrollID, anchor: .center)
                    }
                    
                    // Notes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notes (optional)")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        TextField("Add details about the interaction...", text: $notes, axis: .vertical)
                            .lineLimit(4...8)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        // AI Writing Assistant
                        AIWritingAssistantView(text: $notes)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .scrollDismissesKeyboard(.interactively)
            
            // Save Button
            Button(action: saveInteraction) {
                Text("Save Interaction")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.accentColor)
                    .clipShape(Capsule())
                    .shadow(color: Color.accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    private var noPriorityContacts: [Contact] {
        contacts.filter { $0.priority == nil }
    }
    
    private func contactRow(for contact: Contact) -> some View {
        Button {
            selectedContact = contact
        } label: {
            HStack {
                Text(contact.name)
                Spacer()
                if let date = contact.lastContacted {
                    Text(date, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .foregroundStyle(.primary)
    }
    
    private func saveInteraction() {
        guard let contact = selectedContact else { return }
        
        // Create new Interaction object
        let interaction = Interaction(
            date: interactionDate,
            notes: notes,
            interactionType: interactionType,
            contact: contact
        )
        
        modelContext.insert(interaction)
        
        // Find and fulfill any pending manual reminders for this contact
        let pendingReminders = manualReminders.filter {
            $0.contact.id == contact.id && $0.status == .pending
        }
        let fulfilledReminder = pendingReminders.first
        fulfilledReminder?.markCompleted(interactionId: interaction.id)
        
        // Handle repeat interval: spawn next occurrence
        if let fulfilled = fulfilledReminder, fulfilled.repeatInterval != .never {
            _ = ConnectionHealthEngine.createNextOccurrence(from: fulfilled, context: modelContext)
        }
        
        // Use ConnectionHealthEngine for unified scoring and rescheduling
        ConnectionHealthEngine.recordInteraction(
            contact: contact,
            interaction: interaction,
            manualReminder: fulfilledReminder,
            currentDate: interactionDate
        )
        
        dismiss()
    }
}
