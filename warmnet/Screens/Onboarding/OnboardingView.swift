//
//  OnboardingView.swift
//  warmnet
//
//  Created on 24 December 2025.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @State private var currentScreen: OnboardingScreen = .splash
    @State private var showSplash = true
    @State private var showPersonalisation = false
    @State private var navigateToContactImport = false
    @State private var showFinalCongratulations = false
    
    var onComplete: () -> Void = {}
    
    enum OnboardingScreen {
        case splash
        case problem
        case painfulTruth
        case valueProposition
        case personalisation
        case contactImport
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Main onboarding flow
                Group {
                    switch currentScreen {
                    case .splash:
                        SplashScreen(onSkip: {
                            // Skip entire onboarding
                            onComplete()
                        })
                        .transition(.opacity)
                        .onAppear {
                            // Auto-advance from splash after 2 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    currentScreen = .problem
                                }
                            }
                        }
                        
                    case .problem:
                        Onboarding1ProblemScreen(onContinue: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentScreen = .painfulTruth
                            }
                        })
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                        
                    case .painfulTruth:
                        Onboarding2PainfulTruthScreen(onShowMeHow: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentScreen = .valueProposition
                            }
                        })
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                        
                    case .valueProposition:
                        Onboarding3ValuePropositionScreen(onBuildMySystem: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentScreen = .personalisation
                            }
                        })
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                    
                    case .personalisation:
                        PersonalisationView(onComplete: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentScreen = .contactImport
                            }
                        })
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                    
                    case .contactImport:
                        OnboardingContactImportWrapper(onComplete: {
                            // Onboarding fully complete
                            onComplete()
                        })
                        .navigationBarBackButtonHidden(true)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: [PersonalisationData.self])
}
