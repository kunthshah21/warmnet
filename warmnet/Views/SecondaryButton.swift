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
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .inset(by: 0.50)
                        .stroke(Color(red: 0.49, green: 0.49, blue: 0.49), lineWidth: 0.50)
                )
            }
            .frame(height: 48)
            .cornerRadius(15)
        }
    }
}

#Preview {
    SecondaryButton(title: "Login to my Account") {
        print("Secondary button tapped")
    }
    .padding()
}
