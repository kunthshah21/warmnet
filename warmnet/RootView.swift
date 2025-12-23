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
    @State private var showOnboarding = false
    
    var body: some View {
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
        .onAppear {
            // For testing: Show onboarding if not completed
            showOnboarding = !hasCompletedOnboarding
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: [Contact.self, PersonalisationData.self], inMemory: true)
}
