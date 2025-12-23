//
//  PersonalisationIntroScreen.swift
//  warmnet
//
//  Created on 24 December 2025.
//

import SwiftUI

struct PersonalisationIntroScreen: View {
    var onStart: () -> Void = {}
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.purple.opacity(0.15), Color.blue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                    .frame(height: 60)
                
                // Small text at top
                Text("Let's personalise your experience ⚡")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary.opacity(0.7))
                
                Text("(Takes 45 seconds)")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.primary.opacity(0.5))
                
                // Visual element
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 180, height: 180)
                    
                    Image(systemName: "person.crop.circle.fill.badge.checkmark")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .padding(.vertical, 40)
                
                // Description
                VStack(spacing: 12) {
                    Text("We'll ask you 4 quick questions")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("This helps us personalize WarmNet to match YOUR relationship style")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.primary.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Start button
                Button(action: onStart) {
                    Text("Let's Start")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    PersonalisationIntroScreen()
}
