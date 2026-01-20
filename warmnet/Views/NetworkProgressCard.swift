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
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? AppColors.charcoal : Color(uiColor: .secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
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
        VStack(spacing: 16) {
            ConcentricProgressRings(tierProgresses: tierProgresses)
            
            NetworkProgressLegend(tierProgresses: tierProgresses)
        }
        .frame(maxWidth: .infinity)
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
