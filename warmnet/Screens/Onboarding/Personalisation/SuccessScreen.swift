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
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                // Background - Black
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Success icon with animation
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color(red: 0.32, green: 0.57, blue: 0.87))
                        .scaleEffect(showConfetti ? 1.0 : 0.5)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showConfetti)
                    
                    // Hooray text
                    VStack(spacing: 16) {
                        Text("Hooray! 🎉")
                            .font(Font.custom(AppFontName.workSansMedium, size: 42))
                            .foregroundColor(.black)
                            .scaleEffect(showConfetti ? 1.0 : 0.8)
                            .opacity(showConfetti ? 1.0 : 0.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: showConfetti)
                        
                        Text("Congratulations on taking your first steps!")
                            .font(Font.custom(AppFontName.overpassVariable, size: 20).weight(.medium))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .opacity(showConfetti ? 1.0 : 0.0)
                            .offset(y: showConfetti ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: showConfetti)
                        
                        Text("You're on your way to building meaningful, lasting relationships.")
                            .font(Font.custom(AppFontName.overpassVariable, size: 16).weight(.medium))
                            .foregroundColor(.black.opacity(0.8))
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
                triggerSuccess(containerSize: size)
            }
        }
    }
    
    private func triggerSuccess(containerSize: CGSize) {
        // Trigger haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Show confetti animation
        withAnimation {
            showConfetti = true
        }
        
        // Generate confetti pieces using container size rather than UIScreen.main
        confettiPieces = (0..<50).map { _ in
            ConfettiPiece(containerSize: containerSize)
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

    init(containerSize: CGSize) {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
        self.color = colors.randomElement() ?? .blue
        self.startX = CGFloat.random(in: 0...max(containerSize.width, 0))
        self.startY = CGFloat.random(in: -100...0)
        self.endY = containerSize.height + 100
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
