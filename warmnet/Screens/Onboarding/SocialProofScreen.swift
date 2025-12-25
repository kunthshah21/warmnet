//
//  SocialProofScreen.swift
//  warmnet
//
//  Created on 24 December 2025.
//

import SwiftUI

struct SocialProofScreen: View {
    @State private var showContent = false
    @State private var badgeScale: CGFloat = 0.5
    
    var onContinue: () -> Void = {}
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Badge/Trophy icon
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.yellow.opacity(0.4), Color.orange.opacity(0.2), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .scaleEffect(showContent ? 1.0 : 0.5)
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.8), value: showContent)
                    
                    // Badge circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .scaleEffect(badgeScale)
                        .animation(.spring(response: 0.6, dampingFraction: 0.5), value: badgeScale)
                    
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(badgeScale)
                        .animation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.1), value: badgeScale)
                }
                .padding(.vertical, 20)
                
                // Text content
                VStack(spacing: 24) {
                    Text("You are 1 step away")
                        .font(Font.custom("WorkSans-Medium", size: 28))
                        .foregroundColor(.white.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                        .opacity(showContent ? 1.0 : 0.0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.3), value: showContent)
                    
                    VStack(spacing: 12) {
                        Text("You have joined the")
                            .font(Font.custom("Overpass-Medium", size: 18))
                            .foregroundColor(.white.opacity(0.7))
                            .fixedSize(horizontal: false, vertical: true)
                        
                        HStack(spacing: 8) {
                            Text("top")
                                .font(Font.custom("WorkSans-Medium", size: 24))
                                .foregroundColor(.white)
                            
                            Text("1%")
                                .font(Font.custom("WorkSans-Medium", size: 36))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            Text("Club")
                                .font(Font.custom("WorkSans-Medium", size: 24))
                                .foregroundColor(.white)
                        }
                        
                        Text("of high social network interactions")
                            .font(Font.custom("Overpass-Medium", size: 16))
                            .foregroundColor(.white.opacity(0.7))
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                    }
                    .opacity(showContent ? 1.0 : 0.0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.5), value: showContent)
                    .padding(.horizontal, 32)
                }
                
                Spacer()
                
                // Continue button
                Button(action: onContinue) {
                    Text("Continue")
                        .font(Font.custom("Overpass-Medium", size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: 253)
                        .frame(height: 48)
                        .background(Color(red: 0.32, green: 0.57, blue: 0.87))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .opacity(showContent ? 1.0 : 0.0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.7), value: showContent)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation {
                showContent = true
                badgeScale = 1.0
            }
            
            // Trigger haptic
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
}

#Preview {
    SocialProofScreen()
}
