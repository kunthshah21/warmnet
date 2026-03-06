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
    
    // MARK: - Constants
    private let closeColor = Color(red: 0.17, green: 0.49, blue: 0.93) // Blue
    private let middleColor = Color(red: 0.05, green: 0.58, blue: 0.53) // Teal
    private let broaderColor = Color(red: 0.39, green: 0.45, blue: 0.55) // Gray
    
    // MARK: - Computed Properties
    private var innerCircleCount: Int {
        contacts.filter { $0.priority == .innerCircle }.count
    }
    
    private var keyRelationshipsCount: Int {
        contacts.filter { $0.priority == .keyRelationships }.count
    }
    
    private var broaderNetworkCount: Int {
        contacts.filter { $0.priority == .broaderNetwork }.count
    }
    
    private var totalCount: Int {
        innerCircleCount + keyRelationshipsCount + broaderNetworkCount
    }
    
    private var innerPercentage: Double {
        totalCount > 0 ? Double(innerCircleCount) / Double(totalCount) : 0
    }
    
    private var keyPercentage: Double {
        totalCount > 0 ? Double(keyRelationshipsCount) / Double(totalCount) : 0
    }
    
    private var broaderPercentage: Double {
        totalCount > 0 ? Double(broaderNetworkCount) / Double(totalCount) : 0
    }
    
    var body: some View {
        Button {
            HapticManager.impact(.light)
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Overview")
                            .font(.custom(AppFontName.workSansMedium, size: 14))
                            .tracking(0.70)
                            .foregroundStyle(.secondary)
                        
                        Text("Network Health")
                            .font(.custom(AppFontName.workSansMedium, size: 20))
                            .foregroundStyle(.primary)
                    }
                    
                    Spacer()
                    
                    Text("View All")
                        .font(.custom(AppFontName.workSansMedium, size: 14))
                        .foregroundStyle(closeColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(closeColor.opacity(0.10))
                        .clipShape(Capsule())
                }
                
                // Description
                Text("Your connections at a glance. You are\nmaintaining a healthy balance.")
                    .font(.custom(AppFontName.workSansRegular, size: 16))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Progress Bar & Percentages
                VStack(alignment: .leading, spacing: 8) {
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            if totalCount > 0 {
                                Rectangle()
                                    .fill(closeColor)
                                    .frame(width: geometry.size.width * innerPercentage)
                                
                                Rectangle()
                                    .fill(middleColor)
                                    .frame(width: geometry.size.width * keyPercentage)
                                
                                Rectangle()
                                    .fill(broaderColor)
                                    .frame(width: geometry.size.width * broaderPercentage)
                            } else {
                                Rectangle()
                                    .fill(Color.secondary.opacity(0.2))
                            }
                        }
                    }
                    .frame(height: 12)
                    .clipShape(Capsule())
                    
                    HStack {
                        if totalCount > 0 {
                            if innerPercentage > 0 {
                                Text("\(Int(innerPercentage * 100))%")
                            }
                            Spacer()
                            if keyPercentage > 0 {
                                Text("\(Int(keyPercentage * 100))%")
                            }
                            Spacer()
                            if broaderPercentage > 0 {
                                Text("\(Int(broaderPercentage * 100))%")
                            }
                        } else {
                            Text("0%")
                        }
                    }
                    .font(.custom(AppFontName.workSansRegular, size: 12))
                    .foregroundStyle(.secondary)
                }
                
                // Legend / Stats
                HStack(spacing: 0) {
                    statView(label: "Close", count: innerCircleCount, color: closeColor)
                    
                    Divider()
                        .frame(height: 32)
                        .padding(.horizontal, 8)
                    
                    statView(label: "Middle", count: keyRelationshipsCount, color: middleColor)
                    
                    Divider()
                        .frame(height: 32)
                        .padding(.horizontal, 8)
                    
                    statView(label: "Broader", count: broaderNetworkCount, color: broaderColor)
                }
            }
            .padding(20)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(20)
            .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.04), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
    
    private func statView(label: String, count: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                
                Text(label)
                    .font(.custom(AppFontName.workSansMedium, size: 12))
                    .foregroundStyle(.secondary)
            }
            
            Text("\(count)")
                .font(.custom(AppFontName.workSansMedium, size: 18))
                .foregroundStyle(.primary)
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
