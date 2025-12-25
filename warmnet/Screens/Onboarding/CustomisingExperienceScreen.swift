//
//  CustomisingExperienceScreen.swift
//  warmnet
//
//  Created on 24 December 2025.
//

import SwiftUI

struct CustomisingExperienceScreen: View {
    @State private var progress: CGFloat = 0.0
    @State private var currentStep = 0
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    
    var onComplete: () -> Void = {}
    
    private let steps = [
        "Setting up your dashboard...",
        "Organizing your contacts...",
        "Preparing insights..."
    ]
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Title
                Text("Customising your experience")
                    .font(Font.custom("WorkSans-Medium", size: 32))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 32)
                
                // Animated processing indicator
                ZStack {
                    // Outer rotating rings
                    ForEach(0..<3) { index in
                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(
                                LinearGradient(
                                    colors: [.blue.opacity(0.7 - Double(index) * 0.2), .purple.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .frame(width: 100 + CGFloat(index * 35), height: 100 + CGFloat(index * 35))
                            .rotationEffect(.degrees(rotationAngle - Double(index * 120)))
                    }
                    
                    // Center icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.3), .purple.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 70, height: 70)
                            .scaleEffect(pulseScale)
                        
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 32))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                .frame(height: 200)
                
                // Progress section
                VStack(spacing: 16) {
                    Text(steps[currentStep])
                        .font(Font.custom("Overpass-Medium", size: 16))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        .id("step-\(currentStep)")
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(red: 0.32, green: 0.57, blue: 0.87))
                                .frame(width: geometry.size.width * progress, height: 8)
                        }
                    }
                    .frame(height: 8)
                    .padding(.horizontal, 50)
                    
                    Text("\(Int(progress * 100))%")
                        .font(Font.custom("Overpass-Medium", size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            startCustomisation()
        }
    }
    
    private func startCustomisation() {
        // Rotation animation for rings
        withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Pulse animation for center icon
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            pulseScale = 1.15
        }
        
        // Progress bar animation
        withAnimation(.easeInOut(duration: 2.5)) {
            progress = 1.0
        }
        
        // Update steps
        let stepDuration = 0.83 // 2.5 seconds / 3 steps
        for i in 0..<steps.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * stepDuration) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentStep = i
                }
            }
        }
        
        // Complete after 2.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            onComplete()
        }
    }
}

#Preview {
    CustomisingExperienceScreen()
}
