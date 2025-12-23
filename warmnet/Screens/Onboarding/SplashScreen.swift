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
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // App name
            Text("WarmNet")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.9)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // Skip button in top right
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: onSkip) {
                        Text("Skip")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.2))
                                    .background(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
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
