import SwiftUI
import SwiftData

struct TodayAndWeeklyCard: View {
    @Environment(\.colorScheme) private var colorScheme
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
            let contactedThisWeek = lastInteraction >= startOfWeek && lastInteraction <= endOfWeek
            return contactedThisWeek
        }.count
    }
    
    private var totalDueThisWeek: Int {
        let remaining = weeklyReminders.values.reduce(0, +)
        return completedThisWeek + remaining
    }
    
    private var progressPercentage: Double {
        guard totalDueThisWeek > 0 else { return 1.0 }
        return Double(completedThisWeek) / Double(totalDueThisWeek)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // This Week Section
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(AppColors.mutedBlue)
                Text("THIS WEEK")
                    .font(.custom(AppFontName.workSansMedium, size: 14))
                    .foregroundStyle(colorScheme == .dark ? AppColors.textPrimary : .primary)
            }
            
            // Daily breakdown
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text("Mon: \(weeklyReminders["Mon"] ?? 0)")
                    Text("·").foregroundStyle(colorScheme == .dark ? AppColors.textTertiary : .secondary)
                    Text("Tue: \(weeklyReminders["Tue"] ?? 0)")
                    Text("·").foregroundStyle(colorScheme == .dark ? AppColors.textTertiary : .secondary)
                    Text("Wed: \(weeklyReminders["Wed"] ?? 0)")
                }
                .font(.custom(AppFontName.workSansRegular, size: 13))
                
                HStack(spacing: 4) {
                    Text("Thu: \(weeklyReminders["Thu"] ?? 0)")
                    Text("·").foregroundStyle(colorScheme == .dark ? AppColors.textTertiary : .secondary)
                    Text("Fri: \(weeklyReminders["Fri"] ?? 0)")
                    Text("·").foregroundStyle(colorScheme == .dark ? AppColors.textTertiary : .secondary)
                    Text("Weekend: \(weeklyReminders["Weekend"] ?? 0)")
                }
                .font(.custom(AppFontName.workSansRegular, size: 13))
            }
            .foregroundStyle(colorScheme == .dark ? AppColors.textSecondary : .secondary)
            
            // Progress
            VStack(alignment: .leading, spacing: 6) {
                Text("Progress: \(completedThisWeek)/\(totalDueThisWeek) completed")
                    .font(.custom(AppFontName.workSansRegular, size: 13))
                    .foregroundStyle(colorScheme == .dark ? AppColors.textSecondary : .secondary)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 4)
                            .fill(colorScheme == .dark ? AppColors.deepNavy : Color.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        // Progress fill
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppGradients.blueGlow)
                            .frame(width: geometry.size.width * progressPercentage, height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(16)
        .background(colorScheme == .dark ? AppColors.charcoal : Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
    }
}
