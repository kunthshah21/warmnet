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
            // Background
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Progress and header
                VStack(spacing: 8) {
                    HStack {
                        Text("Question 2 of 4")
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
                                .frame(width: geometry.size.width * 0.5, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 32)
                }
                
                // Question
                VStack(alignment: .leading, spacing: 12) {
                    Text("What's your biggest challenge?")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 32)
                        .padding(.top, 24)
                    
                    Text("Select all that apply")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.primary.opacity(0.6))
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
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            !selectedChallenges.isEmpty ?
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
                            isSelected ? Color.purple : Color.gray.opacity(0.4),
                            lineWidth: 2
                        )
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 16, height: 16)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
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
    ChallengeQuestionScreen(selectedChallenges: .constant([]))
}
