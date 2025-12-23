//
//  OnboardingContactImportWrapper.swift
//  warmnet
//
//  Created on 24 December 2025.
//

import SwiftUI

struct OnboardingContactImportWrapper: View {
    @State private var currentScreen: Screen = .contactImport
    
    var onComplete: () -> Void = {}
    
    enum Screen {
        case contactImport
        case finalCongratulations
        case socialProof
        case customising
        case planReady
        case paywall
    }
    
    var body: some View {
        Group {
            switch currentScreen {
            case .contactImport:
                ImportContactsScreen(onFlowComplete: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentScreen = .finalCongratulations
                    }
                })
                .transition(.opacity)
            
            case .finalCongratulations:
                FinalCongratulationsScreen(onComplete: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentScreen = .socialProof
                    }
                })
                .transition(.opacity)
            
            case .socialProof:
                SocialProofScreen(onContinue: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentScreen = .customising
                    }
                })
                .transition(.opacity)
            
            case .customising:
                CustomisingExperienceScreen(onComplete: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentScreen = .planReady
                    }
                })
                .transition(.opacity)
            
            case .planReady:
                PlanReadyScreen(onContinue: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentScreen = .paywall
                    }
                })
                .transition(.opacity)
            
            case .paywall:
                PaywallScreen(
                    onContinue: {
                        // User selected premium
                        print("User selected premium plan")
                        onComplete()
                    },
                    onSkip: {
                        // User continues with free
                        print("User continues with free plan")
                        onComplete()
                    }
                )
                .transition(.opacity)
            }
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingContactImportWrapper()
    }
}
