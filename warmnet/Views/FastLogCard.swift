import SwiftUI

struct FastLogCard: View {
    // Dummy data structure for visualization
    struct FastLogItem: Identifiable {
        let id = UUID()
        let name: String
    }
    
    @State private var items: [FastLogItem] = [
        FastLogItem(name: "Alice Smith"),
        FastLogItem(name: "Bob Jones"),
        FastLogItem(name: "Charlie Brown")
    ]
    
    @State private var completedItemId: UUID?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(Color("Primary"))
                Text("Today's Network Goals")
                    .font(.headline)
                Spacer()
            }
            .padding(.bottom, 8)
            
            if items.isEmpty {
                Text("All caught up for next week!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else {
                ForEach(items) { item in
                    HStack(spacing: 12) {
                        Button {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            
                            withAnimation(.spring(duration: 0.3)) {
                                completedItemId = item.id
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    markAsDone(item)
                                    if completedItemId == item.id {
                                        completedItemId = nil
                                    }
                                }
                            }
                        } label: {
                            ZStack {
                                if completedItemId == item.id {
                                    Circle()
                                        .fill(Color("Primary"))
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(.white)
                                } else {
                                    Circle()
                                        .strokeBorder(Color.secondary.opacity(0.6), lineWidth: 1.5)
                                        .background(Circle().fill(Color.clear))
                                }
                            }
                            .frame(width: 20, height: 20)
                        }

                        Text(item.name)
                            .font(.body)
                            .fontWeight(.medium)
                        
                        Spacer()
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(8)
                    .transition(.asymmetric(
                        insertion: .identity,
                        removal: .opacity.combined(with: .move(edge: .trailing))
                    ))
                }
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func markAsDone(_ item: FastLogItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items.remove(at: index)
        }
    }
}

#Preview {
    ZStack {
        Color(uiColor: .systemGroupedBackground)
            .ignoresSafeArea()
        FastLogCard()
            .padding()
    }
}
