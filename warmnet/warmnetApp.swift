import SwiftUI
import SwiftData
import UserNotifications

@main
struct warmnetApp: App {
    @AppStorage("userTheme") private var userTheme: String = "System"
    
    /// Delegate for handling notification lifecycle
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Contact.self,
            PersonalisationData.self,
            Interaction.self,
            UserSettings.self,
            NotificationHistory.self,
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
                .onAppear {
                    setupLocationNotificationService()
                }
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
    
    /// Setup the location notification service with model context
    private func setupLocationNotificationService() {
        let context = sharedModelContainer.mainContext
        
        // Provide model context to location service
        Task { @MainActor in
            LocationNotificationService.shared.modelContext = context
            
            // Setup notification action handler
            NotificationManager.shared.onLocationNotificationAction = { action, userInfo in
                handleNotificationAction(action, userInfo: userInfo, context: context)
            }
            
            // Setup geofences if enabled
            let settings = UserSettings.getOrCreate(from: context)
            if settings.locationNotificationsEnabled {
                let descriptor = FetchDescriptor<Contact>()
                if let contacts = try? context.fetch(descriptor) {
                    await LocationNotificationService.shared.setupGeofences(for: contacts)
                }
            }
            
            // Cleanup old notification history
            NotificationHistory.cleanupOldRecords(context: context)
        }
    }
    
    /// Handle notification action responses
    private func handleNotificationAction(_ action: String, userInfo: [AnyHashable: Any], context: ModelContext) {
        guard let city = userInfo["city"] as? String else { return }
        
        switch action {
        case NotificationManager.NotificationAction.viewContacts.identifier:
            // TODO: Deep link to contacts filtered by city
            // This would require a navigation coordinator pattern
            print("warmnetApp: User wants to view contacts in \(city)")
            
        case NotificationManager.NotificationAction.snooze.identifier:
            // Snooze notifications for this city for 2 hours
            let snoozeUntil = Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()
            
            let descriptor = FetchDescriptor<NotificationHistory>(
                predicate: #Predicate { history in
                    history.city == city
                },
                sortBy: [SortDescriptor(\.notifiedAt, order: .reverse)]
            )
            
            if let histories = try? context.fetch(descriptor),
               let latestHistory = histories.first {
                latestHistory.snooze(until: snoozeUntil)
                try? context.save()
            }
            print("warmnetApp: Snoozed notifications for \(city) until \(snoozeUntil)")
            
        case NotificationManager.NotificationAction.dismiss.identifier:
            print("warmnetApp: User dismissed notification for \(city)")
            
        default:
            break
        }
    }
}

// MARK: - App Delegate

/// App delegate for setting up notification center delegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Set notification center delegate
        UNUserNotificationCenter.current().delegate = NotificationManager.shared
        return true
    }
}
