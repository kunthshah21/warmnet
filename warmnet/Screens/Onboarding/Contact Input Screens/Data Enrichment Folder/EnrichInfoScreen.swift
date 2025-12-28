import SwiftUI

struct EnrichInfoScreen: View {
    var onGetStarted: () -> Void
    var onFlowComplete: () -> Void
    @State private var navigateToPriority = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                    .frame(minHeight: 80, maxHeight: 120)
                
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 0.32, green: 0.57, blue: 0.87))
                    .padding(.bottom, 20)
                
                Text("Enrich Data")
                    .font(Font.custom("WorkSans-Medium", size: 32))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(spacing: 16) {
                    Text("First, we'll help you organize your contacts by assigning priorities to ensure you stay in touch with who matters most.")
                        .font(Font.custom("Overpass-Medium", size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Next, we'll enrich location data to help you visualize where your network is located around the world.")
                        .font(Font.custom("Overpass-Medium", size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black.opacity(0.7))
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
                    .font(Font.custom("Overpass-Medium", size: 16))
                    .foregroundColor(.white)
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
