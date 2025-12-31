import SwiftUI

struct NotificationsSettingsScreen: View {
    var body: some View {
        ContentUnavailableView(
            "Notifications",
            systemImage: "bell.slash",
            description: Text("Notification settings are coming soon.")
        )
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        NotificationsSettingsScreen()
    }
}
