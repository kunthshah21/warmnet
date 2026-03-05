import SwiftUI

struct ReminderEmptyStateView: View {
    let onAddReminder: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "bell.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("No Reminders Scheduled")
                .font(.custom(AppFontName.workSansMedium, size: 18))
                .foregroundStyle(.secondary)
            
            Text("Schedule reminders to stay in touch with your network")
                .font(.custom(AppFontName.overpassVariable, size: 14))
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button {
                HapticManager.impact(.light)
                onAddReminder()
            } label: {
                Text("Add Network Reminder")
                    .font(.custom(AppFontName.workSansMedium, size: 16))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .frame(height: 52)
                    .background(Color(red: 0.09, green: 0.09, blue: 0.11))
                    .cornerRadius(100)
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ReminderEmptyStateView(onAddReminder: {})
}
