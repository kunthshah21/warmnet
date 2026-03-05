import SwiftUI
import SwiftData

struct RemindersScreen: View {
    @Environment(\.colorScheme) private var colorScheme
    @Query private var contacts: [Contact]
    @Query(sort: \ManualReminder.reminderDate) private var manualReminders: [ManualReminder]
    
    @State private var showAddReminderSheet = false
    
    private var pendingManualReminders: [ManualReminder] {
        manualReminders.filter { $0.status == .pending }
    }
    
    private var pendingReminderContactIDs: Set<UUID> {
        Set(pendingManualReminders.map { $0.contact.id })
    }
    
    private var automaticReminders: [Contact] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let weekFromNow = calendar.date(byAdding: .day, value: 7, to: today) else {
            return []
        }
        
        return contacts
            .filter { contact in
                let dueDate = calendar.startOfDay(for: contact.nextReminderDate)
                let isInRange = dueDate <= weekFromNow
                let hasPendingReminder = pendingReminderContactIDs.contains(contact.id)
                return isInRange && !hasPendingReminder
            }
            .sorted { $0.nextReminderDate < $1.nextReminderDate }
    }
    
    private var hasAnyReminders: Bool {
        !pendingManualReminders.isEmpty || !automaticReminders.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerRow
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom, 8)
                
                if hasAnyReminders {
                    remindersList
                } else {
                    ReminderEmptyStateView(onAddReminder: {
                        showAddReminderSheet = true
                    })
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showAddReminderSheet) {
                AddReminderSheet()
            }
        }
    }
    
    private var headerRow: some View {
        HStack {
            Text("Reminders")
                .font(.custom(AppFontName.workSansMedium, size: 32))
                .fontWeight(.bold)
            
            Spacer()
            
            Button {
                showAddReminderSheet = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.mutedBlue)
            }
        }
    }
    
    private var remindersList: some View {
        ScrollView {
            VStack(spacing: 24) {
                addReminderButton
                    .padding(.top, 8)
                
                if !pendingManualReminders.isEmpty {
                    remindersSetSection
                }
                
                if !pendingManualReminders.isEmpty && !automaticReminders.isEmpty {
                    Divider()
                }
                
                if !automaticReminders.isEmpty {
                    automaticRemindersSection
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .scrollContentBackground(.visible)
    }
    
    private var remindersSetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Network Reminders")
                    .font(.custom(AppFontName.workSansMedium, size: 20))
                    .foregroundStyle(.primary)
                Text("Reminders you've created")
                    .font(.custom(AppFontName.workSansRegular, size: 14))
                    .foregroundStyle(.secondary)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(pendingManualReminders) { reminder in
                    NavigationLink(destination: ContactDetailScreen(contact: reminder.contact)) {
                        ReminderContactRow(contact: reminder.contact)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var automaticRemindersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Suggested Reminders")
                    .font(.custom(AppFontName.workSansMedium, size: 20))
                    .foregroundStyle(.primary)
                Text("Based on your contact frequency")
                    .font(.custom(AppFontName.workSansRegular, size: 14))
                    .foregroundStyle(.secondary)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(automaticReminders) { contact in
                    NavigationLink(destination: ContactDetailScreen(contact: contact)) {
                        ReminderContactRow(contact: contact)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var addReminderButton: some View {
        Button {
            showAddReminderSheet = true
        } label: {
            Text("Add Network Reminder")
                .font(.custom(AppFontName.workSansMedium, size: 16))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(Color(red: 0.09, green: 0.09, blue: 0.11))
                .cornerRadius(100)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, ManualReminder.self, configurations: config)
    
    let today = Date()
    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
    let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: today)!
    
    let sampleContacts = [
        Contact(name: "Sarah Johnson", priority: .innerCircle, nextTouchDate: yesterday),
        Contact(name: "Mike Chen", priority: .keyRelationships, nextTouchDate: today),
        Contact(name: "Emma Wilson", priority: .broaderNetwork, nextTouchDate: nextWeek)
    ]
    
    for contact in sampleContacts {
        container.mainContext.insert(contact)
    }
    
    let manualReminder = ManualReminder(
        contact: sampleContacts[0],
        reminderDate: today,
        note: "Catch up about the project",
        hasDate: true
    )
    container.mainContext.insert(manualReminder)
    
    return RemindersScreen()
        .modelContainer(container)
}
