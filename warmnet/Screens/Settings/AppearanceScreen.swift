import SwiftUI

struct AppearanceScreen: View {
    @AppStorage("userTheme") private var userTheme: String = "System"
    
    let themes = ["Light", "Dark", "System"]
    
    var body: some View {
        Form {
            Section {
                Picker("Appearance", selection: $userTheme) {
                    ForEach(themes, id: \.self) { theme in
                        Text(theme)
                    }
                }
                .pickerStyle(.inline)
            } footer: {
                Text("Choose your preferred appearance for the app.")
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AppearanceScreen()
    }
}
