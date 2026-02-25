//
//  SecondaryButton.swift
//  warmnet
//
//  Created on 28 December 2025.
//

import SwiftUI

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                HStack(spacing: 10) {
                    Text(title)
                        .typography(\.secondaryButton)
                }
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(AppColors.charcoal.opacity(0.5))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(AppColors.mutedBlue.opacity(0.4), lineWidth: 1)
                )
            }
            .frame(height: 48)
        }
    }
}

#Preview {
    SecondaryButton(title: "Login to my Account") { }
    .padding()
    .background(AppColors.deepNavy)
}
