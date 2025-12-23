//
//  PlanReadyScreen.swift
//  warmnet
//
//  Created on 24 December 2025.
//

import SwiftUI

struct PlanReadyScreen: View {
    @State private var showContent = false
    @State private var checkmarkScale: CGFloat = 0.5
    
    var onContinue: () -> Void = {}
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.green.opacity(0.15), Color.teal.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Success checkmark with animation
                ZStack {
                    // Glow rings
                    ForEach(0..<2) { index in
                        Circle()
                            .stroke(
                                Color.green.opacity(0.3 - Double(index) * 0.1),
                                lineWidth: 3
                            )
                            .frame(width: 160 + CGFloat(index * 40), height: 160 + CGFloat(index * 40))
                            .scaleEffect(showContent ? 1.0 : 0.5)
                            .opacity(showContent ? 1.0 : 0.0)
                            .animation(.easeOut(duration: 0.6).delay(Double(index) * 0.1), value: showContent)
                    }
                    
                    // Main circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.green.opacity(0.3), Color.teal.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .scaleEffect(checkmarkScale)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: checkmarkScale)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .teal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(checkmarkScale)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1), value: checkmarkScale)
                }
                .padding(.vertical, 20)
                
                // Text content
                VStack(spacing: 24) {
                    Text("Success!")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .teal],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .scaleEffect(showContent ? 1.0 : 0.8)
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: showContent)
                    
                    VStack(spacing: 12) {
                        Text("Your Plan is ready")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("Everything is set up and ready for you to start building meaningful connections")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.primary.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .opacity(showContent ? 1.0 : 0.0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.4), value: showContent)
                }
                
                Spacer()
                
                // Continue button
                Button(action: onContinue) {
                    HStack(spacing: 8) {
                        Text("Continue")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [.green, .teal],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .opacity(showContent ? 1.0 : 0.0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.6), value: showContent)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation {
                showContent = true
                checkmarkScale = 1.0
            }
            
            // Trigger haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
}

#Preview {
    PlanReadyScreen()
}
