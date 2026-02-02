//
//  ProgressCircleCard.swift
//  warmnet
//
//  Created on 31/01/2026.
//

import SwiftUI
import SwiftData

/// Card displaying network coverage progress with concentric ring visualization
/// Tapping opens a popup with detailed statistics
struct ProgressCircleCard: View {
    @Environment(\.colorScheme) private var colorScheme
    @Query private var contacts: [Contact]
    @Query private var interactions: [Interaction]
    
    @State private var showDetailSheet: Bool = false
    @State private var tierProgresses: [TierProgress] = []
    @State private var completedTiersThisSession: Set<Priority> = []
    
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button {
            showDetailSheet = true
            onTap?()
        } label: {
            VStack(alignment: .center, spacing: 8) {
                // Header with title and expand indicator
                HStack {
                    Text("Network Coverage")
                        .font(.custom(AppFontName.workSansMedium, size: 18))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary.opacity(0.6))
                }
                
                // Compact view with rings
                VStack {
                    Spacer(minLength: 0)
                    
                    HStack {
                        Spacer()
                        NetworkCoverageRings(tierProgresses: tierProgresses, size: 90)
                        Spacer()
                    }
                    
                    Spacer(minLength: 0)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.85, green: 0.82, blue: 0.95)) // Lavender/purple tint
            )
        }
        .buttonStyle(.plain)
        .onAppear {
            calculateProgress()
        }
        .onChange(of: contacts.count) { _, _ in
            calculateProgress()
        }
        .onChange(of: interactions.count) { _, _ in
            calculateProgress()
        }
        .sheet(isPresented: $showDetailSheet) {
            NetworkCoverageDetailSheet(tierProgresses: tierProgresses)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Progress Calculation
    
    private func calculateProgress() {
        let newProgresses = NetworkProgressService.calculateAllProgress(contacts: contacts)
        
        // Check for newly completed tiers and trigger haptic
        for newProgress in newProgresses {
            let isNowComplete = newProgress.isComplete
            let alreadyTriggeredThisSession = completedTiersThisSession.contains(newProgress.tier)
            
            if isNowComplete && !alreadyTriggeredThisSession {
                triggerCompletionHaptic()
                completedTiersThisSession.insert(newProgress.tier)
            }
        }
        
        withAnimation(.easeOut(duration: 0.3)) {
            tierProgresses = newProgresses
        }
    }
    
    private func triggerCompletionHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}

// MARK: - Network Coverage Detail Sheet (Popup)

struct NetworkCoverageDetailSheet: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    let tierProgresses: [TierProgress]
    
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
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            Text("Network Coverage")
                .font(.custom(AppFontName.workSansMedium, size: 22))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 8)
            
            // Concentric rings with center percentage
            ZStack {
                NetworkCoverageRings(tierProgresses: tierProgresses, size: 140)
                
                // Overall completion percentage in the center
                VStack(spacing: 2) {
                    Text("\(Int(overallProgress * 100))%")
                        .font(.custom(AppFontName.workSansMedium, size: 28))
                        .foregroundStyle(.primary)
                    
                    Text("Coverage")
                        .font(.custom(AppFontName.workSansRegular, size: 12))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 8)
            
            // Detailed tier breakdown
            if !tierProgresses.isEmpty {
                VStack(spacing: 16) {
                    ForEach(orderedTierProgresses) { tierProgress in
                        NetworkCoverageTierRow(tierProgress: tierProgress)
                    }
                }
                .padding(.horizontal, 8)
            } else {
                // Empty state
                VStack(spacing: 12) {
                    Image(systemName: "person.3")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    
                    Text("Add contacts to track progress")
                        .font(.custom(AppFontName.workSansRegular, size: 16))
                        .foregroundStyle(.secondary)
                }
                .frame(height: 100)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .background(colorScheme == .dark ? Color(.systemBackground) : Color(.systemBackground))
    }
}

// MARK: - Network Coverage Rings (Reusable)

struct NetworkCoverageRings: View {
    let tierProgresses: [TierProgress]
    var size: CGFloat = 120
    
    private var lineWidth: CGFloat {
        size >= 100 ? 12 : 10
    }
    
    private var ringGap: CGFloat {
        size >= 100 ? 16 : 12
    }
    
    /// Order for rendering: outer to inner (Broader → Key → Inner)
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
                let ringSize = size - (CGFloat(ringIndex) * ringGap * 2)
                
                NetworkCoverageRingView(
                    progress: tierProgress.progress,
                    color: tierProgress.tier.color,
                    lineWidth: lineWidth,
                    size: ringSize
                )
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Single Ring View

struct NetworkCoverageRingView: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat
    let size: CGFloat
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(color.opacity(0.3), lineWidth: lineWidth)
            
            // Progress arc
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.spring(duration: 1.0, bounce: 0.3)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.spring(duration: 0.6, bounce: 0.2)) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Tier Progress Row for Expanded View

struct NetworkCoverageTierRow: View {
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
                    .foregroundStyle(.primary)
                
                Text(windowText)
                    .font(.custom(AppFontName.workSansRegular, size: 11))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Progress fraction and percentage
            VStack(alignment: .trailing, spacing: 2) {
                Text(tierProgress.displayText)
                    .font(.custom(AppFontName.workSansMedium, size: 14))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())
                
                Text("\(Int(tierProgress.progress * 100))%")
                    .font(.custom(AppFontName.workSansRegular, size: 11))
                    .foregroundStyle(tierProgress.isComplete ? tierProgress.tier.color : .secondary)
                    .contentTransition(.numericText())
            }
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        LinearGradient(
            stops: [
                .init(color: Color("Top"), location: 0.0),
                .init(color: Color("Middle"), location: 0.15),
                .init(color: Color("Bottom"), location: 0.35)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        ScrollView {
            VStack(spacing: 20) {
                ProgressCircleCard()
                    .padding(.horizontal)
            }
            .padding(.top, 40)
        }
    }
}
