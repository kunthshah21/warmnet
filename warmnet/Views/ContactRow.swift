import SwiftUI

struct ContactRow: View {
    let contact: Contact
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar circle with initials
            AvatarView(name: contact.name)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(contact.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                if !contact.phoneNumber.isEmpty {
                    Text(contact.fullPhoneNumber)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                if !contact.reference.isEmpty {
                    Text(contact.reference)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.quaternary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ContactRow(contact: Contact(
        name: "John Doe",
        phoneCountryCode: "+1",
        phoneNumber: "555-1234",
        reference: "Met at conference"
    ))
    .padding()
}

