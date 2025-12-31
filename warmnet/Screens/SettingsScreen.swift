import SwiftUI
import SwiftData

struct SettingsScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    @Query private var personalisationData: [PersonalisationData]
    
    @State private var showImportFlow = false
    @State private var showReminderDebug = false
    
    private var userProfile: PersonalisationData? {
        personalisationData.first
    }
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Personal Information
                Section("Personal Information") {
                    if let profile = userProfile {
                        // Relationship Goal
                        Picker("Relationship Goal", selection: Binding(
                            get: { profile.relationshipGoal ?? .allOfAbove },
                            set: { profile.relationshipGoal = $0 }
                        )) {
                            ForEach(RelationshipGoal.allCases, id: \.self) { goal in
                                Text(goal.rawValue).tag(goal)
                            }
                        }
                        
                        // Connection Size
                        Picker("Network Size", selection: Binding(
                            get: { profile.connectionSize ?? .medium },
                            set: { profile.connectionSize = $0 }
                        )) {
                            ForEach(ConnectionSize.allCases, id: \.self) { size in
                                Text(size.rawValue).tag(size)
                            }
                        }
                        
                        // Communication Style
                        Picker("Communication Style", selection: Binding(
                            get: { profile.communicationStyle ?? .quickTexter },
                            set: { profile.communicationStyle = $0 }
                        )) {
                            ForEach(CommunicationStyle.allCases, id: \.self) { style in
                                Text(style.rawValue).tag(style)
                            }
                        }
                    } else {
                        Text("No profile data found")
                            .foregroundStyle(.secondary)
                    }
                }
                
                // MARK: - Legal
                Section("Legal") {
                    NavigationLink("Privacy Policy") {
                        PrivacyPolicyView()
                    }
                }
                
                // MARK: - Testing & Debug
                Section("Testing & Debug") {
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
            .navigationTitle("Settings")
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
        // Force the app to show onboarding by restarting
        // The RootView will detect hasCompletedOnboarding = false
        // and show OnboardingView on next launch
        exit(0)
    }
}

#Preview {
    SettingsScreen()
        .modelContainer(for: [Contact.self, PersonalisationData.self], inMemory: true)
}
