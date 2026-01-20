import SwiftUI
import SwiftData

struct MapPreviewCard: View {
    @Environment(\.colorScheme) private var colorScheme
    var onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                header

                MapPreviewMap()
                    .frame(height: 190)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            // Glassmorphism effect
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(colorScheme == .dark ? AppColors.charcoal.opacity(0.8) : .white.opacity(0.8))
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
            )
            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Map")
                    .font(.custom(AppFontName.workSansMedium, size: 16))
                    .foregroundStyle(colorScheme == .dark ? AppColors.textPrimary : .primary)

                Text("View where your contacts are")
                    .font(.custom(AppFontName.workSansRegular, size: 14))
                    .foregroundStyle(colorScheme == .dark ? AppColors.textSecondary : .secondary)
            }

            Spacer()

            Image(systemName: "chevron.up")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(colorScheme == .dark ? AppColors.textTertiary : .secondary)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Map. View where your contacts are.")
        .accessibilityHint("Opens the map in a sheet.")
    }
}

#Preview {
    ZStack {
        AppGradients.background
            .ignoresSafeArea()

        MapPreviewCard(onTap: {})
            .padding()
    }
}


