import SwiftUI
import SwiftData

struct TodayAndWeeklyCard: View {
    let contacts: [Contact]
    let onLogInteraction: (Contact) -> Void
    
    @State private var showCalendar = false
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var startOfWeek: Date {
        calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
    }
    
    private var endOfWeek: Date {
        calendar.dateInterval(of: .weekOfYear, for: Date())?.end ?? Date()
    }
    
    private var todaysGoals: [Contact] {
        let today = Calendar.current.startOfDay(for: Date())
        return contacts.filter { contact in
            let due = Calendar.current.startOfDay(for: contact.nextReminderDate)
            return due <= today
        }.sorted { $0.nextReminderDate < $1.nextReminderDate }
    }
    
    private var weeklyReminders: [String: Int] {
        var counts: [String: Int] = [
            "Mon": 0, "Tue": 0, "Wed": 0, "Thu": 0, "Fri": 0, "Weekend": 0
        ]
        
        for contact in contacts {
            let reminderDate = contact.nextReminderDate
            
            // Count if due this week or earlier (overdue counts too)
            if reminderDate <= endOfWeek {
                // Determine which day to show it on
                let displayDate = reminderDate < startOfWeek ? startOfWeek : reminderDate
                let weekday = calendar.component(.weekday, from: displayDate)
                
                switch weekday {
                case 2: counts["Mon"]! += 1
                case 3: counts["Tue"]! += 1
                case 4: counts["Wed"]! += 1
                case 5: counts["Thu"]! += 1
                case 6: counts["Fri"]! += 1
                case 1, 7: counts["Weekend"]! += 1
                default: break
                }
            }
        }
        
        return counts
    }
    
    private var completedThisWeek: Int {
        contacts.filter { contact in
            guard let lastInteraction = contact.lastContacted else { return false }
            let wasDue = contact.nextReminderDate <= endOfWeek
            let contactedThisWeek = lastInteraction >= startOfWeek && lastInteraction <= endOfWeek
            return wasDue && contactedThisWeek
        }.count
    }
    
    private var totalDueThisWeek: Int {
        weeklyReminders.values.reduce(0, +)
    }
    
    private var progressPercentage: Double {
        guard totalDueThisWeek > 0 else { return 1.0 }
        return Double(completedThisWeek) / Double(totalDueThisWeek)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Today's Network Goals Section
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(Color("Primary"))
                Text("Today's Network Goals")
                    .font(.headline)
                Spacer()
            }
            
            if todaysGoals.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title2)
                    Text("All caught up for today!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 8)
            } else {
                VStack(spacing: 4) {
                    ForEach(todaysGoals) { contact in
                        Button {
                            onLogInteraction(contact)
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .strokeBorder(Color.secondary.opacity(0.6), lineWidth: 1.5)
                                        .background(Circle().fill(Color.clear))
                                    Image(systemName: "plus")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(Color.secondary)
                                }
                                .frame(width: 20, height: 20)

                                Text(contact.name)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 8)
                        }
                    }
                }
            }
            
            // Divider between sections
            Divider()
                .padding(.vertical, 4)
            
            // This Week Section
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.blue)
                Text("THIS WEEK")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            
            // Daily breakdown
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text("Mon: \(weeklyReminders["Mon"] ?? 0)")
                    Text("·").foregroundStyle(.secondary)
                    Text("Tue: \(weeklyReminders["Tue"] ?? 0)")
                    Text("·").foregroundStyle(.secondary)
                    Text("Wed: \(weeklyReminders["Wed"] ?? 0)")
                }
                .font(.subheadline)
                
                HStack(spacing: 4) {
                    Text("Thu: \(weeklyReminders["Thu"] ?? 0)")
                    Text("·").foregroundStyle(.secondary)
                    Text("Fri: \(weeklyReminders["Fri"] ?? 0)")
                    Text("·").foregroundStyle(.secondary)
                    Text("Weekend: \(weeklyReminders["Weekend"] ?? 0)")
                }
                .font(.subheadline)
            }
            .foregroundStyle(.secondary)
            
            // Progress
            VStack(alignment: .leading, spacing: 6) {
                Text("Progress: \(completedThisWeek)/\(totalDueThisWeek) completed")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        // Progress fill
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .blue.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progressPercentage, height: 8)
                    }
                }
                .frame(height: 8)
            }
            
            // View calendar button
            Button {
                showCalendar = true
            } label: {
                HStack {
                    Text("View Full Calendar")
                        .font(.subheadline.weight(.medium))
                    Image(systemName: "arrow.right")
                        .font(.caption)
                }
                .foregroundStyle(.blue)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .sheet(isPresented: $showCalendar) {
            ReminderCalendarScreen()
        }
    }
}
