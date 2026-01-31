//
//  NetworkProgressCard.swift
//  warmnet
//
//  Created on 07/01/2026.
//

import SwiftUI
import SwiftData

/// Card displaying network coverage progress with Apple Watch-style rings
struct NetworkProgressCard: View {
    @Environment(\.colorScheme) private var colorScheme
    @Query private var contacts: [Contact]
    @Query private var interactions: [Interaction]
    
    @State private var tierProgresses: [TierProgress] = []
    @State private var isLoading: Bool = true
    @State private var completedTiersThisSession: Set<Priority> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Network Coverage")
                .font(.custom(AppFontName.workSansMedium, size: 16))
                .foregroundStyle(colorScheme == .dark ? AppColors.textSecondary : .secondary)
            
            if isLoading {
                loadingView
            } else if tierProgresses.isEmpty {
                emptyStateView
            } else {
                progressContent
            }
        }
        .padding(20)
        .onAppear {
            calculateProgress()
        }
        .onChange(of: contacts.count) { _, _ in
            calculateProgress()
        }
        .onChange(of: interactions.count) { _, _ in
            // Recalculate when interactions change
            calculateProgress()
        }
    }
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        HStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
                .tint(AppColors.mutedBlue)
            Spacer()
        }
        .frame(height: 140)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.3")
                .font(.title)
                .foregroundStyle(colorScheme == .dark ? AppColors.textTertiary : .secondary)
            
            Text("Add contacts to track progress")
                .font(.custom(AppFontName.workSansRegular, size: 14))
                .foregroundStyle(colorScheme == .dark ? AppColors.textSecondary : .secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
    }
    
    private var progressContent: some View {
        VStack(spacing: 20) {
            // Concentric rings with center percentage
            ZStack {
                ConcentricProgressRings(tierProgresses: tierProgresses)
                
                // Overall completion percentage in the center
                VStack(spacing: 2) {
                    Text("\(Int(overallProgress * 100))%")
                        .font(.custom(AppFontName.workSansMedium, size: 24))
                        .foregroundStyle(colorScheme == .dark ? AppColors.textPrimary : .primary)
                    
                    Text("Coverage")
                        .font(.custom(AppFontName.workSansRegular, size: 11))
                        .foregroundStyle(colorScheme == .dark ? AppColors.textTertiary : .secondary)
                }
            }
            
            // Detailed tier breakdown
            VStack(spacing: 12) {
                ForEach(orderedTierProgresses) { tierProgress in
                    TierProgressRow(tierProgress: tierProgress)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var overallProgress: Double {
        guard !tierProgresses.isEmpty else { return 0 }
        let totalContacted = tierProgresses.reduce(0) { $0 + $1.contacted }
        let totalExpected = tierProgresses.reduce(0) { $0 + $1.total }
        guard totalExpected > 0 else { return 0 }
        return Double(totalContacted) / Double(totalExpected)
    }
    
    private var orderedTierProgresses: [TierProgress] {
        let order: [Priority] = [.innerCircle, .keyRelationships, .broaderNetwork]
        return order.compactMap { tier in
            tierProgresses.first { $0.tier == tier }
        }
    }
    
    // MARK: - Progress Calculation
    
    private func calculateProgress() {
        // Brief delay for loading animation
        if isLoading {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                updateProgress()
                withAnimation(.easeOut(duration: 0.2)) {
                    isLoading = false
                }
            }
        } else {
            updateProgress()
        }
    }
    
    private func updateProgress() {
        let previousProgresses = tierProgresses
        let newProgresses = NetworkProgressService.calculateAllProgress(contacts: contacts)
        
        // Check for newly completed tiers and trigger haptic
        for newProgress in newProgresses {
            _ = previousProgresses.first { $0.tier == newProgress.tier }?.isComplete ?? false
            let isNowComplete = newProgress.isComplete
            let alreadyTriggeredThisSession = completedTiersThisSession.contains(newProgress.tier)
            
            if isNowComplete && !alreadyTriggeredThisSession {
                // Trigger haptic for first-time completion this session
                triggerCompletionHaptic()
                completedTiersThisSession.insert(newProgress.tier)
            }
        }
        
        tierProgresses = newProgresses
    }
    
    private func triggerCompletionHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}

// MARK: - Tier Progress Row

struct TierProgressRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let tierProgress: TierProgress
    
    private var tierName: String {
        switch tierProgress.tier {
        case .innerCircle: return "Close Network"
        case .keyRelationships: return "Middle Network"
        case .broaderNetwork: return "Broader Network"
        }
    }
    
    private var windowText: String {
        "Every \(tierProgress.windowDays) days"
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Colored indicator
            Circle()
                .fill(tierProgress.tier.color)
                .frame(width: 10, height: 10)
            
            // Tier name and window
            VStack(alignment: .leading, spacing: 2) {
                Text(tierName)
                    .font(.custom(AppFontName.workSansMedium, size: 14))
                    .foregroundStyle(colorScheme == .dark ? AppColors.textPrimary : .primary)
                
                Text(windowText)
                    .font(.custom(AppFontName.workSansRegular, size: 11))
                    .foregroundStyle(colorScheme == .dark ? AppColors.textTertiary : .secondary)
            }
            
            Spacer()
            
            // Progress fraction and percentage
            VStack(alignment: .trailing, spacing: 2) {
                Text(tierProgress.displayText)
                    .font(.custom(AppFontName.workSansMedium, size: 14))
                    .monospacedDigit()
                    .foregroundStyle(colorScheme == .dark ? AppColors.textPrimary : .primary)
                    .contentTransition(.numericText())
                
                Text("\(Int(tierProgress.progress * 100))%")
                    .font(.custom(AppFontName.workSansRegular, size: 11))
                    .foregroundStyle(tierProgress.isComplete ? tierProgress.tier.color : (colorScheme == .dark ? AppColors.textTertiary : .secondary))
                    .contentTransition(.numericText())
            }
        }
        .padding(.horizontal, 4)
    }
}

#Preview {
    ZStack {
        AppColors.deepNavy
            .ignoresSafeArea()
        
        VStack(spacing: 20) {
            NetworkProgressCard()
        }
        .padding()
    }
}
