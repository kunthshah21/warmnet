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
    @State private var containerSize: CGSize = .zero
    
    var onComplete: () -> Void = {}
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Black background
                Color.white
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
                            .font(Font.custom(AppFontName.workSansMedium, size: 44))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .scaleEffect(showContent ? 1.0 : 0.8)
                            .opacity(showContent ? 1.0 : 0.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: showContent)
                        
                        Text("You're all set to use your system!")
                            .font(Font.custom(AppFontName.overpassVariable, size: 18).weight(.medium))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
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
                            .typography(\.primaryButton)
                            .frame(maxWidth: 253)
                            .frame(height: 48)
                            .background(Color(red: 0.32, green: 0.57, blue: 0.87))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
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
            .onAppear {
                containerSize = geo.size
                triggerCelebration()
            }
            .onChange(of: geo.size) { _, new in
                containerSize = new
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func triggerCelebration() {
        // Trigger haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Show content animation
        withAnimation {
            showContent = true
        }
        
        // Generate confetti pieces (requires container size)
        confettiPieces = (0..<60).map { _ in
            ConfettiPiece(containerSize: containerSize)
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
                    .fill(Color(red: 0.32, green: 0.57, blue: 0.87).opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0.32, green: 0.57, blue: 0.87))
            }
            
            Text(text)
                .font(Font.custom(AppFontName.overpassVariable, size: 16).weight(.medium))
                .foregroundColor(.black)
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.32, green: 0.57, blue: 0.87))
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    FinalCongratulationsScreen()
}
