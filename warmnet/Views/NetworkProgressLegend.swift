//
//  NetworkProgressLegend.swift
//  warmnet
//
//  Created on 07/01/2026.
//

import SwiftUI

/// A single legend item showing colored dot and count
struct NetworkProgressLegendItem: View {
    @Environment(\.colorScheme) private var colorScheme
    let tierProgress: TierProgress
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(tierProgress.tier.color)
                .frame(width: 8, height: 8)
            
            Text(tierProgress.displayText)
                .font(.custom(AppFontName.workSansMedium, size: 13))
                .monospacedDigit()
                .foregroundStyle(colorScheme == .dark ? AppColors.textPrimary : .primary)
                .contentTransition(.numericText())
        }
    }
}

/// Legend row displaying all tier progress counts
struct NetworkProgressLegend: View {
    @Environment(\.colorScheme) private var colorScheme
    let tierProgresses: [TierProgress]
    
    /// Display order: Green → Blue → Yellow (Inner to Outer conceptually)
    private var orderedProgresses: [TierProgress] {
        let order: [Priority] = [.innerCircle, .keyRelationships, .broaderNetwork]
        return order.compactMap { tier in
            tierProgresses.first { $0.tier == tier }
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(orderedProgresses.enumerated()), id: \.element.id) { index, tierProgress in
                if index > 0 {
                    Text("•")
                        .foregroundStyle(colorScheme == .dark ? AppColors.textTertiary : .secondary)
                        .padding(.horizontal, 8)
                }
                
                NetworkProgressLegendItem(tierProgress: tierProgress)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        NetworkProgressLegend(
            tierProgresses: [
                TierProgress(id: .innerCircle, tier: .innerCircle, contacted: 5, total: 7, windowDays: 14),
                TierProgress(id: .keyRelationships, tier: .keyRelationships, contacted: 12, total: 15, windowDays: 60),
                TierProgress(id: .broaderNetwork, tier: .broaderNetwork, contacted: 23, total: 45, windowDays: 180)
            ]
        )
        
        NetworkProgressLegend(
            tierProgresses: [
                TierProgress(id: .innerCircle, tier: .innerCircle, contacted: 5, total: 7, windowDays: 14),
                TierProgress(id: .keyRelationships, tier: .keyRelationships, contacted: 12, total: 15, windowDays: 60)
            ]
        )
        
        NetworkProgressLegend(
            tierProgresses: [
                TierProgress(id: .innerCircle, tier: .innerCircle, contacted: 7, total: 7, windowDays: 14)
            ]
        )
    }
    .padding()
}
