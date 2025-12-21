import SwiftUI
import SwiftData

struct HomeScreen: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var showAddContact = false
    @State private var showMapSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [backgroundTopColor, backgroundBottomColor],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        MapPreviewCard {
                            showMapSheet = true
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 120) // Space for floating button
                }
                .scrollContentBackground(.visible)
                
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
            .sheet(isPresented: $showMapSheet) {
                MapScreen(showsDismissButton: true)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    // MARK: - Subviews

    private var backgroundTopColor: Color {
        colorScheme == .dark ? Color(.sRGB, white: 0.02, opacity: 1) : Color(.sRGB, white: 1.0, opacity: 1)
    }

    private var backgroundBottomColor: Color {
        colorScheme == .dark ? Color(.sRGB, white: 0.10, opacity: 1) : Color(.sRGB, white: 0.95, opacity: 1)
    }
    
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
}
