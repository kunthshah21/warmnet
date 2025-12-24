import SwiftUI

struct PriorityEnrichInfoScreen: View {
    var onEnrich: () -> Void
    var onFlowComplete: () -> Void
    @State private var navigateToEnrichment = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "list.number")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
                .padding(.bottom, 20)
            
            Text("Select Priority")
                .font(.largeTitle.weight(.bold))
                .multilineTextAlignment(.center)
            
            Text("Categorize your contacts into three distinct priority levels to manage your interactions effectively.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                priorityRow(icon: "star.fill", color: .green, title: "High Priority", description: "Close friends and family you talk to often.")
                priorityRow(icon: "circle.fill", color: .blue, title: "Medium Priority", description: "Friends and colleagues you keep in touch with.")
                priorityRow(icon: "circle.fill", color: .yellow, title: "Low Priority", description: "Acquaintances and extended network.")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
            .padding(.horizontal)
            
            Spacer()
            
            PrimaryButton("Enrich Priorities", icon: "checkmark.circle") {
                navigateToEnrichment = true
                onEnrich()
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding()
        .navigationTitle("Priority")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToEnrichment) {
            PriorityEnrichmentScreen(onSave: {
                // Handle save completion, maybe navigate to next step or dismiss
                // For now, we can just print or dismiss if it was the last step
                print("Saved priorities")
            }, onFlowComplete: {
                print("PriorityEnrichInfoScreen: onFlowComplete called")
                onFlowComplete()
            })
        }
    }
    
    private func priorityRow(icon: String, color: Color, title: String, description: String) -> some View {
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
        PriorityEnrichInfoScreen(onEnrich: {}, onFlowComplete: {})
    }
}
