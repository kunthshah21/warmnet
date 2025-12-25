//
//  PainfulTruthScreen.swift
//  warmnet
//
//  Created on 24 December 2025.
//

import SwiftUI

struct PainfulTruthScreen: View {
    var onShowMeHow: () -> Void = {}
    
    var body: some View {
        ZStack {
            // Background - Black
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(minHeight: 120, maxHeight: 180)
                
                // Image
                Image("onboarding-2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 0)
                    .scaleEffect(1.2)
                
                Spacer()
                    .frame(height: 30)
                
                // Content Section
                VStack(spacing: 20) {
                    // Title
                    Text("You reach out. They help. You vanish.")
                        .font(Font.custom("WorkSans-Medium", size: 30))
                        .lineSpacing(10)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 40)
                    
                    // Subtitle
                    Text("This pattern is killing your best relationships, one ghost at a time.")
                        .font(Font.custom("Overpass-Medium", size: 14))
                        .lineSpacing(4)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 70)
                    
                    Spacer()
                        .frame(height: 10)
                    
                    // Continue button
                    Button(action: onShowMeHow) {
                        Text("Continue")
                            .font(Font.custom("Overpass-Medium", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: 253)
                            .frame(height: 48)
                            .background(Color(red: 0.32, green: 0.57, blue: 0.87))
                            .cornerRadius(20)
                    }
                }
                
                Spacer()
                    .frame(minHeight: 100, maxHeight: 150)
            }
        }
    }
}

#Preview {
    PainfulTruthScreen()
}

