import SwiftUI
import Contacts

struct ImportContactsScreen: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var permissionStatus: CNAuthorizationStatus = .notDetermined
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var navigateToSelection = false
    @State private var hasCalledCompletion = false
    
    var onFlowComplete: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [backgroundTopColor, backgroundBottomColor],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                Text("Import Contacts")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Import your contacts for the application to work properly. We respect your privacy and only use contacts locally.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                
                // Image Placeholder
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.secondary.opacity(0.3), lineWidth: 2)
                    .background(Color.clear)
                    .frame(height: 200)
                    .overlay {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary.opacity(0.5))
                    }
                    .padding(.horizontal)
                
                Spacer()
                
                PrimaryButton("Import Contacts", icon: "square.and.arrow.down") {
                    requestContactsAccess()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToSelection) {
            ContactSelectScreen(onFlowComplete: {
                print("ImportContactsScreen: Received onFlowComplete from ContactSelectScreen")
                // Reset navigation state first
                navigateToSelection = false
                // Prevent multiple calls
                guard !hasCalledCompletion else { return }
                hasCalledCompletion = true
                // Call the wrapper's completion handler after a brief delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    print("ImportContactsScreen: Calling onFlowComplete")
                    onFlowComplete?()
                }
            })
        }
        .onAppear {
            checkPermissionStatus()
            hasCalledCompletion = false
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func checkPermissionStatus() {
        permissionStatus = CNContactStore.authorizationStatus(for: .contacts)
    }
    
    private func requestContactsAccess() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = error.localizedDescription
                    showError = true
                    return
                }
                
                if granted {
                    permissionStatus = .authorized
                    print("Contacts access granted")
                    // Navigate to contact selection screen
                    navigateToSelection = true
                } else {
                    permissionStatus = .denied
                    errorMessage = "Permission denied. Please enable access in Settings."
                    showError = true
                }
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
    NavigationStack {
        ImportContactsScreen()
    }
}
