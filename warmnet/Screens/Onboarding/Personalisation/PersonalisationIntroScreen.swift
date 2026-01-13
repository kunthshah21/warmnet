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
            // Background - Black
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(minHeight: 60, maxHeight: 100)
                
                Spacer()
                
                // Content Section
                VStack(spacing: 20) {
                    // Title
                    Text("Lets personalise your\nexperience")
                        .font(Font.custom(AppFontName.workSansRegular, size: 30))
                        .lineSpacing(6)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 16)

                    
                    // Subtitle
                    Text("Personalize how you nurture every important relationship effortlessly")
                        .font(Font.custom(AppFontName.overpassVariable, size: 14))
                        .lineSpacing(4)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 70)
                }
                
                Spacer()
                    .frame(height: 40)
                
                // Button
                Button(action: onStart) {
                    Text("Let's Start")
                        .typography(\.primaryButton)
                        .frame(maxWidth: 253)
                        .frame(height: 48)
                        .background(Color(red: 0.32, green: 0.57, blue: 0.87))
                        .cornerRadius(20)
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    PersonalisationIntroScreen()
}
