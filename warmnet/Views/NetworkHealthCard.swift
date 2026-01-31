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
                HStack(spacing: 0) {
                    NetworkTierItem(
                        count: innerCircleCount,
                        label: "Close Network",
                        color: AppColors.accentGreen
                    )
                    
                    Spacer()
                    
                    NetworkTierItem(
                        count: keyRelationshipsCount,
                        label: "Middle Network",
                        color: AppColors.mutedBlue
                    )
                    
                    Spacer()
                    
                    NetworkTierItem(
                        count: broaderNetworkCount,
                        label: "Broader Network",
                        color: .primary
                    )
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
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
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                // Network icon
                NetworkIcon()
                    .foregroundStyle(color)
                
                Text("\(count)")
                    .font(.custom(AppFontName.workSansMedium, size: 22))
                    .fontWeight(.bold)
                    .foregroundStyle(color)
                    .contentTransition(.numericText())
            }
            
            Text(label)
                .font(.custom(AppFontName.workSansRegular, size: 12))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
}

// MARK: - Network Icon

struct NetworkIcon: View {
    var body: some View {
        Image(systemName: "person.3.sequence.fill")
            .font(.system(size: 18))
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
