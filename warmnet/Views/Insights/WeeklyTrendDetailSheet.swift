//
//  WeeklyTrendDetailSheet.swift
//  warmnet
//
//  Created for Weekly Trend Insights feature.
//

import SwiftUI
import SwiftData

/// Detail sheet displaying comprehensive weekly trend analysis
///
/// This sheet presents:
/// - Time period filter (Daily/Weekly toggle)
/// - Enhanced bar chart visualization
/// - Key statistics (total, average, best day)
/// - AI-powered insights section
///
/// Follows the MV (Model-View) architecture pattern and mirrors
/// the design of NetworkCoverageDetailSheet for consistency.
struct WeeklyTrendDetailSheet: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    /// Trend data passed from WeeklyTrendCard
    let trendData: [TrendDayInfo]
    
    /// Selected time period filter
    @State private var selectedPeriod: TrendTimePeriod = .weekly
    
    /// Filtered data based on selected period
    private var filteredData: [TrendDayInfo] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let cutoffDate = calendar.date(byAdding: .day, value: -selectedPeriod.lookbackDays, to: today) ?? today
        
        return trendData.filter { $0.date >= cutoffDate }
    }
    
    /// Maximum count for chart scaling
    private var maxCount: Int {
        max(filteredData.map { $0.count }.max() ?? 1, 1)
    }
    
    /// Total connections in the period
    private var totalConnections: Int {
        filteredData.reduce(0) { $0 + $1.count }
    }
    
    /// Average connections per day
    private var averagePerDay: Double {
        filteredData.isEmpty ? 0.0 : Double(totalConnections) / Double(filteredData.count)
    }
    
    /// Best performing day
    private var bestDay: TrendDayInfo? {
        filteredData.max { $0.count < $1.count }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Time Period Filter
                timePeriodFilter
                
                // Chart Section
                chartSection
                
                // Statistics Section
                statsSection
                
                // AI Insights Section
                WeeklyTrendAIInsightView(
                    timePeriod: selectedPeriod,
                    trendData: filteredData
                )
                
                Spacer(minLength: 20)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .scrollContentBackground(.visible)
        .background(colorScheme == .dark ? Color(.systemBackground) : Color(.systemBackground))
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        Text("Weekly Trends")
            .font(.custom(AppFontName.workSansMedium, size: 22))
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 8)
    }
    
    // MARK: - Time Period Filter
    
    private var timePeriodFilter: some View {
        HStack(spacing: 0) {
            ForEach(TrendTimePeriod.allCases, id: \.self) { period in
                Button {
                    HapticManager.selection()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedPeriod = period
                    }
                } label: {
                    Text(period.displayName)
                        .font(.custom(AppFontName.workSansMedium, size: 14))
                        .foregroundStyle(selectedPeriod == period ? .white : .primary)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selectedPeriod == period ? AppColors.mutedBlue : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
        )
    }
    
    // MARK: - Chart Section
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Chart title
            Text(selectedPeriod == .daily ? "Last 7 Days" : "Last 4 Weeks")
                .font(.custom(AppFontName.workSansMedium, size: 14))
                .foregroundStyle(.secondary)
            
            // Bar chart
            HStack(alignment: .bottom, spacing: selectedPeriod == .daily ? 12 : 4) {
                ForEach(filteredData) { day in
                    VStack(spacing: 6) {
                        // Bar
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppColors.mutedBlue)
                            .frame(width: selectedPeriod == .daily ? 32 : 6, height: barHeight(for: day.count))
                        
                        // Date label (only for daily view)
                        if selectedPeriod == .daily {
                            Text(day.formattedDate)
                                .font(.custom(AppFontName.workSansRegular, size: 11))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .frame(height: 140)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6).opacity(0.5))
        )
    }
    
    // MARK: - Statistics Section
    
    private var statsSection: some View {
        HStack(spacing: 12) {
            // Total Connections
            StatCard(
                title: "Total",
                value: "\(totalConnections)",
                icon: "person.2.fill"
            )
            .frame(maxWidth: .infinity)
            
            // Average per Day
            StatCard(
                title: "Avg/Day",
                value: String(format: "%.1f", averagePerDay),
                icon: "chart.bar.fill"
            )
            .frame(maxWidth: .infinity)
            
            // Best Day
            StatCard(
                title: "Best Day",
                value: bestDay?.formattedDate ?? "-",
                subtitle: bestDay != nil ? "\(bestDay!.count)" : nil,
                icon: "star.fill"
            )
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Helper Methods
    
    private func barHeight(for count: Int) -> CGFloat {
        let minHeight: CGFloat = 8
        let maxHeight: CGFloat = 100
        
        guard maxCount > 0 else { return minHeight }
        
        let proportion = CGFloat(count) / CGFloat(maxCount)
        return minHeight + (proportion * (maxHeight - minHeight))
    }
}

// MARK: - Stat Card Component

private struct StatCard: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let title: String
    let value: String
    var subtitle: String? = nil
    let icon: String
    
    /// Fixed height so all three cards match (Best Day has two value lines)
    private let cardContentHeight: CGFloat = 72
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(AppColors.mutedBlue)
            
            // Value + optional subtitle in a fixed-height block so cards stay equal
            VStack(spacing: 2) {
                Text(value)
                    .font(.custom(AppFontName.workSansMedium, size: 20))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.custom(AppFontName.workSansRegular, size: 12))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: cardContentHeight)
            
            Text(title)
                .font(.custom(AppFontName.workSansRegular, size: 12))
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6).opacity(0.5))
        )
    }
}

// MARK: - Preview

#Preview {
    let calendar = Calendar.current
    let today = Date()
    
    // Generate sample data for 28 days
    let sampleData: [TrendDayInfo] = (0..<28).map { dayOffset in
        let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
        let count = Int.random(in: 0...5)
        return TrendDayInfo(date: date, count: count)
    }.reversed()
    
    return WeeklyTrendDetailSheet(trendData: sampleData)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
}
