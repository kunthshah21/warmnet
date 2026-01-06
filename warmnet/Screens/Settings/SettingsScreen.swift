import SwiftUI
import SwiftData

struct SettingsScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    @Query private var personalisationData: [PersonalisationData]
    
    @State private var showImportFlow = false
    @State private var showReminderDebug = false
    @State private var showLocationNotificationTest = false
    
    // Dummy Data for now
    private let dummyName = "Kunth Shah"
    private let dummyEmail = "kunth@example.com"
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Profile Header
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundStyle(.gray)
                            .background(Circle().fill(Color.gray.opacity(0.1)))
                        
                        VStack(spacing: 4) {
                            Text(dummyName)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(dummyEmail)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }
                
                // MARK: - Manage Profile
                Section {
                    NavigationLink(destination: ProfileEditScreen()) {
                        Label("Manage Profile", systemImage: "person.text.rectangle")
                    }
                }
                
                // MARK: - Customise Experience
                Section("Customise my experience") {
                    NavigationLink(destination: AppearanceScreen()) {
                        Label("Appearance", systemImage: "paintpalette")
                    }
                }
                
                // MARK: - Notifications
                Section {
                    NavigationLink(destination: NotificationsSettingsScreen()) {
                        Label("Manage Notifications", systemImage: "bell.badge")
                    }
                }
                
                // MARK: - Support & Legal
                Section {
                    NavigationLink(destination: ReportBugScreen()) {
                        Label("Report a Bug", systemImage: "ant")
                    }
                    
                    NavigationLink(destination: SubscriptionScreen()) {
                        Label("Manage Subscription", systemImage: "creditcard")
                    }
                    
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                }
                
                // MARK: - Testing & Debug
                Section("Testing & Debug") {
                    Button("Test Location Notifications") {
                        showLocationNotificationTest = true
                    }
                    
                    Button("Test Contact Input") {
                        showImportFlow = true
                    }
                    
                    Button("Reminder System Debug") {
                        showReminderDebug = true
                    }
                    
                    Button("Test Onboarding (Resets App)") {
                        resetOnboarding()
                    }
                    .foregroundStyle(.red)
                    
                    Button("Reset All Data") {
                        resetAllData()
                    }
                    .foregroundStyle(.red)
                }
            }
            .navigationTitle("Profile")
            .navigationDestination(isPresented: $showLocationNotificationTest) {
                LocationNotificationTestScreen()
            }
            .navigationDestination(isPresented: $showImportFlow) {
                ImportContactsScreen()
            }
            .navigationDestination(isPresented: $showReminderDebug) {
                ReminderQueueDebugView()
            }
        }
    }
    
    // MARK: - Actions
    
    private func resetAllData() {
        do {
            try modelContext.delete(model: Contact.self)
        } catch {
            print("Failed to reset data: \(error)")
        }
    }
    
    private func resetOnboarding() {
        hasCompletedOnboarding = false
        exit(0)
    }
}

#Preview {
    SettingsScreen()
        .modelContainer(for: [Contact.self, PersonalisationData.self], inMemory: true)
}
