import SwiftUI

struct TestingScreen: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var showImportFlow = false
    
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
                
                VStack {
                    PrimaryButton(
                        "Test Contact Input",
                        action: {
                            showImportFlow = true
                        }
                    )
                    .padding(.horizontal, 16)
                }
            }
            .navigationTitle("Testing")
            .navigationDestination(isPresented: $showImportFlow) {
                ImportContactsScreen()
            }
        }
    }
    
    // Background colors based on color scheme
    private var backgroundTopColor: Color {
        colorScheme == .dark ? Color(red: 0.05, green: 0.05, blue: 0.1) : Color(red: 0.95, green: 0.97, blue: 1.0)
    }
    
    private var backgroundBottomColor: Color {
        colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.15) : Color(red: 0.85, green: 0.90, blue: 0.98)
    }
}

#Preview {
    TestingScreen()
}
