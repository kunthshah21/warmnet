import SwiftUI
import SwiftData

@main
struct warmnetApp: App {
    @AppStorage("userTheme") private var userTheme: String = "System"

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Contact.self,
            PersonalisationData.self,
            Interaction.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(selectedScheme)
        }
        .modelContainer(sharedModelContainer)
    }

    private var selectedScheme: ColorScheme? {
        switch userTheme {
        case "Light":
            return .light
        case "Dark":
            return .dark
        default:
            return nil
        }
    }
}
