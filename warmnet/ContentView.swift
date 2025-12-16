import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        HomeScreen()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Contact.self, inMemory: true)
}
