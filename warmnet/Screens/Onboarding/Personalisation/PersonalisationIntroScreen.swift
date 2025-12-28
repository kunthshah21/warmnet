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
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                    .frame(height: 60)
                
                // Small text at top
                Text("Let's personalise your experience ⚡")
                    .font(Font.custom("Overpass-Medium", size: 18))
                    .foregroundColor(.black.opacity(0.9))
                
                Text("(Takes 45 seconds)")
                    .font(Font.custom("Overpass-Medium", size: 14))
                    .foregroundColor(.black.opacity(0.7))
                
                // Visual element
                Image(systemName: "person.crop.circle.fill.badge.checkmark")
                    .font(.system(size: 80))
                    .foregroundColor(Color(red: 0.32, green: 0.57, blue: 0.87))
                    .padding(.vertical, 40)
                
                // Description
                VStack(spacing: 12) {
                    Text("We'll ask you 4 quick questions")
                        .font(Font.custom("WorkSans-Medium", size: 20))
                        .foregroundColor(.black)
                    
                    Text("This helps us personalize WarmNet to match YOUR relationship style")
                        .font(Font.custom("Overpass-Medium", size: 16))
                        .foregroundColor(.black.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Start button
                Button(action: onStart) {
                    Text("Let's Start")
                        .font(Font.custom("Overpass-Medium", size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: 253)
                        .frame(height: 48)
                        .background(Color(red: 0.32, green: 0.57, blue: 0.87))
                        .cornerRadius(20)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    PersonalisationIntroScreen()
}
