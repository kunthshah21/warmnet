//
//  RootView.swift
//  warmnet
//
//  Created on 24 December 2025.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @State private var showOnboarding = false
    @State private var hasMigrated = false
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            Group {
                if hasCompletedOnboarding {
                    // Main app
                    ContentView()
                } else {
                    // Onboarding flow
                    OnboardingView(onComplete: {
                        withAnimation {
                            hasCompletedOnboarding = true
                        }
                    })
                }
            }
        }
        .onAppear {
            // For testing: Show onboarding if not completed
            showOnboarding = !hasCompletedOnboarding
            
            // Perform one-time migration
            if !hasMigrated && MigrationHelper.needsMigration(modelContext: modelContext) {
                MigrationHelper.migrateContactInteractions(modelContext: modelContext)
                hasMigrated = true
            }
        }
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? AppColors.deepNavy : Color(.systemBackground)
    }
}

#Preview {
    RootView()
        .modelContainer(for: [Contact.self, PersonalisationData.self], inMemory: true)
}
