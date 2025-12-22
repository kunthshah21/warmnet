import SwiftUI
import SwiftData

enum CalendarViewType: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

struct ReminderCalendarScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var contacts: [Contact]
    
    @State private var selectedViewType: CalendarViewType = .week
    @State private var selectedDate = Date()
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // View type picker
                Picker("View Type", selection: $selectedViewType) {
                    ForEach(CalendarViewType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Calendar content based on view type
                ScrollView {
                    switch selectedViewType {
                    case .week:
                        WeekCalendarView(contacts: contacts, selectedDate: $selectedDate)
                    case .month:
                        MonthCalendarView(contacts: contacts, selectedDate: $selectedDate)
                    case .year:
                        YearCalendarView(contacts: contacts, selectedDate: $selectedDate)
                    }
                }
            }
            .navigationTitle("Reminder Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Week Calendar View
struct WeekCalendarView: View {
    let contacts: [Contact]
    @Binding var selectedDate: Date
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var weekInterval: DateInterval? {
        calendar.dateInterval(of: .weekOfYear, for: selectedDate)
    }
    
    private var contactsDueThisWeek: [Contact] {
        guard let interval = weekInterval else { return [] }
        
        return contacts.filter { contact in
            let reminderDate = contact.nextReminderDate
            return reminderDate >= interval.start && reminderDate < interval.end
        }.sorted { $0.nextReminderDate < $1.nextReminderDate }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Week navigation
            HStack {
                Button {
                    selectedDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
                } label: {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text(weekRangeText)
                    .font(.headline)
                
                Spacer()
                
                Button {
                    selectedDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            
            // Summary
            Text("\(contactsDueThisWeek.count) reminders this week")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // Contacts list
            if contactsDueThisWeek.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 48))
                        .foregroundStyle(.green)
                    Text("No reminders this week")
                        .font(.headline)
                    Text("You're all caught up!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 12) {
                    ForEach(contactsDueThisWeek) { contact in
                        ContactReminderCard(contact: contact)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    
    private var weekRangeText: String {
        guard let interval = weekInterval else { return "" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        let start = formatter.string(from: interval.start)
        let end = formatter.string(from: calendar.date(byAdding: .day, value: -1, to: interval.end) ?? interval.end)
        
        return "\(start) - \(end)"
    }
}

// MARK: - Month Calendar View
struct MonthCalendarView: View {
    let contacts: [Contact]
    @Binding var selectedDate: Date
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var monthInterval: DateInterval? {
        calendar.dateInterval(of: .month, for: selectedDate)
    }
    
    private var contactsDueThisMonth: [Contact] {
        guard let interval = monthInterval else { return [] }
        
        return contacts.filter { contact in
            let reminderDate = contact.nextReminderDate
            return reminderDate >= interval.start && reminderDate < interval.end
        }.sorted { $0.nextReminderDate < $1.nextReminderDate }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Month navigation
            HStack {
                Button {
                    selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
                } label: {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text(monthText)
                    .font(.headline)
                
                Spacer()
                
                Button {
                    selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            
            // Summary
            Text("\(contactsDueThisMonth.count) reminders this month")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // Contacts list
            if contactsDueThisMonth.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 48))
                        .foregroundStyle(.green)
                    Text("No reminders this month")
                        .font(.headline)
                    Text("You're all caught up!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 12) {
                    ForEach(contactsDueThisMonth) { contact in
                        ContactReminderCard(contact: contact)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    
    private var monthText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
}

// MARK: - Year Calendar View
struct YearCalendarView: View {
    let contacts: [Contact]
    @Binding var selectedDate: Date
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var yearInterval: DateInterval? {
        calendar.dateInterval(of: .year, for: selectedDate)
    }
    
    private var contactsDueThisYear: [Contact] {
        guard let interval = yearInterval else { return [] }
        
        return contacts.filter { contact in
            let reminderDate = contact.nextReminderDate
            return reminderDate >= interval.start && reminderDate < interval.end
        }.sorted { $0.nextReminderDate < $1.nextReminderDate }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Year navigation
            HStack {
                Button {
                    selectedDate = calendar.date(byAdding: .year, value: -1, to: selectedDate) ?? selectedDate
                } label: {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text(yearText)
                    .font(.headline)
                
                Spacer()
                
                Button {
                    selectedDate = calendar.date(byAdding: .year, value: 1, to: selectedDate) ?? selectedDate
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            
            // Summary
            Text("\(contactsDueThisYear.count) reminders this year")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // Contacts list
            if contactsDueThisYear.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 48))
                        .foregroundStyle(.green)
                    Text("No reminders this year")
                        .font(.headline)
                    Text("You're all caught up!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 12) {
                    ForEach(contactsDueThisYear) { contact in
                        ContactReminderCard(contact: contact)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    
    private var yearText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: selectedDate)
    }
}

// MARK: - Contact Reminder Card
struct ContactReminderCard: View {
    let contact: Contact
    
    private var dueDateText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: contact.nextReminderDate)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            AvatarView(name: contact.name, size: 48)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(contact.name)
                    .font(.headline)
                
                if let priority = contact.priority {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(priority.color)
                            .frame(width: 8, height: 8)
                        Text(priority.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Text("Due: \(dueDateText)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if contact.isOverdue {
                Text("Overdue")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.2))
                    .foregroundStyle(.red)
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}
