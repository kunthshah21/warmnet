//
//  ConnectionSizeQuestionScreen.swift
//  warmnet
//
//  Created on 24 December 2025.
//

import SwiftUI

struct ConnectionSizeQuestionScreen: View {
    @Binding var selectedSize: ConnectionSize?
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
                        Text("Question 3 of 4")
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
                                .frame(width: geometry.size.width * 0.75, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 32)
                }
                
                // Question
                VStack(alignment: .leading, spacing: 12) {
                    Text("How many people do you want to stay meaningfully connected with?")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 32)
                        .padding(.top, 24)
                }
                
                // Options
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(ConnectionSize.allCases, id: \.self) { size in
                            ConnectionSizeButton(
                                range: size.range,
                                description: size.description,
                                isSelected: selectedSize == size,
                                action: {
                                    selectedSize = size
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
                    
                    // Micro-copy
                    Text("Don't worry - we'll help you manage whatever you choose")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.primary.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 16)
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
                            selectedSize != nil ?
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
                .disabled(selectedSize == nil)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
}

// Connection Size Button Component
struct ConnectionSizeButton: View {
    let range: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
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
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(range)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text(description)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.primary.opacity(0.7))
                    }
                    
                    Spacer()
                }
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
    ConnectionSizeQuestionScreen(selectedSize: .constant(nil))
}
