//
//  PainfulTruthScreen.swift
//  warmnet
//
//  Created on 24 December 2025.
//

import SwiftUI

struct Onboarding2PainfulTruthScreen: View {
    var onShowMeHow: () -> Void = {}
    
    var body: some View {
        ZStack {
            // Background - Deep Navy gradient
            AppGradients.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(minHeight: 60, maxHeight: 100)
                
                // Image
                Image("onboarding-2")
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
                    Text("You reach out. They help. You vanish.")
                        .font(.custom(AppFontName.workSansRegular, size: 30))
                        .lineSpacing(6)
                        .foregroundColor(AppColors.textPrimary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(height: 80)
                        .padding(.horizontal, 24)
                    
                    // Subtitle
                    Text("This pattern is killing your best relationships, one ghost at a time.")
                        .font(.custom(AppFontName.workSansRegular, size: 14))
                        .lineSpacing(4)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(height: 60)
                        .padding(.horizontal, 45)
                }
                
                Spacer()
                
                // Buttons Section at Bottom
                VStack(spacing: 16) {
                    // Primary Button - Start Fresh
                    Button(action: onShowMeHow) {
                        Text("Start Fresh")
                            .font(.custom(AppFontName.workSansMedium, size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(AppGradients.blueGlow)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal, 20)
                    .shadow(color: AppColors.mutedBlue.opacity(0.3), radius: 12, x: 0, y: 6)
                    
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
    Onboarding2PainfulTruthScreen()
}

