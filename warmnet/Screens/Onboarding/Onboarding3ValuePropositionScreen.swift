//
//  ValuePropositionScreen.swift
//  warmnet
//
//  Created on 24 December 2025.
//

import SwiftUI

struct Onboarding3ValuePropositionScreen: View {
    var onBuildMySystem: () -> Void = {}
    
    var body: some View {
        ZStack {
            // Background - White
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(minHeight: 60, maxHeight: 100)
                
                // Image
                Image("onboarding-3")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
                    .padding(.horizontal, 20)
                
                Spacer()
                    .frame(height: 30)
                
                // Content Section
                VStack(spacing: 12) {
                    // Title
                    Text("Imagine reaching out with nothing to ask")
                        .font(Font.custom(AppFontName.workSansRegular, size: 30))
                        .lineSpacing(6)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(height: 80)
                        .padding(.horizontal, 24)
                    
                    // Subtitle
                    Text("Just value to give. Just genuine interest. That's how real networks are built.")
                        .font(Font.custom(AppFontName.overpassVariable, size: 14))
                        .lineSpacing(4)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(height: 60)
                        .padding(.horizontal, 45)
                }
                
                Spacer()
                
                // Buttons Section at Bottom
                VStack(spacing: 16) {
                    // Primary Button - Start Fresh
                    Button(action: onBuildMySystem) {
                        Text("Start Fresh")
                            .typography(\.primaryButton)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color(red: 0.32, green: 0.57, blue: 0.87))
                            .cornerRadius(15)
                    }
                    .padding(.horizontal, 20)
                    
                    // Secondary Button - Login
                    SecondaryButton(title: "Login to my Account") {
                        // Login action
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 10)
            }
        }
    }
}

#Preview {
    Onboarding3ValuePropositionScreen()
}

