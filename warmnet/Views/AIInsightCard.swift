//
//  AIInsightCard.swift
//  warmnet
//
//  Created on 31 January 2026.
//

import SwiftUI

struct AIInsightCard: View {
    let insightText: String
    let onInteractionIdeas: () -> Void
    let onNetworkOpportunity: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 19) {
            Text(insightText)
                .font(.system(size: 15, weight: .medium))
                .lineSpacing(4)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(alignment: .top, spacing: 21) {
                Button {
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
                
                Button {
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
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    AIInsightCard(
        insightText: "This month, you've focused on connecting with professionals in the biotech and AI sectors. The trend shows a growing interest in collaborative projects at the intersection of these fields.",
        onInteractionIdeas: { print("Interaction ideas tapped") },
        onNetworkOpportunity: { print("Network opportunity tapped") }
    )
    .padding()
    .background(Color(red: 0xF1/255, green: 0xF2/255, blue: 0xF6/255))
}
