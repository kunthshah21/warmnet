//
//  FinalCongratulationsScreen.swift
//  warmnet
//
//  Created on 24 December 2025.
//

import SwiftUI

struct FinalCongratulationsScreen: View {
    @State private var showContent = false
    @State private var confettiPieces: [ConfettiPiece] = []
    
    var onComplete: () -> Void = {}
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.green.opacity(0.15), Color.blue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Success icon with animation
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.green.opacity(0.3), Color.blue.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(showContent ? 1.0 : 0.5)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showContent)
                    
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 90))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(showContent ? 1.0 : 0.5)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1), value: showContent)
                }
                
                // Congratulations text
                VStack(spacing: 20) {
                    Text("Congratulations! 🎉")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                        .scaleEffect(showContent ? 1.0 : 0.8)
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: showContent)
                    
                    Text("You're all set to use your system!")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .opacity(showContent ? 1.0 : 0.0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: showContent)
                    
                    VStack(spacing: 12) {
                        FeatureCheckRow(icon: "person.3.fill", text: "Contacts imported")
                        FeatureCheckRow(icon: "star.fill", text: "Priorities set")
                        FeatureCheckRow(icon: "map.fill", text: "Locations enriched")
                        FeatureCheckRow(icon: "sparkles", text: "System personalized")
                    }
                    .padding(.top, 8)
                    .opacity(showContent ? 1.0 : 0.0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: showContent)
                }
                
                Spacer()
                
                // Get Started button
                Button(action: onComplete) {
                    Text("Get Started")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [.green, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .opacity(showContent ? 1.0 : 0.0)
                .offset(y: showContent ? 0 : 20)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: showContent)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
            
            // Confetti overlay
            ForEach(confettiPieces) { piece in
                ConfettiView(piece: piece)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            triggerCelebration()
        }
    }
    
    private func triggerCelebration() {
        // Trigger haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Show content animation
        withAnimation {
            showContent = true
        }
        
        // Generate confetti pieces
        confettiPieces = (0..<60).map { _ in
            ConfettiPiece()
        }
    }
}

// MARK: - Feature Check Row

struct FeatureCheckRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.green)
            }
            
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.green)
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    FinalCongratulationsScreen()
}
