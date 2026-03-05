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
                HStack(alignment: .top) {
                    Text("Network Health")
                        .font(.custom(AppFontName.workSansMedium, size: 16))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }
                
                HStack(alignment: .top, spacing: 0) {
                    NetworkTierItem(
                        count: innerCircleCount,
                        label: "Close Network",
                        color: Priority.innerCircle.color,
                        iconName: "person.fill"
                    )
                    
                    NetworkTierItem(
                        count: keyRelationshipsCount,
                        label: "Middle Network",
                        color: Priority.keyRelationships.color,
                        iconName: "person.2.fill"
                    )
                    
                    NetworkTierItem(
                        count: broaderNetworkCount,
                        label: "Broader Network",
                        color: Priority.broaderNetwork.color,
                        iconName: "person.3.fill"
                    )
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.04), radius: 10, x: 0, y: 4)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Network Tier Item

struct NetworkTierItem: View {
    let count: Int
    let label: String
    let color: Color
    let iconName: String
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: iconName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(color)
                
                Text("\(count)")
                    .font(.custom(AppFontName.workSansMedium, size: 22))
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())
            }
            
            Text(label)
                .font(.custom(AppFontName.workSansRegular, size: 12))
                .foregroundStyle(.secondary)
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
