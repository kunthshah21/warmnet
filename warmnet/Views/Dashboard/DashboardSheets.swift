//
//  DashboardSheets.swift
//  warmnet
//
//  Created on 14/01/2026.
//

import SwiftUI
import SwiftData

// MARK: - Add Reminder Sheet

struct AddReminderSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var contacts: [Contact]
    
    @State private var selectedContact: Contact?
    @State private var reminderDate = Date()
    @State private var reminderNote = ""
    @State private var searchText = ""
    
    private var filteredContacts: [Contact] {
        if searchText.isEmpty {
            return contacts.sorted { $0.name < $1.name }
        }
        return contacts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search contacts...", text: $searchText)
                }
                .padding(12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top)
                
                if let contact = selectedContact {
                    // Selected contact and reminder details
                    selectedContactView(contact)
                } else {
                    // Contact list
                    contactsList
                }
            }
            .navigationTitle("Add Network Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if selectedContact != nil {
                        Button("Save") {
                            saveReminder()
                            dismiss()
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
        }
    }
    
    private var contactsList: some View {
        List {
            ForEach(filteredContacts) { contact in
                Button {
                    withAnimation {
                        selectedContact = contact
                    }
                } label: {
                    HStack(spacing: 12) {
                        AvatarView(name: contact.name, size: 44)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(contact.name)
                                .font(.custom(AppFontName.workSansMedium, size: 16))
                                .foregroundStyle(.primary)
                            
                            if !contact.company.isEmpty {
                                Text(contact.company)
                                    .font(.custom(AppFontName.overpassVariable, size: 13))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.plain)
    }
    
    private func selectedContactView(_ contact: Contact) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Selected contact card
                HStack(spacing: 16) {
                    AvatarView(name: contact.name, size: 60)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(contact.name)
                            .font(.custom(AppFontName.workSansMedium, size: 18))
                        
                        if !contact.company.isEmpty {
                            Text(contact.company)
                                .font(.custom(AppFontName.overpassVariable, size: 14))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            selectedContact = nil
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Date picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reminder Date")
                        .font(.custom(AppFontName.workSansMedium, size: 16))
                    
                    DatePicker("", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.graphical)
                }
                
                // Note
                VStack(alignment: .leading, spacing: 12) {
                    Text("Note (optional)")
                        .font(.custom(AppFontName.workSansMedium, size: 16))
                    
                    TextField("Add a note about this reminder...", text: $reminderNote, axis: .vertical)
                        .lineLimit(3...6)
                        .padding(12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
    
    private func saveReminder() {
        guard let contact = selectedContact else { return }
        contact.nextTouchDate = reminderDate
        let manual = ManualReminder(contact: contact, reminderDate: reminderDate, note: reminderNote)
        modelContext.insert(manual)
    }
}

// MARK: - Notifications Sheet

struct NotificationsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let upcomingReminders: [Contact]
    let onContactTap: (Contact) -> Void
    
    var body: some View {
        NavigationStack {
            Group {
                if upcomingReminders.isEmpty {
                    emptyState
                } else {
                    remindersList
                }
            }
            .navigationTitle("Reminders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("No upcoming reminders")
                .font(.custom(AppFontName.workSansMedium, size: 18))
                .foregroundStyle(.secondary)
            
            Text("Your scheduled contacts will appear here")
                .font(.custom(AppFontName.overpassVariable, size: 14))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var remindersList: some View {
        List {
            Section {
                ForEach(upcomingReminders.prefix(10)) { contact in
                    Button {
                        onContactTap(contact)
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            AvatarView(name: contact.name, size: 40)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(contact.name)
                                    .font(.custom(AppFontName.workSansMedium, size: 16))
                                    .foregroundStyle(.primary)
                                
                                Text(formattedDate(contact.nextReminderDate))
                                    .font(.custom(AppFontName.workSansRegular, size: 13))
                                    .foregroundStyle(contact.isOverdue ? AppColors.accentRed : .secondary)
                            }
                            
                            Spacer()
                            
                            if contact.isOverdue {
                                Text("Overdue")
                                    .font(.custom(AppFontName.workSansRegular, size: 12))
                                    .foregroundStyle(AppColors.accentRed)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(AppColors.accentRed.opacity(0.15))
                                    )
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("Upcoming")
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}
