import SwiftUI
import SwiftData

struct LogInteractionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Contact.name) private var contacts: [Contact]
    
    @State private var selectedContact: Contact?
    @State private var interactionDate = Date()
    
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
                        
                        Button("Save Interaction") {
                            selected.lastInteractionDate = interactionDate
                            dismiss()
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
}
