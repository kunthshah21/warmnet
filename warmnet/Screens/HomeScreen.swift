import SwiftUI
import SwiftData

struct HomeScreen: View {
    @State private var showAddContact = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Empty state placeholder
                VStack(spacing: 24) {
                    Image(systemName: "house.circle")
                        .font(.system(size: 80))
                        .foregroundStyle(.tertiary)
                    
                    VStack(spacing: 8) {
                        Text("Welcome to WarmNet")
                            .font(.title2.weight(.semibold))
                        
                        Text("Your home for managing connections")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Floating Add Contact Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        addContactButton
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 24)
            }
            .navigationTitle("Home")
            .sheet(isPresented: $showAddContact) {
                AddContactSheet()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var addContactButton: some View {
        Button {
            showAddContact = true
        } label: {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .blue.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: .blue.opacity(0.3), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeScreen()
        .modelContainer(for: Contact.self, inMemory: true)
}
