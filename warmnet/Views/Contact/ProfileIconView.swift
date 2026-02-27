//
//  ProfileIconView.swift
//  warmnet
//
//  Created on 30/01/2026.
//

import SwiftUI

/// Reusable profile icon component that displays user's photo or a placeholder
struct ProfileIconView: View {
    let profilePhoto: Data?
    var size: CGFloat = 63
    var action: (() -> Void)? = nil
    
    var body: some View {
        if let action = action {
            Button(action: action) {
                profileContent
            }
            .buttonStyle(.plain)
        } else {
            profileContent
        }
    }
    
    private var profileContent: some View {
        Group {
            if let photoData = profilePhoto,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                ZStack {
                    Circle()
                        .fill(AppGradients.blueGlow)
                        .frame(width: size, height: size)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: size * 0.4, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ProfileIconView(profilePhoto: nil)
        ProfileIconView(profilePhoto: nil, size: 50)
        ProfileIconView(profilePhoto: nil, size: 40, action: {})
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
