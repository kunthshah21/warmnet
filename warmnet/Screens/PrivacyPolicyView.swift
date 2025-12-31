import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .bold()
                
                Text("Last updated: December 31, 2025")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Divider()
                
                Text("Data Privacy")
                    .font(.headline)
                
                Text("Warmnet is designed with privacy first. All your contact data, interactions, and personal preferences are stored locally on your device using Apple's SwiftData framework.")
                
                Text("We do not collect, transmit, or sell your personal data to any third-party servers. Your data stays on your device.")
                
                Text("Contact Access")
                    .font(.headline)
                    .padding(.top)
                
                Text("The app requests access to your contacts solely for the purpose of helping you manage your relationships. This data is processed locally.")
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
