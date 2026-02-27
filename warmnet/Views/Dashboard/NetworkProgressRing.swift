//
//  NetworkProgressRing.swift
//  warmnet
//
//  Created on 07/01/2026.
//

import SwiftUI

/// A single animated progress ring with configurable size and color
struct NetworkProgressRing: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat
    let size: CGFloat
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(
                    color.opacity(0.2),
                    lineWidth: lineWidth
                )
            
            // Progress arc
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.spring(duration: 1.0, bounce: 0.3)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { oldValue, newValue in
            withAnimation(.spring(duration: 0.6, bounce: 0.2)) {
                animatedProgress = newValue
            }
        }
    }
}

/// Concentric progress rings displaying multiple tiers
struct ConcentricProgressRings: View {
    let tierProgresses: [TierProgress]
    
    private let baseSize: CGFloat = 120
    private let lineWidth: CGFloat = 12
    private let ringGap: CGFloat = 16
    
    /// Order for rendering: outer to inner (Yellow → Blue → Green)
    private var orderedProgresses: [TierProgress] {
        let order: [Priority] = [.broaderNetwork, .keyRelationships, .innerCircle]
        return order.compactMap { tier in
            tierProgresses.first { $0.tier == tier }
        }
    }
    
    var body: some View {
        ZStack {
            ForEach(Array(orderedProgresses.enumerated()), id: \.element.id) { index, tierProgress in
                let ringIndex = orderedProgresses.count - 1 - index
                let size = baseSize - (CGFloat(ringIndex) * ringGap * 2)
                
                NetworkProgressRing(
                    progress: tierProgress.progress,
                    color: tierProgress.tier.color,
                    lineWidth: lineWidth,
                    size: size
                )
            }
        }
        .frame(width: baseSize, height: baseSize)
    }
}

#Preview {
    VStack(spacing: 40) {
        // Single ring
        NetworkProgressRing(
            progress: 0.7,
            color: .green,
            lineWidth: 12,
            size: 80
        )
        
        // Multiple rings
        ConcentricProgressRings(
            tierProgresses: [
                TierProgress(id: .innerCircle, tier: .innerCircle, contacted: 5, total: 7, windowDays: 14),
                TierProgress(id: .keyRelationships, tier: .keyRelationships, contacted: 12, total: 15, windowDays: 60),
                TierProgress(id: .broaderNetwork, tier: .broaderNetwork, contacted: 23, total: 45, windowDays: 180)
            ]
        )
        
        // Two rings only (no broader network)
        ConcentricProgressRings(
            tierProgresses: [
                TierProgress(id: .innerCircle, tier: .innerCircle, contacted: 5, total: 7, windowDays: 14),
                TierProgress(id: .keyRelationships, tier: .keyRelationships, contacted: 12, total: 15, windowDays: 60)
            ]
        )
    }
    .padding()
}
