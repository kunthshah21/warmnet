import SwiftUI

struct ProfileEditScreen: View {
    @State private var name: String = "Kunth Shah"
    @State private var email: String = "kunth@example.com"
    @State private var birthdate: Date = Date()
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    VStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundStyle(.gray)
                        
                        Button("Edit Picture") {
                            // Action to edit picture
                        }
                        .font(.footnote)
                    }
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }
            
            Section("Personal Details") {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                DatePicker("Birthdate", selection: $birthdate, displayedComponents: .date)
            }
        }
        .navigationTitle("Manage Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ProfileEditScreen()
    }
}
