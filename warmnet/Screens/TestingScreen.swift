import SwiftUI
import SwiftData

struct TestingScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showImportFlow = false
    @State private var showOnboarding = false
    @State private var showReminderDebug = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [backgroundTopColor, backgroundBottomColor],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    PrimaryButton(
                        "Test Contact Input",
                        action: {
                            showImportFlow = true
                        }
                    )
                    .padding(.horizontal, 16)
                    
                    PrimaryButton(
                        "Reminder System Debug",
                        action: {
                            showReminderDebug = true
                        }
                    )
                    .padding(.horizontal, 16)
                    
                    PrimaryButton(
                        "Test Onboarding",
                        action: resetOnboarding
                    )
                    .padding(.horizontal, 16)
                    
                    PrimaryButton(
                        "Reset All Data",
                        action: resetAllData
                    )
                    .padding(.horizontal, 16)
                }
            }
            .navigationTitle("Testing")
            .navigationDestination(isPresented: $showImportFlow) {
                ImportContactsScreen()
            }
            .navigationDestination(isPresented: $showReminderDebug) {
                ReminderQueueDebugView()
            }
        }
    }
    
    // Background colors based on color scheme
    private var backgroundTopColor: Color {
        colorScheme == .dark ? Color(red: 0.05, green: 0.05, blue: 0.1) : Color(red: 0.95, green: 0.97, blue: 1.0)
    }
    
    private var backgroundBottomColor: Color {
        colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.15) : Color(red: 0.85, green: 0.90, blue: 0.98)
    }
    
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
    TestingScreen()
}
