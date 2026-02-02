//
//  WeeklyTrendCard.swift
//  warmnet
//
//  Created on 31/01/2026.
//

import SwiftUI
import SwiftData

/// Card displaying weekly interaction trend with a bar chart visualization
/// Tapping opens a detail sheet with time filters and AI insights
struct WeeklyTrendCard: View {
    @Environment(\.colorScheme) private var colorScheme
    @Query private var interactions: [Interaction]
    
    /// Sheet presentation state
    @State private var showDetailSheet: Bool = false
    
    var onTap: (() -> Void)? = nil
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    // Get the last 4 weeks of daily interaction data
    private var weeklyData: [DayData] {
        let today = calendar.startOfDay(for: Date())
        var data: [DayData] = []
        
        // Go back 28 days (4 weeks)
        for dayOffset in (0..<28).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? date
            
            let count = interactions.filter { interaction in
                interaction.date >= dayStart && interaction.date < dayEnd
            }.count
            
            data.append(DayData(date: date, count: count))
        }
        
        return data
    }
    
    /// Convert DayData to TrendDayInfo for the detail sheet
    private var trendDataForSheet: [TrendDayInfo] {
        weeklyData.map { TrendDayInfo(date: $0.date, count: $0.count) }
    }
    
    private var maxCount: Int {
        max(weeklyData.map { $0.count }.max() ?? 1, 1)
    }
    
    var body: some View {
        Button {
            showDetailSheet = true
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                // Header with title and arrow
                HStack {
                    Text("Weekly Trend")
                        .font(.custom(AppFontName.workSansMedium, size: 18))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(Circle().fill(Color.white.opacity(0.2)))
                }
                
                Spacer()
                
                // Bar chart
                HStack(alignment: .bottom, spacing: 3) {
                    ForEach(weeklyData) { day in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.9))
                            .frame(width: 4, height: barHeight(for: day.count))
                    }
                }
                .frame(height: 60)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.mutedBlue)
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDetailSheet) {
            WeeklyTrendDetailSheet(trendData: trendDataForSheet)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    private func barHeight(for count: Int) -> CGFloat {
        let minHeight: CGFloat = 8
        let maxHeight: CGFloat = 60
        
        guard maxCount > 0 else { return minHeight }
        
        let proportion = CGFloat(count) / CGFloat(maxCount)
        return minHeight + (proportion * (maxHeight - minHeight))
    }
}

// MARK: - Supporting Types

struct DayData: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, Interaction.self, configurations: config)
    
    return ZStack {
        Color.gray.opacity(0.1)
            .ignoresSafeArea()
        
        WeeklyTrendCard()
            .padding()
    }
    .modelContainer(container)
}
