//
//  ValuePropositionScreen.swift
//  warmnet
//
//  Created on 24 December 2025.
//

import SwiftUI

struct ValuePropositionScreen: View {
    var onBuildMySystem: () -> Void = {}
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.green.opacity(0.15), Color.blue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                    .frame(height: 60)
                
                // Heading
                Text("Imagine if...")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                // Benefits list
                VStack(alignment: .leading, spacing: 20) {
                    BenefitRow(text: "You never forgot an important person again")
                    BenefitRow(text: "Every conversation felt natural, never forced")
                    BenefitRow(text: "People thought: \"When you reach out, it's always meaningful\"")
                    BenefitRow(text: "Your network became your greatest asset")
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 32)
                
                Spacer()
                
                // Build my system button
                Button(action: onBuildMySystem) {
                    Text("Build my system")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [.green, .blue],
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

// Helper view for benefit rows
struct BenefitRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("✨")
                .font(.system(size: 20))
            
            Text(text)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.primary.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    ValuePropositionScreen()
}
