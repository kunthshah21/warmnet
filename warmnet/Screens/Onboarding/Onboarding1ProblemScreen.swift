//
//  ProblemScreen.swift
//  warmnet
//
//  Created on 24 December 2025.
//

import SwiftUI

struct Onboarding1ProblemScreen: View {
    var onContinue: () -> Void = {}
    
    var body: some View {
        ZStack {
            // Background - Black
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(minHeight: 60, maxHeight: 100)
                
                // Image
                Image("onboarding-1")
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
                    Text("Your relationships are slipping away")
                        .font(Font.custom("WorkSans-Regular", size: 30))
                        .lineSpacing(6)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(height: 80)
                        .padding(.horizontal, 24)
                    
                    // Subtitle
                    Text("Important people fade from your life, not from lack of care, but from lack of system")
                        .font(Font.custom("Overpass", size: 14))
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
                    Button(action: onContinue) {
                        Text("Start Fresh")
                            .font(Font.custom("Overpass-Medium", size: 16))
                            .foregroundColor(.white)
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
    Onboarding1ProblemScreen()
}
