import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                HomeScreen()
            }
            
            Tab("Contacts", systemImage: "person.2.fill") {
                ContactsScreen()
            }
            
            Tab("Reminders", systemImage: "bell.fill") {
                RemindersScreen()
            }
            
            Tab("Insights", systemImage: "chart.bar.fill") {
                InsightsScreen()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Contact.self, inMemory: true)
}

