//
//  NetworkHealthCard.swift
//  warmnet
//
//  Created on 31/01/2026.
//

import SwiftUI
import SwiftData

/// Card displaying network health with tier counts
struct NetworkHealthCard: View {
    @Environment(\.colorScheme) private var colorScheme
    @Query private var contacts: [Contact]
    
    var onTap: (() -> Void)? = nil
    
    private var innerCircleCount: Int {
        contacts.filter { $0.priority == .innerCircle }.count
    }
    
    private var keyRelationshipsCount: Int {
        contacts.filter { $0.priority == .keyRelationships }.count
    }
    
    private var broaderNetworkCount: Int {
        contacts.filter { $0.priority == .broaderNetwork }.count
    }
    
    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                // Header with title and arrow
                HStack {
                    Text("Network Health")
                        .font(.custom(AppFontName.workSansMedium, size: 18))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                        .padding(8)
                        .background(Circle().fill(Color.black.opacity(0.1)))
                }
                
                // Network tier counts
                HStack(alignment: .top, spacing: 0) {
                    NetworkTierItem(
                        count: innerCircleCount,
                        label: "Close Network",
                        color: Color(red: 0.2, green: 0.55, blue: 0.45),
                        iconName: "person.fill"
                    )
                    
                    NetworkTierItem(
                        count: keyRelationshipsCount,
                        label: "Middle Network",
                        color: Color(red: 0.25, green: 0.4, blue: 0.65),
                        iconName: "person.2.fill"
                    )
                    
                    NetworkTierItem(
                        count: broaderNetworkCount,
                        label: "Broader Network",
                        color: Color(red: 0.72, green: 0.58, blue: 0.2),
                        iconName: "person.3.fill"
                    )
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? AppColors.charcoal : Color(uiColor: .secondarySystemGroupedBackground))
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Network Tier Item

struct NetworkTierItem: View {
    @Environment(\.colorScheme) private var colorScheme
    let count: Int
    let label: String
    let color: Color
    let iconName: String
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(color)
                
                Text("\(count)")
                    .font(.custom(AppFontName.workSansMedium, size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(color)
                    .contentTransition(.numericText())
            }
            
            Text(label)
                .font(.custom(AppFontName.workSansMedium, size: 11))
                .fontWeight(.bold)
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.1)
            .ignoresSafeArea()
        
        NetworkHealthCard()
            .padding()
    }
}
