import SwiftUI
import Contacts

struct DeviceContactRow: View {
    let contact: CNContact
    let isSelected: Bool
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Avatar Circle
                ZStack {
                    Circle()
                        .fill(isSelected ? Color(red: 0.32, green: 0.57, blue: 0.87).opacity(0.2) : Color.white.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    if let imageData = contact.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } else {
                        Text(contact.initials)
                            .font(.headline)
                            .foregroundColor(isSelected ? Color(red: 0.32, green: 0.57, blue: 0.87) : .black.opacity(0.7))
                    }
                }
                
                // Contact Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(contact.fullName)
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                        Text(phoneNumber)
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.6))
                    } else if !contact.emailAddresses.isEmpty {
                        Text(contact.emailAddresses.first?.value as String? ?? "")
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.6))
                    }
                }
                
                Spacer()
                
                // Checkmark
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? Color(red: 0.32, green: 0.57, blue: 0.87) : Color.black.opacity(0.1), lineWidth: 2)
                        .background(
                            Circle()
                                .fill(isSelected ? Color(red: 0.32, green: 0.57, blue: 0.87) : Color.clear)
                        )
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(red: 0.32, green: 0.57, blue: 0.87).opacity(0.15) : Color.black.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color(red: 0.32, green: 0.57, blue: 0.87).opacity(0.5) : Color.black.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// Extension to get contact initials
extension CNContact {
    var fullName: String {
        [givenName, familyName].filter { !$0.isEmpty }.joined(separator: " ")
    }
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullName) {
            let initialsFormatter = PersonNameComponentsFormatter()
            initialsFormatter.style = .abbreviated
            return initialsFormatter.string(from: components)
        }
        return String(fullName.prefix(1))
    }
}
