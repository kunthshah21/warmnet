import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: 0) {
                HomeScreen()
            }

            Tab("Reminders", systemImage: "bell.fill", value: 1) {
                RemindersScreen()
            }

            Tab("Contacts", systemImage: "person.2.fill", value: 2) {
                ContactsScreen()
            }

            Tab("Insights", systemImage: "chart.bar.fill", value: 3) {
                InsightsScreen()
            }
        }
        .sensoryFeedback(.selection, trigger: selectedTab)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Contact.self, inMemory: true)
}

