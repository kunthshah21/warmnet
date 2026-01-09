//
//  PersonalisingLoadingScreen.swift
//  warmnet
//
//  Created on 24 December 2025.
//

import SwiftUI

struct PersonalisingLoadingScreen: View {
    @State private var progress: CGFloat = 0.0
    @State private var currentStep = 0
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    
    var onComplete: () -> Void = {}
    
    private let steps = [
        "Analyzing your preferences...",
        "Building your network graph...",
        "Personalizing your experience...",
        "Almost ready..."
    ]
    
    var body: some View {
        ZStack {
            // Background - Black
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Main title
                Text("WarmNet")
                    .font(Font.custom(AppFontName.workSansMedium, size: 36))
                    .foregroundColor(.black)
                    .padding(.bottom, 8)
                
                // Animated processing indicator
                ZStack {
                    // Outer rotating circles
                    ForEach(0..<3) { index in
                        Circle()
                            .stroke(
                                Color(red: 0.32, green: 0.57, blue: 0.87).opacity(0.6),
                                lineWidth: 3
                            )
                            .frame(width: 120 + CGFloat(index * 30), height: 120 + CGFloat(index * 30))
                            .rotationEffect(.degrees(rotationAngle + Double(index * 120)))
                            .opacity(0.6 - Double(index) * 0.15)
                    }
                    
                    // Center pulsing icon
                    Image(systemName: "sparkles")
                        .font(.system(size: 36))
                        .foregroundColor(Color(red: 0.32, green: 0.57, blue: 0.87))
                        .scaleEffect(pulseScale)
                }
                .frame(height: 200)
                
                // Progress text
                VStack(spacing: 12) {
                    Text(steps[currentStep])
                        .font(Font.custom(AppFontName.overpassVariable, size: 18).weight(.medium))
                        .foregroundColor(.black)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        .id("step-\(currentStep)")
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(red: 0.32, green: 0.57, blue: 0.87))
                                .frame(width: geometry.size.width * progress, height: 8)
                        }
                    }
                    .frame(height: 8)
                    .padding(.horizontal, 60)
                    
                    Text("\(Int(progress * 100))%")
                        .font(Font.custom(AppFontName.overpassVariable, size: 14).weight(.medium))
                        .foregroundColor(.black.opacity(0.7))
                }
                
                Spacer()
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            startProcessing()
        }
    }
    
    private func startProcessing() {
        // Rotation animation for circles
        withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Pulse animation for center icon
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            pulseScale = 1.2
        }
        
        // Progress bar animation
        withAnimation(.easeInOut(duration: 5.0)) {
            progress = 1.0
        }
        
        // Update steps
        let stepDuration = 1.25 // 5 seconds / 4 steps
        for i in 0..<steps.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * stepDuration) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentStep = i
                }
            }
        }
        
        // Complete after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            onComplete()
        }
    }
}

#Preview {
    PersonalisingLoadingScreen()
}
