//
//  WeeklyTrendAIInsightView.swift
//  warmnet
//
//  Created for Weekly Trend Insights feature.
//

import SwiftUI
import SwiftData

/// View component for displaying AI-generated trend insights
/// 
/// This view handles loading states, error display, and refresh functionality
/// for the AI insights section in the Weekly Trend detail sheet.
struct WeeklyTrendAIInsightView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    
    /// Current time period selection
    let timePeriod: TrendTimePeriod
    
    /// Trend data to analyze
    let trendData: [TrendDayInfo]
    
    /// AI insight service for generating insights
    @State private var insightService: WeeklyTrendInsightService?
    
    /// Current insight text
    @State private var insight: String?
    
    /// Loading state
    @State private var isLoading: Bool = false
    
    /// Error state
    @State private var errorMessage: String?
    
    /// Track if initial load has occurred
    @State private var hasLoaded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with title and refresh button
            HStack {
                Text("AI Insights")
                    .font(.custom(AppFontName.workSansMedium, size: 16))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                // Refresh button
                Button {
                    Task {
                        await loadInsight()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isLoading ? 360 : 0))
                        .animation(
                            isLoading ? .linear(duration: 1).repeatForever(autoreverses: false) : .default,
                            value: isLoading
                        )
                }
                .disabled(isLoading)
                .buttonStyle(.plain)
            }
            
            // Content area
            Group {
                if isLoading && insight == nil {
                    // Loading shimmer
                    LoadingShimmerView()
                } else if let errorMessage = errorMessage {
                    // Error state
                    ErrorStateView(
                        message: errorMessage,
                        onRetry: {
                            Task {
                                await loadInsight()
                            }
                        }
                    )
                } else if let insight = insight {
                    // Insight text
                    Text(insight)
                        .font(.custom(AppFontName.workSansRegular, size: 14))
                        .foregroundStyle(.secondary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    // Empty state
                    Text("Tap refresh to generate AI insights about your trends.")
                        .font(.custom(AppFontName.workSansRegular, size: 14))
                        .foregroundStyle(.tertiary)
                        .italic()
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6).opacity(0.5))
        )
        .onAppear {
            setupService()
            if !hasLoaded {
                Task {
                    await loadInsight()
                    hasLoaded = true
                }
            }
        }
        .onChange(of: timePeriod) { _, _ in
            // Reload insight when time period changes
            Task {
                await loadInsight()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupService() {
        if insightService == nil {
            insightService = WeeklyTrendInsightService(modelContext: modelContext)
        }
    }
    
    private func loadInsight() async {
        guard let service = insightService else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await service.generateTrendInsight(
                for: timePeriod,
                trendData: trendData
            )
            insight = result
        } catch {
            errorMessage = "Unable to generate insights. Please try again."
        }
        
        isLoading = false
    }
}

// MARK: - Loading Shimmer View

private struct LoadingShimmerView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            WeeklyTrendShimmerLine(width: 0.95)
            WeeklyTrendShimmerLine(width: 0.85)
            WeeklyTrendShimmerLine(width: 0.75)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

private struct WeeklyTrendShimmerLine: View {
    let width: CGFloat
    @State private var isAnimating = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(
                LinearGradient(
                    colors: [
                        Color.gray.opacity(0.2),
                        Color.gray.opacity(0.3),
                        Color.gray.opacity(0.2)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .scaleEffect(x: width, anchor: .leading)
            .opacity(isAnimating ? 0.6 : 1.0)
            .animation(
                .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

// MARK: - Error State View

private struct ErrorStateView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 14))
                    .foregroundStyle(.orange)
                
                Text(message)
                    .font(.custom(AppFontName.workSansRegular, size: 14))
                    .foregroundStyle(.secondary)
            }
            
            Button {
                onRetry()
            } label: {
                Text("Try Again")
                    .font(.custom(AppFontName.workSansMedium, size: 13))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppColors.mutedBlue)
                    )
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Contact.self,
        Interaction.self,
        PersonalisationData.self,
        configurations: config
    )
    
    return VStack {
        WeeklyTrendAIInsightView(
            timePeriod: .weekly,
            trendData: [
                TrendDayInfo(date: Date(), count: 3),
                TrendDayInfo(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, count: 2),
                TrendDayInfo(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, count: 5)
            ]
        )
        .padding()
    }
    .modelContainer(container)
}
