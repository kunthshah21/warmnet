import SwiftUI

struct ContactRow: View {
    let contact: Contact
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar circle with initials
            AvatarView(name: contact.name, size: 36)
            
            Text(contact.name)
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)
            
            Circle()
                .fill((contact.priority ?? .broaderNetwork).color)
                .frame(width: 8, height: 8)
            
            Spacer()
        }
        .padding(.vertical, 2)
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

