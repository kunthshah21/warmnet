import SwiftUI

struct LocationEnrichmentInfoScreen: View {
    var onEnrich: () -> Void
    var onFlowComplete: () -> Void
    @State private var navigateToEnrichment = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "location.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
                .padding(.bottom, 20)
            
            Text("Enrich Location")
                .font(.largeTitle.weight(.bold))
                .multilineTextAlignment(.center)
            
            Text("Add location data to your contacts to visualize your network on a map and plan meetups when you travel.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                infoRow(icon: "map.fill", color: .blue, title: "Visualize Network", description: "See where your friends and connections are located globally.")
                infoRow(icon: "airplane", color: .orange, title: "Travel Planning", description: "Easily find who to meet when you visit a new city.")
                infoRow(icon: "mappin.and.ellipse", color: .red, title: "Smart Suggestions", description: "Get reminders to connect when you are nearby.")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
            .padding(.horizontal)
            
            Spacer()
            
            PrimaryButton("Enrich Locations", icon: "location.fill") {
                navigateToEnrichment = true
                onEnrich()
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding()
        .navigationTitle("Location")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToEnrichment) {
            LocationEnrichmentScreen(onFlowComplete: onFlowComplete)
        }
    }
    
    private func infoRow(icon: String, color: Color, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        LocationEnrichmentInfoScreen(onEnrich: {}, onFlowComplete: {})
    }
}
