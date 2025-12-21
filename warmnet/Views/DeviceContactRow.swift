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
                        .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.secondary.opacity(0.2))
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
                            .foregroundColor(isSelected ? .accentColor : .secondary)
                    }
                }
                
                // Contact Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(contact.fullName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                        Text(phoneNumber)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else if !contact.emailAddresses.isEmpty {
                        Text(contact.emailAddresses.first?.value as String? ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Checkmark
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? Color.accentColor : Color.secondary.opacity(0.3), lineWidth: 2)
                        .background(
                            Circle()
                                .fill(isSelected ? Color.accentColor : Color.clear)
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
                    .fill(isSelected ? glassBackgroundSelected : glassBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color.accentColor.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    // Glass effect backgrounds
    private var glassBackground: Color {
        colorScheme == .dark ? Color.white.opacity(0.05) : Color.white.opacity(0.6)
    }
    
    private var glassBackgroundSelected: Color {
        colorScheme == .dark ? Color.accentColor.opacity(0.15) : Color.accentColor.opacity(0.1)
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
