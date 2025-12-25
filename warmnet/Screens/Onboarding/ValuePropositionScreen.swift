//
//  ValuePropositionScreen.swift
//  warmnet
//
//  Created on 24 December 2025.
//

import SwiftUI

struct ValuePropositionScreen: View {
    var onBuildMySystem: () -> Void = {}
    
    var body: some View {
        ZStack {
            // Background - Black
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(minHeight: 120, maxHeight: 180)
                
                // Image
                Image("onboarding-3")
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
                    Text("Imagine reaching out with nothing to ask")
                        .font(Font.custom("WorkSans-Medium", size: 30))
                        .lineSpacing(10)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 40)
                    
                    // Subtitle
                    Text("Just value to give. Just genuine interest. That's how real networks are built.")
                        .font(Font.custom("Overpass-Medium", size: 14))
                        .lineSpacing(4)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 40)
                    
                    Spacer()
                        .frame(height: 10)
                    
                    // Build my system button
                    Button(action: onBuildMySystem) {
                        Text("build my system")
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
    ValuePropositionScreen()
}

