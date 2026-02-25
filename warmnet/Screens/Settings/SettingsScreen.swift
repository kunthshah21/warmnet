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
    @State private var showBirthdayTest = false
    
    // Get profile data from SwiftData
    private var profileData: PersonalisationData? {
        personalisationData.first
    }
    
    private var displayName: String {
        profileData?.name ?? "Add your name"
    }
    
    private var displayEmail: String {
        profileData?.email ?? "Add your email"
    }
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Profile Header
                Section {
                    VStack(spacing: 12) {
                        if let photoData = profileData?.profilePhoto,
                           let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundStyle(.gray)
                                .background(Circle().fill(Color.gray.opacity(0.1)))
                        }
                        
                        VStack(spacing: 4) {
                            Text(displayName)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(displayEmail)
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
                    
                    Button("Test Birthday Notifications") {
                        showBirthdayTest = true
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
                    .foregroundStyle(AppColors.accentRed)
                    
                    Button("Reset All Data") {
                        resetAllData()
                    }
                    .foregroundStyle(AppColors.accentRed)
                }
            }
            .navigationTitle("Profile")
            .navigationDestination(isPresented: $showLocationNotificationTest) {
                LocationNotificationTestScreen()
            }
            .navigationDestination(isPresented: $showBirthdayTest) {
                BirthdayNotificationTestScreen()
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
        try? modelContext.delete(model: Contact.self)
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
