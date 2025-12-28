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
            // Background - Black
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Progress and header
                VStack(spacing: 8) {
                    HStack {
                        Text("Question 4 of 4")
                            .font(Font.custom("Overpass-Medium", size: 14))
                            .foregroundColor(.black.opacity(0.7))
                        
                        Spacer()
                        
                        Text("80% complete")
                            .font(Font.custom("Overpass-Medium", size: 14))
                            .foregroundColor(Color(red: 0.32, green: 0.57, blue: 0.87))
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 60)
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(red: 0.32, green: 0.57, blue: 0.87))
                                .frame(width: geometry.size.width * 0.8, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 32)
                }
                
                // Question
                VStack(alignment: .leading, spacing: 12) {
                    Text("What's your natural communication style?")
                        .font(Font.custom("WorkSans-Medium", size: 26))
                        .foregroundColor(.black)
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
                        .font(Font.custom("Overpass-Medium", size: 14))
                        .foregroundColor(.black.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 16)
                }
                
                Spacer()
                
                // Complete button
                Button(action: onComplete) {
                    Text("Continue")
                        .font(Font.custom("Overpass-Medium", size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: 253)
                        .frame(height: 48)
                        .background(
                            selectedStyle != nil ?
                            Color(red: 0.32, green: 0.57, blue: 0.87) :
                            Color.gray.opacity(0.5)
                        )
                        .cornerRadius(20)
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
                                isSelected ? Color(red: 0.32, green: 0.57, blue: 0.87) : Color.white.opacity(0.3),
                                lineWidth: 2
                            )
                            .frame(width: 24, height: 24)
                        
                        if isSelected {
                            Circle()
                                .fill(Color(red: 0.32, green: 0.57, blue: 0.87))
                                .frame(width: 12, height: 12)
                        }
                    }
                    
                    // Emoji and title
                    HStack(spacing: 8) {
                        Text(emoji)
                            .font(.system(size: 24))
                        
                        Text(title)
                            .font(Font.custom("WorkSans-Medium", size: 18))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                }
                
                // Description
                Text(description)
                    .font(Font.custom("Overpass-Medium", size: 14))
                    .foregroundColor(.black.opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 40)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isSelected ? Color(red: 0.32, green: 0.57, blue: 0.87) : Color.white.opacity(0.1),
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
