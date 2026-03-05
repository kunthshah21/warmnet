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
        Button {
            HapticManager.impact(.medium)
            action()
        } label: {
            HStack(spacing: 10) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title2.weight(.semibold))
                }
                Text(title)
                    .typography(\.primaryButton)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppGradients.blueGlow)
            )
            .shadow(color: AppColors.mutedBlue.opacity(0.3), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton("Add Contact", icon: "plus") { }
        
        PrimaryButton("Save") { }
    }
    .padding()
    .background(AppColors.deepNavy)
}

