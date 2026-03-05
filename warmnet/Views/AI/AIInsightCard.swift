//
//  AIInsightCard.swift
//  warmnet
//
//  Created on 31 January 2026.
//  Updated for AI Insights feature.
//

import SwiftUI
import SwiftData

struct AIInsightCard: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    
    /// The type of insight to generate
    let insightType: InsightType
    
    /// Callback when interaction ideas button is tapped
    let onInteractionIdeas: () -> Void
    
    /// Callback when network opportunity button is tapped
    let onNetworkOpportunity: () -> Void
    
    /// State for AI generation
    @State private var aiGenerator: AIInsightGenerator?
    @State private var insightText: String = ""
    @State private var isLoading = true
    @State private var hasError = false
    @State private var showChat = false
    
    // MARK: - Computed Properties
    
    private var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    private var buttonBackgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.20, green: 0.20, blue: 0.20) : Color(red: 0.90, green: 0.90, blue: 0.90)
    }
    
    private var buttonTextColor: Color {
        colorScheme == .dark ? Color(red: 0.60, green: 0.75, blue: 1.0) : Color(red: 0.19, green: 0.41, blue: 1)
    }
    
    private var iconColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 19) {
            // Insight text or loading state
            insightContentView
            
            // Action buttons
            actionButtonsRow
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
            HapticManager.impact(.light)
            showChat = true
        }
        .task {
            await loadInsight()
        }
        .sheet(isPresented: $showChat) {
            AIChatScreen(initialContext: insightType)
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var insightContentView: some View {
        if isLoading {
            ShimmerView()
                .frame(height: 60)
        } else if hasError {
            errorView
        } else {
            // Use lighter text color for AI insight body (matches home screen style)
            let contentColor = colorScheme == .dark ? Color.white.opacity(0.65) : Color.black.opacity(0.6)
            HStack(alignment: .top, spacing: 8) {
                Text(insightText)
                    .font(.custom(AppFontName.workSansMedium, size: 15))
                    .lineSpacing(4)
                    .foregroundColor(contentColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Tap to chat indicator
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var errorView: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Unable to generate insight")
                    .font(.custom(AppFontName.workSansMedium, size: 14))
                    .foregroundColor(textColor)
                
                Button("Tap to retry") {
                    HapticManager.notification(.warning)
                    Task {
                        await loadInsight()
                    }
                }
                .font(.custom(AppFontName.workSansRegular, size: 13))
                .foregroundColor(AppColors.mutedBlue)
            }
            
            Spacer()
        }
    }
    
    private var actionButtonsRow: some View {
        HStack(alignment: .top, spacing: 21) {
            Button {
                HapticManager.impact(.light)
                onInteractionIdeas()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "bubble.left.fill")
                        .font(.system(size: 14))
                        .foregroundColor(iconColor)
                        .frame(width: 25, height: 25)
                    
                    Text("Interaction ideas")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(buttonTextColor)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                .frame(maxWidth: .infinity, minHeight: 53)
                .background(buttonBackgroundColor)
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
            
            Button {
                HapticManager.impact(.light)
                onNetworkOpportunity()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 14))
                        .foregroundColor(iconColor)
                        .frame(width: 25, height: 25)
                    
                    Text("Network Opportunity")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(buttonTextColor)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                .frame(maxWidth: .infinity, minHeight: 53)
                .background(buttonBackgroundColor)
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Methods
    
    private func loadInsight() async {
        isLoading = true
        hasError = false
        
        // Initialize generator if needed
        if aiGenerator == nil {
            let contextService = AIContextService(modelContext: modelContext)
            aiGenerator = AIInsightGenerator(contextService: contextService)
        }
        
        do {
            let insight = try await aiGenerator?.generateInsight(type: insightType) ?? ""
            insightText = insight
            hasError = false
            HapticManager.notification(.success)
        } catch {
            hasError = true
            insightText = ""
            HapticManager.notification(.error)
        }
        
        isLoading = false
    }
}

// MARK: - Legacy Support

extension AIInsightCard {
    /// Legacy initializer for backwards compatibility
    /// Creates a card with static text (no AI generation)
    init(
        insightText: String,
        onInteractionIdeas: @escaping () -> Void,
        onNetworkOpportunity: @escaping () -> Void
    ) {
        self.insightType = .homeSummary
        self.onInteractionIdeas = onInteractionIdeas
        self.onNetworkOpportunity = onNetworkOpportunity
        self._insightText = State(initialValue: insightText)
        self._isLoading = State(initialValue: false)
    }
}

// MARK: - Preview

#Preview("Loading State") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, PersonalisationData.self, Interaction.self, configurations: config)
    
    return AIInsightCard(
        insightType: .homeSummary,
        onInteractionIdeas: { },
        onNetworkOpportunity: { }
    )
    .padding()
    .background(Color(red: 0xF1/255, green: 0xF2/255, blue: 0xF6/255))
    .modelContainer(container)
}

#Preview("Static Text (Legacy)") {
    AIInsightCard(
        insightText: "This month, you've focused on connecting with professionals in the biotech and AI sectors. The trend shows a growing interest in collaborative projects at the intersection of these fields.",
        onInteractionIdeas: { },
        onNetworkOpportunity: { }
    )
    .padding()
    .background(Color(red: 0xF1/255, green: 0xF2/255, blue: 0xF6/255))
}
