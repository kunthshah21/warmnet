//
//  GoalQuestionScreen.swift
//  warmnet
//
//  Created on 24 December 2025.
//

import SwiftUI

struct GoalQuestionScreen: View {
    @Binding var selectedGoal: RelationshipGoal?
    var onContinue: () -> Void = {}
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Progress and header
                VStack(spacing: 8) {
                    HStack {
                        Text("Question 1 of 4")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary.opacity(0.6))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 60)
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [.purple, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * 0.25, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 32)
                }
                
                // Question
                VStack(alignment: .leading, spacing: 12) {
                    Text("What's your main goal with relationships?")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 32)
                        .padding(.top, 24)
                }
                
                // Options
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(RelationshipGoal.allCases, id: \.self) { goal in
                            RadioButton(
                                text: goal.rawValue,
                                isSelected: selectedGoal == goal,
                                action: {
                                    selectedGoal = goal
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
                }
                
                Spacer()
                
                // Continue button
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            selectedGoal != nil ?
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                colors: [.gray.opacity(0.5), .gray.opacity(0.5)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(selectedGoal == nil)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
}

// Reusable Radio Button Component
struct RadioButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Radio circle
                ZStack {
                    Circle()
                        .strokeBorder(
                            isSelected ? Color.purple : Color.gray.opacity(0.4),
                            lineWidth: 2
                        )
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 12, height: 12)
                    }
                }
                
                // Text
                Text(text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: isSelected ? Color.purple.opacity(0.2) : Color.clear, radius: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isSelected ? Color.purple.opacity(0.5) : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    GoalQuestionScreen(selectedGoal: .constant(nil))
}
