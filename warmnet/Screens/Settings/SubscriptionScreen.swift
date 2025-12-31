import SwiftUI

struct SubscriptionScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.yellow)
                    .padding(.top, 40)
                
                Text("Warmnet Premium")
                    .font(.largeTitle)
                    .bold()
                
                Text("Unlock unlimited contacts, advanced insights, and more.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                
                Button("Manage Subscription") {
                    // Action
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
                
                Spacer()
            }
        }
        .navigationTitle("Subscription")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SubscriptionScreen()
    }
}
