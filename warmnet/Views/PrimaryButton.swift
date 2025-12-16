import SwiftUI

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title2.weight(.semibold))
                }
                Text(title)
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.accentColor.gradient)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton("Add Contact", icon: "plus") {
            print("Tapped")
        }
        
        PrimaryButton("Save") {
            print("Saved")
        }
    }
    .padding()
}

