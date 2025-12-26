import SwiftUI
import SwiftData

struct LogInteractionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Contact.name) private var contacts: [Contact]
    
    @State private var selectedContact: Contact?
    @State private var interactionDate = Date()
    @State private var interactionType: InteractionType = .inPerson
    @State private var notes: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                if let selected = selectedContact {
                    Section("Log Interaction") {
                        HStack {
                            Text("Selected:")
                            Text(selected.name).bold()
                            Spacer()
                            Button("Change") {
                                selectedContact = nil
                            }
                        }
                        
                        DatePicker("Date", selection: $interactionDate, displayedComponents: .date)
                        
                        Picker("Interaction Type", selection: $interactionType) {
                            ForEach(InteractionType.allCases, id: \.self) { type in
                                Label(type.rawValue, systemImage: type.icon)
                                    .tag(type)
                            }
                        }
                        
                        TextField("Notes (optional)", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                        
                        Button("Save Interaction") {
                            saveInteraction()
                        }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    ForEach(Priority.allCases, id: \.self) { priority in
                        let priorityContacts = contacts.filter { $0.priority == priority }
                        if !priorityContacts.isEmpty {
                            Section(priority.rawValue) {
                                ForEach(priorityContacts) { contact in
                                    Button {
                                        selectedContact = contact
                                    } label: {
                                        HStack {
                                            Text(contact.name)
                                            Spacer()
                                            if let date = contact.lastInteractionDate {
                                                Text(date, style: .date)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                    }
                                    .foregroundStyle(.primary)
                                }
                            }
                        }
                    }
                    
                    let noPriorityContacts = contacts.filter { $0.priority == nil }
                    if !noPriorityContacts.isEmpty {
                        Section("No Priority") {
                            ForEach(noPriorityContacts) { contact in
                                Button {
                                    selectedContact = contact
                                } label: {
                                    HStack {
                                        Text(contact.name)
                                        Spacer()
                                        if let date = contact.lastInteractionDate {
                                            Text(date, style: .date)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .foregroundStyle(.primary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Log Interaction")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
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
        
        // Update lastInteractionDate for backward compatibility
        contact.lastInteractionDate = interactionDate
        contact.updatedAt = Date()
        
        dismiss()
    }
}
