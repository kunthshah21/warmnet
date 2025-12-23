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
                        ProblemScreen(onContinue: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentScreen = .painfulTruth
                            }
                        })
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                        
                    case .painfulTruth:
                        PainfulTruthScreen(onShowMeHow: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentScreen = .valueProposition
                            }
                        })
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                        
                    case .valueProposition:
                        ValuePropositionScreen(onBuildMySystem: {
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
                
                // Debug navigation overlay (bottom)
                if currentScreen != .personalisation && currentScreen != .contactImport {
                    VStack {
                        Spacer()
                        
                        HStack(spacing: 16) {
                            // Screen indicator dots
                            HStack(spacing: 8) {
                                ForEach([OnboardingScreen.problem, .painfulTruth, .valueProposition], id: \.self) { screen in
                                    Circle()
                                        .fill(currentScreen == screen ? Color.primary : Color.gray.opacity(0.4))
                                        .frame(width: 8, height: 8)
                                }
                            }
                            
                            Spacer()
                            
                            // Quick navigation buttons for testing
                            Button("Reset") {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    currentScreen = .splash
                                }
                            }
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
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
