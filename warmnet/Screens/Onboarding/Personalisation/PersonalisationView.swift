//
//  PersonalisationView.swift
//  warmnet
//
//  Created on 24 December 2025.
//

import SwiftUI
import SwiftData

struct PersonalisationView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentScreen: PersonalisationScreen = .intro
    @State private var personalisationData = PersonalisationData()
    
    @State private var selectedGoal: RelationshipGoal?
    @State private var selectedChallenges: Set<Challenge> = []
    @State private var selectedSize: ConnectionSize?
    @State private var selectedStyle: CommunicationStyle?
    
    var onComplete: () -> Void = {}
    
    enum PersonalisationScreen {
        case intro
        case goal
        case challenge
        case connectionSize
        case communicationStyle
        case success
        case personalising
    }
    
    var body: some View {
        ZStack {
            // Main personalisation flow
            Group {
                switch currentScreen {
                case .intro:
                    PersonalisationIntroScreen(onStart: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = .goal
                        }
                    })
                    .transition(.opacity)
                    
                case .goal:
                    GoalQuestionScreen(
                        selectedGoal: $selectedGoal,
                        onContinue: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentScreen = .challenge
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                    
                case .challenge:
                    ChallengeQuestionScreen(
                        selectedChallenges: $selectedChallenges,
                        onContinue: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentScreen = .connectionSize
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                    
                case .connectionSize:
                    ConnectionSizeQuestionScreen(
                        selectedSize: $selectedSize,
                        onContinue: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentScreen = .communicationStyle
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                    
                case .communicationStyle:
                    CommunicationStyleQuestionScreen(
                        selectedStyle: $selectedStyle,
                        onComplete: {
                            savePersonalisationData()
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentScreen = .success
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                
                case .success:
                    SuccessScreen(onContinue: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentScreen = .personalising
                        }
                    })
                    .transition(.opacity)
                
                case .personalising:
                    PersonalisingLoadingScreen(onComplete: {
                        onComplete()
                    })
                    .transition(.opacity)
                }
            }
            
            // Debug navigation overlay (bottom) - for testing only
            if currentScreen != .intro && currentScreen != .success && currentScreen != .personalising {
                VStack {
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Spacer()
                        
                        // Quick navigation button for testing
                        Button("Reset to Intro") {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                resetData()
                                currentScreen = .intro
                            }
                        }
                        .font(.system(size: 11, weight: .medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func savePersonalisationData() {
        personalisationData.relationshipGoal = selectedGoal
        personalisationData.challenges = Array(selectedChallenges)
        personalisationData.connectionSize = selectedSize
        personalisationData.communicationStyle = selectedStyle
        personalisationData.completedAt = Date()
        
        modelContext.insert(personalisationData)
        
        do {
            try modelContext.save()
            print("✅ Personalisation data saved successfully")
            print("Goal: \(selectedGoal?.rawValue ?? "None")")
            print("Challenges: \(selectedChallenges.map { $0.rawValue })")
            print("Connection Size: \(selectedSize?.rawValue ?? "None")")
            print("Communication Style: \(selectedStyle?.rawValue ?? "None")")
        } catch {
            print("❌ Failed to save personalisation data: \(error.localizedDescription)")
        }
    }
    
    private func resetData() {
        selectedGoal = nil
        selectedChallenges = []
        selectedSize = nil
        selectedStyle = nil
        personalisationData = PersonalisationData()
    }
}

#Preview {
    PersonalisationView()
        .modelContainer(for: [PersonalisationData.self])
}
