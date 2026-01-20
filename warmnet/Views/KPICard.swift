import SwiftUI

struct KPICard: View {
    @Environment(\.colorScheme) private var colorScheme
    let innerCircleCount: Int
    let keyRelationshipsCount: Int
    let broaderNetworkCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Network Health")
                .font(.custom(AppFontName.workSansMedium, size: 16))
                .foregroundStyle(colorScheme == .dark ? AppColors.textSecondary : .secondary)
            
            HStack(spacing: 12) {
                kpiItem(
                    count: innerCircleCount,
                    label: "Inner Circle",
                    icon: "star.fill",
                    color: AppColors.accentGreen
                )
                
                Divider()
                    .frame(height: 40)
                
                kpiItem(
                    count: keyRelationshipsCount,
                    label: "Key Relationships",
                    icon: "person.2.fill",
                    color: AppColors.mutedBlue
                )
                
                Divider()
                    .frame(height: 40)
                
                kpiItem(
                    count: broaderNetworkCount,
                    label: "Broader Network",
                    icon: "person.3.fill",
                    color: AppColors.softBeige
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? AppColors.charcoal : Color(uiColor: .secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
    }
    
    private func kpiItem(count: Int, label: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
                
                Text("\(count)")
                    .font(.custom(AppFontName.workSansMedium, size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(colorScheme == .dark ? AppColors.textPrimary : .primary)
                    .contentTransition(.numericText())
            }
            
            Text(label)
                .font(.custom(AppFontName.workSansRegular, size: 11))
                .foregroundStyle(colorScheme == .dark ? AppColors.textSecondary : .secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ZStack {
        AppColors.deepNavy
            .ignoresSafeArea()
        
        KPICard(
            innerCircleCount: 5,
            keyRelationshipsCount: 12,
            broaderNetworkCount: 45
        )
        .padding()
    }
}
