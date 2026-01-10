import SwiftUI
import SwiftData
import PhotosUI

struct ProfileEditScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var personalisationData: [PersonalisationData]
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var birthdate: Date = Date()
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: UIImage?
    
    private var profileData: PersonalisationData? {
        personalisationData.first
    }
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    VStack {
                        if let profileImage = profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundStyle(.gray)
                        }
                        
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Text("Edit Picture")
                                .font(.footnote)
                        }
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
        .onAppear {
            loadProfileData()
        }
        .onChange(of: name) { _, _ in saveProfileData() }
        .onChange(of: email) { _, _ in saveProfileData() }
        .onChange(of: birthdate) { _, _ in saveProfileData() }
        .onChange(of: selectedPhoto) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    profileImage = uiImage
                    saveProfilePhoto(data)
                }
            }
        }
    }
    
    private func loadProfileData() {
        if let profile = profileData {
            name = profile.name ?? ""
            email = profile.email ?? ""
            birthdate = profile.birthday ?? Date()
            if let photoData = profile.profilePhoto {
                profileImage = UIImage(data: photoData)
            }
        } else {
            // Create initial profile data with defaults
            let calendar = Calendar.current
            let defaultBirthdate = calendar.date(from: DateComponents(year: 2004, month: 5, day: 21)) ?? Date()
            
            let newProfile = PersonalisationData(
                name: "Kunth",
                email: "kunth@gmail.com",
                birthday: defaultBirthdate
            )
            modelContext.insert(newProfile)
            try? modelContext.save()
            
            // Load the default values into state
            name = "Kunth"
            email = "kunth@gmail.com"
            birthdate = defaultBirthdate
        }
    }
    
    private func saveProfileData() {
        if let profile = profileData {
            profile.name = name.isEmpty ? nil : name
            profile.email = email.isEmpty ? nil : email
            profile.birthday = birthdate
            try? modelContext.save()
        }
    }
    
    private func saveProfilePhoto(_ data: Data) {
        if let profile = profileData {
            profile.profilePhoto = data
            try? modelContext.save()
        }
    }
}

#Preview {
    NavigationStack {
        ProfileEditScreen()
    }
    .modelContainer(for: [PersonalisationData.self], inMemory: true)
}
