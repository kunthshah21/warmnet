//
//  SuccessScreen.swift
//  warmnet
//
//  Created on 24 December 2025.
//

import SwiftUI

struct SuccessScreen: View {
    @State private var showConfetti = false
    @State private var confettiPieces: [ConfettiPiece] = []
    
    var onContinue: () -> Void = {}
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.green.opacity(0.15), Color.blue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
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
                        .frame(width: 140, height: 140)
                        .scaleEffect(showConfetti ? 1.0 : 0.5)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showConfetti)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(showConfetti ? 1.0 : 0.5)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1), value: showConfetti)
                }
                
                // Hooray text
                VStack(spacing: 16) {
                    Text("Hooray! 🎉")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .scaleEffect(showConfetti ? 1.0 : 0.8)
                        .opacity(showConfetti ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: showConfetti)
                    
                    Text("Congratulations on taking your first steps!")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .opacity(showConfetti ? 1.0 : 0.0)
                        .offset(y: showConfetti ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: showConfetti)
                    
                    Text("You're on your way to building meaningful, lasting relationships.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.primary.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .opacity(showConfetti ? 1.0 : 0.0)
                        .offset(y: showConfetti ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: showConfetti)
                }
                
                Spacer()
            }
            
            // Confetti overlay
            ForEach(confettiPieces) { piece in
                ConfettiView(piece: piece)
            }
        }
        .onAppear {
            triggerSuccess()
        }
    }
    
    private func triggerSuccess() {
        // Trigger haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Show confetti animation
        withAnimation {
            showConfetti = true
        }
        
        // Generate confetti pieces
        confettiPieces = (0..<50).map { _ in
            ConfettiPiece()
        }
        
        // Auto-advance after 2.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            onContinue()
        }
    }
}

// MARK: - Confetti Models and Views

struct ConfettiPiece: Identifiable {
    let id = UUID()
    let color: Color
    let startX: CGFloat
    let startY: CGFloat
    let endY: CGFloat
    let rotation: Double
    let scale: CGFloat
    
    init() {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
        self.color = colors.randomElement() ?? .blue
        self.startX = CGFloat.random(in: 0...UIScreen.main.bounds.width)
        self.startY = CGFloat.random(in: -100...0)
        self.endY = UIScreen.main.bounds.height + 100
        self.rotation = Double.random(in: 0...720)
        self.scale = CGFloat.random(in: 0.4...1.0)
    }
}

struct ConfettiView: View {
    let piece: ConfettiPiece
    @State private var animate = false
    
    var body: some View {
        Circle()
            .fill(piece.color)
            .frame(width: 8 * piece.scale, height: 8 * piece.scale)
            .position(
                x: piece.startX + (animate ? CGFloat.random(in: -50...50) : 0),
                y: animate ? piece.endY : piece.startY
            )
            .rotationEffect(.degrees(animate ? piece.rotation : 0))
            .opacity(animate ? 0 : 1)
            .onAppear {
                withAnimation(
                    .linear(duration: Double.random(in: 2.0...3.5))
                ) {
                    animate = true
                }
            }
    }
}

#Preview {
    SuccessScreen()
}
