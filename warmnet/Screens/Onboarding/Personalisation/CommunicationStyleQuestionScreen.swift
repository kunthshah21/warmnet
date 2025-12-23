//
//  CommunicationStyleQuestionScreen.swift
//  warmnet
//
//  Created on 24 December 2025.
//

import SwiftUI

struct CommunicationStyleQuestionScreen: View {
    @Binding var selectedStyle: CommunicationStyle?
    var onComplete: () -> Void = {}
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Progress and header
                VStack(spacing: 8) {
                    HStack {
                        Text("Question 4 of 4")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary.opacity(0.6))
                        
                        Spacer()
                        
                        Text("80% complete")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.purple)
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
                                .frame(width: geometry.size.width * 0.8, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 32)
                }
                
                // Question
                VStack(alignment: .leading, spacing: 12) {
                    Text("What's your natural communication style?")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 32)
                        .padding(.top, 24)
                }
                
                // Options
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(CommunicationStyle.allCases, id: \.self) { style in
                            CommunicationStyleButton(
                                emoji: style.emoji,
                                title: style.rawValue,
                                description: style.description,
                                isSelected: selectedStyle == style,
                                action: {
                                    selectedStyle = style
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
                    
                    // Micro-copy
                    Text("We'll suggest outreach styles that match YOUR personality")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.primary.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 16)
                }
                
                Spacer()
                
                // Complete button
                Button(action: onComplete) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            selectedStyle != nil ?
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
                .disabled(selectedStyle == nil)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
}

// Communication Style Button Component
struct CommunicationStyleButton: View {
    let emoji: String
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
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
                    
                    // Emoji and title
                    HStack(spacing: 8) {
                        Text(emoji)
                            .font(.system(size: 24))
                        
                        Text(title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                }
                
                // Description
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.primary.opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 40)
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
    CommunicationStyleQuestionScreen(selectedStyle: .constant(nil))
}
