//
//  ChallengeQuestionScreen.swift
//  warmnet
//
//  Created on 24 December 2025.
//

import SwiftUI

struct ChallengeQuestionScreen: View {
    @Binding var selectedChallenges: Set<Challenge>
    var onContinue: () -> Void = {}
    
    var body: some View {
        ZStack {
            // Background - Black
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Progress bar at the very top
                HStack(spacing: 12) {
                    Text("2/4")
                        .font(Font.custom(AppFontName.overpassVariable, size: 14).weight(.semibold))
                        .foregroundColor(.white.opacity(0.7))
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(red: 0.32, green: 0.57, blue: 0.87))
                                .frame(width: geometry.size.width * 0.5, height: 4)
                        }
                    }
                    .frame(height: 4)
                }
                .padding(.horizontal, 32)
                .padding(.top, 20)
                
                // Question
                VStack(alignment: .leading, spacing: 12) {
                    Text("What's your biggest challenge?")
                        .font(Font.custom(AppFontName.workSansMedium, size: 26))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.top, 24)
                    
                    Text("Select all that apply")
                        .font(Font.custom(AppFontName.overpassVariable, size: 14).weight(.medium))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 32)
                }
                
                // Options
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Challenge.allCases, id: \.self) { challenge in
                            CheckboxButton(
                                text: challenge.rawValue,
                                isSelected: selectedChallenges.contains(challenge),
                                action: {
                                    if selectedChallenges.contains(challenge) {
                                        selectedChallenges.remove(challenge)
                                    } else {
                                        selectedChallenges.insert(challenge)
                                    }
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
                            !selectedChallenges.isEmpty ?
                            Color(red: 0.32, green: 0.57, blue: 0.87) :
                            Color.gray.opacity(0.5)
                        )
                        .cornerRadius(20)
                }
                .disabled(selectedChallenges.isEmpty)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
}

// Reusable Checkbox Button Component
struct CheckboxButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(
                            isSelected ? Color(red: 0.32, green: 0.57, blue: 0.87) : Color.gray.opacity(0.3),
                            lineWidth: 2
                        )
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(red: 0.32, green: 0.57, blue: 0.87))
                            .frame(width: 16, height: 16)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
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
    ChallengeQuestionScreen(selectedChallenges: .constant([]))
}
