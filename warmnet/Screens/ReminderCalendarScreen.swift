import SwiftUI
import SwiftData

struct ReminderCalendarScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var contacts: [Contact]
    
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var expandedMonth: Int?
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var months: [Int] {
        Array(1...12)
    }
    
    private var availableYears: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((currentYear - 5)...(currentYear + 5))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Year display
                HStack {
                    Spacer()
                    
                    Text(String(format: "%d", selectedYear))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                .padding()
                .background(Color(uiColor: .systemBackground))
                
                // Month calendar view
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(months, id: \.self) { month in
                            MonthRowView(
                                month: month,
                                year: selectedYear,
                                contacts: contacts,
                                isExpanded: expandedMonth == month,
                                onTap: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        if expandedMonth == month {
                                            expandedMonth = nil
                                        } else {
                                            expandedMonth = month
                                        }
                                    }
                                }
                            )
                        }
                    }
                    .padding()
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
                
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        ForEach(availableYears, id: \.self) { year in
                            Button(String(format: "%d", year)) {
                                selectedYear = year
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
}

// MARK: - Month Row View
struct MonthRowView: View {
    let month: Int
    let year: Int
    let contacts: [Contact]
    let isExpanded: Bool
    let onTap: () -> Void
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var monthName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let date = calendar.date(from: DateComponents(year: year, month: month, day: 1)) ?? Date()
        return dateFormatter.string(from: date)
    }
    
    private var monthInterval: DateInterval? {
        guard let date = calendar.date(from: DateComponents(year: year, month: month, day: 1)) else {
            return nil
        }
        return calendar.dateInterval(of: .month, for: date)
    }
    
    private var contactsDueThisMonth: [Contact] {
        guard let interval = monthInterval else { return [] }
        
        return contacts.filter { contact in
            let reminderDate = contact.nextReminderDate
            return reminderDate >= interval.start && reminderDate < interval.end
        }.sorted { $0.nextReminderDate < $1.nextReminderDate }
    }
    
    private var weeksInMonth: [DateInterval] {
        guard let monthStart = monthInterval?.start,
              let monthEnd = monthInterval?.end else {
            return []
        }
        
        var weeks: [DateInterval] = []
        var currentDate = monthStart
        
        while currentDate < monthEnd {
            if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: currentDate) {
                weeks.append(weekInterval)
                currentDate = weekInterval.end
            } else {
                break
            }
        }
        
        return weeks
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Month header - always visible
            Button(action: onTap) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(monthName)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        
                        Text("\(contactsDueThisMonth.count) reminders")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            
            // Expanded weeks view
            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(Array(weeksInMonth.enumerated()), id: \.offset) { index, weekInterval in
                        WeekRowView(
                            weekInterval: weekInterval,
                            contacts: contactsDueThisMonth,
                            weekNumber: index + 1
                        )
                    }
                }
                .padding(.top, 8)
            }
        }
    }
}

// MARK: - Week Row View
struct WeekRowView: View {
    let weekInterval: DateInterval
    let contacts: [Contact]
    let weekNumber: Int
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var weekRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        let start = formatter.string(from: weekInterval.start)
        let end = formatter.string(from: calendar.date(byAdding: .day, value: -1, to: weekInterval.end) ?? weekInterval.end)
        
        return "\(start) - \(end)"
    }
    
    private var contactsDueThisWeek: [Contact] {
        contacts.filter { contact in
            let reminderDate = contact.nextReminderDate
            return reminderDate >= weekInterval.start && reminderDate < weekInterval.end
        }.sorted { $0.nextReminderDate < $1.nextReminderDate }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Week header
            HStack {
                Text("Week \(weekNumber)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                Text("·")
                    .foregroundStyle(.secondary)
                
                Text(weekRangeText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("\(contactsDueThisWeek.count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(contactsDueThisWeek.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(12)
            }
            
            // Contacts for this week
            if !contactsDueThisWeek.isEmpty {
                VStack(spacing: 6) {
                    ForEach(contactsDueThisWeek) { contact in
                        NavigationLink(destination: ContactDetailScreen(contact: contact)) {
                            HStack(spacing: 10) {
                                AvatarView(name: contact.name, size: 36)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(contact.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primary)
                                    
                                    Text(dueDateText(for: contact))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                if contact.isOverdue {
                                    Text("Overdue")
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 3)
                                        .background(Color("Red-app").opacity(0.2))
                                        .foregroundStyle(Color("Red-app"))
                                        .cornerRadius(4)
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color(uiColor: .tertiarySystemGroupedBackground))
                            .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.5))
        .cornerRadius(10)
    }
    
    private func dueDateText(for contact: Contact) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: contact.nextReminderDate)
    }
}
