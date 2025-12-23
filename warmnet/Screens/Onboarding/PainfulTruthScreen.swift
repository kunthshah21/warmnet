//
//  PainfulTruthScreen.swift
//  warmnet
//
//  Created on 24 December 2025.
//

import SwiftUI

struct PainfulTruthScreen: View {
    var onShowMeHow: () -> Void = {}
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.red.opacity(0.1), Color.orange.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                    .frame(height: 60)
                
                // Heading
                Text("Most people don't fail at relationships because they don't care.")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 32)
                
                Text("They fail because they don't have a system.")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.horizontal, 32)
                
                // Pain points list
                VStack(alignment: .leading, spacing: 20) {
                    PainPointRow(text: "You forget to follow up")
                    PainPointRow(text: "Relationships drift from neglect")
                    PainPointRow(text: "You only reach out when you need something")
                    PainPointRow(text: "Guilt builds but nothing changes")
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 32)
                
                Spacer()
                
                // Show me How button
                Button(action: onShowMeHow) {
                    Text("Show me How")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [.red, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
}

// Helper view for pain point rows
struct PainPointRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("❌")
                .font(.system(size: 20))
            
            Text(text)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.primary.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    PainfulTruthScreen()
}
