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
            // Background - Black
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Progress bar at the very top
                HStack(spacing: 12) {
                    Text("1/4")
                        .font(Font.custom(AppFontName.overpassVariable, size: 14).weight(.semibold))
                        .foregroundColor(.white.opacity(0.7))
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(red: 0.32, green: 0.57, blue: 0.87))
                                .frame(width: geometry.size.width * 0.25, height: 4)
                        }
                    }
                    .frame(height: 4)
                }
                .padding(.horizontal, 32)
                .padding(.top, 20)
                
                // Question
                VStack(alignment: .leading, spacing: 12) {
                    Text("What's your main goal with relationships?")
                        .font(Font.custom(AppFontName.workSansMedium, size: 26))
                        .foregroundColor(.white)
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
                        .typography(\.primaryButton)
                        .frame(maxWidth: 253)
                        .frame(height: 48)
                        .background(
                            selectedGoal != nil ?
                            Color(red: 0.32, green: 0.57, blue: 0.87) :
                            Color.gray.opacity(0.5)
                        )
                        .cornerRadius(20)
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
                            isSelected ? Color(red: 0.32, green: 0.57, blue: 0.87) : Color.gray.opacity(0.3),
                            lineWidth: 2
                        )
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color(red: 0.32, green: 0.57, blue: 0.87))
                            .frame(width: 12, height: 12)
                    }
                }
                
                // Text
                Text(text)
                    .font(Font.custom(AppFontName.overpassVariable, size: 16).weight(.medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isSelected ? Color(red: 0.32, green: 0.57, blue: 0.87) : Color.white.opacity(0.25),
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
