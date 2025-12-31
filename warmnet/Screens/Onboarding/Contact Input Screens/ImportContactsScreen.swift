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
            // Black background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                    .frame(minHeight: 80, maxHeight: 120)
                
                Text("Import Contacts")
                    .font(Font.custom("WorkSans-Medium", size: 32))
                    .foregroundColor(.black)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("Import your contacts for the application to work properly. We respect your privacy and only use contacts locally.")
                    .font(Font.custom("Overpass-Medium", size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                
                // Image Placeholder
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.black.opacity(0.1), lineWidth: 2)
                    .background(Color.clear)
                    .frame(height: 200)
                    .overlay {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 60))
                            .foregroundStyle(Color(red: 0.32, green: 0.57, blue: 0.87))
                    }
                    .padding(.horizontal)
                
                Spacer()
                    .frame(minHeight: 100, maxHeight: 150)
                
                Button(action: {
                    requestContactsAccess()
                }) {
                    HStack(spacing: 8) {
                        Text("Import Contacts")
                        Image(systemName: "square.and.arrow.down")
                    }
                    .font(Font.custom("Overpass-Medium", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: 253, minHeight: 48)
                    .background(Color(red: 0.32, green: 0.57, blue: 0.87))
                    .cornerRadius(20)
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
    

}

#Preview {
    NavigationStack {
        ImportContactsScreen()
    }
}
