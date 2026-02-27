import SwiftUI
import SwiftData

struct RemindersScreen: View {
    @Environment(\.colorScheme) private var colorScheme
    @Query private var contacts: [Contact]
    
    @State private var showAddReminderSheet = false
    
    private var scheduledReminders: [Contact] {
        contacts
            .filter { $0.nextTouchDate != nil }
            .sorted { $0.nextReminderDate < $1.nextReminderDate }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerRow
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom, 8)
                
                if scheduledReminders.isEmpty {
                    ReminderEmptyStateView(onAddReminder: {
                        showAddReminderSheet = true
                    })
                } else {
                    remindersList
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
            VStack(spacing: 16) {
                addReminderButton
                    .padding(.top, 8)
                
                LazyVStack(spacing: 12) {
                    ForEach(scheduledReminders) { contact in
                        NavigationLink(destination: ContactDetailScreen(contact: contact)) {
                            ReminderContactRow(contact: contact)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .scrollContentBackground(.visible)
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
    let container = try! ModelContainer(for: Contact.self, configurations: config)
    
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
    
    return RemindersScreen()
        .modelContainer(container)
}
