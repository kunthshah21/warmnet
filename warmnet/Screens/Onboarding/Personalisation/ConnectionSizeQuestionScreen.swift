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
            // Background - Black
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Progress bar at the very top
                HStack(spacing: 12) {
                    Text("3/4")
                        .font(Font.custom(AppFontName.overpassVariable, size: 14).weight(.semibold))
                        .foregroundColor(.black.opacity(0.7))
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(red: 0.32, green: 0.57, blue: 0.87))
                                .frame(width: geometry.size.width * 0.75, height: 4)
                        }
                    }
                    .frame(height: 4)
                }
                .padding(.horizontal, 32)
                .padding(.top, 20)
                
                // Question
                VStack(alignment: .leading, spacing: 12) {
                    Text("How many people do you want to stay meaningfully connected with?")
                        .font(Font.custom(AppFontName.workSansMedium, size: 26))
                        .foregroundColor(.black)
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
                        .font(Font.custom(AppFontName.overpassVariable, size: 14).weight(.medium))
                        .foregroundColor(.black.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 16)
                }
                
                // Continue button
                Button(action: onContinue) {
                    Text("Continue")
                        .typography(\.primaryButton)
                        .frame(maxWidth: 253)
                        .frame(height: 48)
                        .background(
                            selectedSize != nil ?
                            Color(red: 0.32, green: 0.57, blue: 0.87) :
                            Color.gray.opacity(0.5)
                        )
                        .cornerRadius(20)
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
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(range)
                            .font(Font.custom(AppFontName.workSansMedium, size: 18))
                            .foregroundColor(.black)
                        
                        Text(description)
                            .font(Font.custom(AppFontName.overpassVariable, size: 14).weight(.medium))
                            .foregroundColor(.black.opacity(0.7))
                    }
                    
                    Spacer()
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isSelected ? Color(red: 0.32, green: 0.57, blue: 0.87) : Color.gray.opacity(0.25),
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
