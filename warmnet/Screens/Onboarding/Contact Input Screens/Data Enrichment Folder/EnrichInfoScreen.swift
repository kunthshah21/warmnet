import SwiftUI

struct EnrichInfoScreen: View {
    var onGetStarted: () -> Void
    var onFlowComplete: () -> Void
    @State private var navigateToPriority = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "wand.and.stars")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
                .padding(.bottom, 20)
            
            Text("Enrich Data")
                .font(.largeTitle.weight(.bold))
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                Text("First, we'll help you organize your contacts by assigning priorities to ensure you stay in touch with who matters most.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                
                Text("Next, we'll enrich location data to help you visualize where your network is located around the world.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            
            Spacer()
            
            PrimaryButton("Get Started", icon: "arrow.right") {
                navigateToPriority = true
                onGetStarted()
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding()
        .navigationTitle("Enrichment")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToPriority) {
            PriorityEnrichInfoScreen(onEnrich: {
                // TODO: Navigate to next step or finish
                print("Priority enrichment done")
            }, onFlowComplete: {
                print("EnrichInfoScreen: onFlowComplete called")
                onFlowComplete()
            })
        }
    }
}

#Preview {
    NavigationStack {
        EnrichInfoScreen(onGetStarted: {}, onFlowComplete: {})
    }
}
