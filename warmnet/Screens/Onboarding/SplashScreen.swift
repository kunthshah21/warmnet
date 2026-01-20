//
//  SplashScreen.swift
//  warmnet
//
//  Created on 24 December 2025.
//

import SwiftUI

struct SplashScreen: View {
    var onSkip: () -> Void = {}
    
    var body: some View {
        ZStack {
            // Background - Deep Navy gradient
            AppGradients.background
                .ignoresSafeArea()
            
            // App name
            Text("WarmNet")
                .font(.custom(AppFontName.workSansMedium, size: 56))
                .foregroundColor(AppColors.textPrimary)
            
            // Skip button in top right
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: onSkip) {
                        Text("Skip")
                            .font(.custom(AppFontName.workSansMedium, size: 14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(AppGradients.blueGlow)
                            .cornerRadius(20)
                    }
                    .padding(.top, 60)
                    .padding(.trailing, 24)
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    SplashScreen()
}
