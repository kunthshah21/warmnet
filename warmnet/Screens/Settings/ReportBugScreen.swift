import SwiftUI

struct ReportBugScreen: View {
    @State private var bugDescription: String = ""
    
    var body: some View {
        Form {
            Section {
                Text("Found a bug? Let us know so we can fix it.")
                    .foregroundStyle(.secondary)
                
                TextEditor(text: $bugDescription)
                    .frame(height: 150)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
            } header: {
                Text("Description")
            }
            
            Button("Submit Report") {
                // Submit action
            }
        }
        .navigationTitle("Report a Bug")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ReportBugScreen()
    }
}
