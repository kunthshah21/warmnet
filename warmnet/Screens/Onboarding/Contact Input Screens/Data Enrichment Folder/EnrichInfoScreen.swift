import SwiftUI

struct EnrichInfoScreen: View {
    var onGetStarted: () -> Void
    var onFlowComplete: () -> Void
    var isOnboarding: Bool = true
    @State private var navigateToPriority = false
    
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
                
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 0.32, green: 0.57, blue: 0.87))
                    .padding(.bottom, 20)
                
                Text("Enrich Data")
                    .font(Font.custom(AppFontName.workSansMedium, size: 32))
                    .foregroundColor(isOnboarding ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(spacing: 16) {
                    Text("First, we'll help you organize your contacts by assigning priorities to ensure you stay in touch with who matters most.")
                        .font(Font.custom(AppFontName.overpassVariable, size: 16).weight(.medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(isOnboarding ? .white.opacity(0.7) : .primary.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Next, we'll enrich location data to help you visualize where your network is located around the world.")
                        .font(Font.custom(AppFontName.overpassVariable, size: 16).weight(.medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(isOnboarding ? .white.opacity(0.7) : .primary.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal)
                
                Spacer()
                    .frame(minHeight: 100, maxHeight: 150)
                
                Button(action: {
                    navigateToPriority = true
                    onGetStarted()
                }) {
                    HStack(spacing: 8) {
                        Text("Get Started")
                        Image(systemName: "arrow.right")
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
        .navigationTitle("Enrichment")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToPriority) {
            PriorityEnrichInfoScreen(onEnrich: {
            }, onFlowComplete: {
                onFlowComplete()
            }, isOnboarding: isOnboarding)
        }
    }
}

#Preview {
    NavigationStack {
        EnrichInfoScreen(onGetStarted: {}, onFlowComplete: {})
    }
}
