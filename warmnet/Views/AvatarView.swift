import SwiftUI

struct AvatarView: View {
    let name: String
    var size: CGFloat = 50
    
    private var initials: String {
        let components = name.split(separator: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        } else if let first = components.first {
            return String(first.prefix(2)).uppercased()
        }
        return "?"
    }
    
    private var backgroundColor: Color {
        let colors: [Color] = [
            .red, .orange, .yellow, .green, .mint,
            .teal, .cyan, .blue, .indigo, .purple, .pink
        ]
        let hash = name.hashValue
        return colors[abs(hash) % colors.count]
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor.gradient)
                .frame(width: size, height: size)
            
            Text(initials)
                .font(.system(size: size * 0.4, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        AvatarView(name: "John Doe")
        AvatarView(name: "Alice", size: 70)
        AvatarView(name: "Bob Smith", size: 40)
    }
}

