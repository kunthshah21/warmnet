import SwiftUI
import SwiftData

struct MapPreviewCard: View {
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
            // One glass container for similarly-sized, tightly-grouped elements (header + preview)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
        }
        .buttonStyle(.plain)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Map")
                    .font(.headline)

                Text("View where your contacts are")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.up")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Map. View where your contacts are.")
        .accessibilityHint("Opens the map in a sheet.")
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [Color(.sRGB, white: 1.0, opacity: 1), Color(.sRGB, white: 0.95, opacity: 1)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        MapPreviewCard(onTap: {})
            .padding()
    }
}


