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
            ManualReminder.self,
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
                .accentColor(AppColors.mutedBlue)
                .tint(AppColors.mutedBlue)
                .environment(\.typography, .warmnet)
                .environment(\.font, Typography.warmnet.body.font)
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
            
            // Apply connection health decay on app launch
            applyConnectionHealthDecay(context: context)
            
            // Run migration for connection health if needed
            MigrationHelper.migrateConnectionHealth(modelContext: context)
        }
    }
    
    /// Apply passive decay to all contacts' connection scores
    private func applyConnectionHealthDecay(context: ModelContext) {
        let descriptor = FetchDescriptor<Contact>()
        if let contacts = try? context.fetch(descriptor) {
            ConnectionHealthEngine.applyDecay(to: contacts)
            try? context.save()
        }
    }
    
    /// Handle notification action responses
    private func handleNotificationAction(_ action: String, userInfo: [AnyHashable: Any], context: ModelContext) {
        guard let city = userInfo["city"] as? String else { return }
        
        switch action {
        case NotificationManager.NotificationAction.viewContacts.identifier:
            break
            
        case NotificationManager.NotificationAction.snooze.identifier:
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
            
        case NotificationManager.NotificationAction.dismiss.identifier:
            break
            
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
