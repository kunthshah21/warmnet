import SwiftUI

struct PriorityEnrichInfoScreen: View {
    var onEnrich: () -> Void
    var onFlowComplete: () -> Void
    @State private var navigateToEnrichment = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                    .frame(minHeight: 80, maxHeight: 120)
                
                Image(systemName: "list.number")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 0.32, green: 0.57, blue: 0.87))
                    .padding(.bottom, 20)
                
                Text("Select Priority")
                    .font(Font.custom("WorkSans-Medium", size: 32))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("Categorize your contacts into three distinct priority levels to manage your interactions effectively.")
                    .font(Font.custom("Overpass-Medium", size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 12) {
                    priorityRow(icon: "star.fill", color: .green, title: "High Priority", description: "Close friends and family you talk to often.")
                    priorityRow(icon: "circle.fill", color: .blue, title: "Medium Priority", description: "Friends and colleagues you keep in touch with.")
                    priorityRow(icon: "circle.fill", color: .yellow, title: "Low Priority", description: "Acquaintances and extended network.")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.05))
                )
                .padding(.horizontal)
                
                Spacer()
                    .frame(minHeight: 100, maxHeight: 150)
                
                Button(action: {
                    navigateToEnrichment = true
                    onEnrich()
                }) {
                    HStack(spacing: 8) {
                        Text("Enrich Priorities")
                        Image(systemName: "checkmark.circle")
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
                    .font(Font.custom("WorkSans-Medium", size: 16))
                    .foregroundColor(.black)
                Text(description)
                    .font(Font.custom("Overpass-Medium", size: 14))
                    .foregroundColor(.black.opacity(0.7))
            }
        }
    }
}

#Preview {
    NavigationStack {
        PriorityEnrichInfoScreen(onEnrich: {}, onFlowComplete: {})
    }
}
