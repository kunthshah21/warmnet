//
//  OverviewSectionView.swift
//  warmnet
//
//  Created on 31/01/2026.
//

import SwiftUI
import SwiftData

/// Overview section displaying Weekly Trend, Progress, and Network Health cards
struct OverviewSectionView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var onWeeklyTrendTap: (() -> Void)? = nil
    var onProgressTap: (() -> Void)? = nil
    var onNetworkHealthTap: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section title
            Text("Overview")
                .font(.custom(AppFontName.workSansMedium, size: 20))
                .foregroundStyle(.primary)
            
            // Top row: Weekly Trend and Progress cards side by side
            HStack(spacing: 12) {
                WeeklyTrendCard(onTap: onWeeklyTrendTap)
                
                ProgressCircleCard(onTap: onProgressTap)
            }
            
            // Bottom row: Network Health card (full width)
            NetworkHealthCard(onTap: onNetworkHealthTap)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, Interaction.self, configurations: config)
    
    return ZStack {
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
            OverviewSectionView()
                .padding(.horizontal, 20)
        }
    }
    .modelContainer(container)
}
