import SwiftUI

struct ReminderContactRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let contact: Contact
    
    var body: some View {
        HStack(spacing: 12) {
            AvatarView(name: contact.name, size: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(contact.name)
                        .font(.custom(AppFontName.workSansMedium, size: 16))
                        .foregroundStyle(colorScheme == .dark ? AppColors.textPrimary : .primary)
                    
                    Circle()
                        .fill((contact.priority ?? .broaderNetwork).color)
                        .frame(width: 8, height: 8)
                }
                
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
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(cardBackgroundColor)
        )
    }
    
    private var cardBackgroundColor: Color {
        colorScheme == .dark
            ? AppColors.charcoal
            : Color(uiColor: .secondarySystemGroupedBackground)
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

#Preview {
    let overdueContact = Contact(
        name: "Sarah Johnson",
        priority: .innerCircle,
        nextTouchDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())
    )
    
    let upcomingContact = Contact(
        name: "Mike Chen",
        priority: .keyRelationships,
        nextTouchDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())
    )
    
    return VStack(spacing: 12) {
        ReminderContactRow(contact: overdueContact)
        ReminderContactRow(contact: upcomingContact)
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
