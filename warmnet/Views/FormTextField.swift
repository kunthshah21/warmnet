import SwiftUI

struct FormTextField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            
            TextField(placeholder.isEmpty ? title : placeholder, text: $text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemGray6))
                )
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        FormTextField(title: "Name", text: .constant("John Doe"))
        FormTextField(title: "Email", text: .constant(""), placeholder: "Enter email", keyboardType: .emailAddress)
    }
    .padding()
}

