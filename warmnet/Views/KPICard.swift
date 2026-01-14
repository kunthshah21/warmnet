import SwiftUI

struct KPICard: View {
    let innerCircleCount: Int
    let keyRelationshipsCount: Int
    let broaderNetworkCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Network Health")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                kpiItem(
                    count: innerCircleCount,
                    label: "Inner Circle",
                    icon: "star.fill",
                    color: Color("Green-app")
                )
                
                Divider()
                    .frame(height: 40)
                
                kpiItem(
                    count: keyRelationshipsCount,
                    label: "Key Relationships",
                    icon: "person.2.fill",
                    color: Color("Blue-app")
                )
                
                Divider()
                    .frame(height: 40)
                
                kpiItem(
                    count: broaderNetworkCount,
                    label: "Broader Network",
                    icon: "person.3.fill",
                    color: .yellow
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private func kpiItem(count: Int, label: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
                
                Text("\(count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .contentTransition(.numericText())
            }
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ZStack {
        Color(uiColor: .systemGroupedBackground)
            .ignoresSafeArea()
        
        KPICard(
            innerCircleCount: 5,
            keyRelationshipsCount: 12,
            broaderNetworkCount: 45
        )
        .padding()
    }
}
