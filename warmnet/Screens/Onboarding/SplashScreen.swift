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
            // Background - Black
            Color.black
                .ignoresSafeArea()
            
            // App name
            Text("WarmNet")
                .font(Font.custom(AppFontName.workSansMedium, size: 56))
                .foregroundColor(.white)
            
            // Skip button in top right
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: onSkip) {
                        Text("Skip")
                            .typography(\.primaryButton)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color(red: 0.32, green: 0.57, blue: 0.87))
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
