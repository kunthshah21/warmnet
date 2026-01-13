import SwiftUI

struct LocationEnrichmentInfoScreen: View {
    var onEnrich: () -> Void
    var onFlowComplete: () -> Void
    var isOnboarding: Bool = true
    @State private var navigateToEnrichment = false
    
    var body: some View {
        ZStack {
            if isOnboarding {
                Color.black.ignoresSafeArea()
            } else {
                Color(uiColor: .systemBackground).ignoresSafeArea()
            }
            
            VStack(spacing: 24) {
                Spacer()
                    .frame(minHeight: 80, maxHeight: 120)
                
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 0.32, green: 0.57, blue: 0.87))
                    .padding(.bottom, 20)
                
                Text("Enrich Location")
                    .font(Font.custom(AppFontName.workSansMedium, size: 32))
                    .foregroundColor(isOnboarding ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("Add location data to your contacts to visualize your network on a map and plan meetups when you travel.")
                    .font(Font.custom(AppFontName.overpassVariable, size: 16).weight(.medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(isOnboarding ? .white.opacity(0.7) : .primary.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 12) {
                    infoRow(icon: "map.fill", color: .blue, title: "Visualize Network", description: "See where your friends and connections are located globally.")
                    infoRow(icon: "airplane", color: .orange, title: "Travel Planning", description: "Easily find who to meet when you visit a new city.")
                    infoRow(icon: "mappin.and.ellipse", color: .red, title: "Smart Suggestions", description: "Get reminders to connect when you are nearby.")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isOnboarding ? Color.white.opacity(0.05) : Color.primary.opacity(0.05))
                )
                .padding(.horizontal)
                
                Spacer()
                    .frame(minHeight: 100, maxHeight: 150)
                
                Button(action: {
                    navigateToEnrichment = true
                    onEnrich()
                }) {
                    HStack(spacing: 8) {
                        Text("Enrich Locations")
                        Image(systemName: "location.fill")
                    }
                    .typography(\.primaryButton)
                    .frame(maxWidth: 253, minHeight: 48)
                    .background(Color(red: 0.32, green: 0.57, blue: 0.87))
                    .cornerRadius(20)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .navigationTitle("Location")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToEnrichment) {
            LocationEnrichmentScreen(onFlowComplete: {
                print("LocationEnrichmentInfoScreen: onFlowComplete called")
                onFlowComplete()
            }, isOnboarding: isOnboarding)
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
                    .font(Font.custom(AppFontName.workSansMedium, size: 16))
                    .foregroundColor(isOnboarding ? .white : .primary)
                Text(description)
                    .font(Font.custom(AppFontName.overpassVariable, size: 14).weight(.medium))
                    .foregroundColor(isOnboarding ? .white.opacity(0.7) : .primary.opacity(0.7))
            }
        }
    }
}

#Preview {
    NavigationStack {
        LocationEnrichmentInfoScreen(onEnrich: {}, onFlowComplete: {})
    }
}
