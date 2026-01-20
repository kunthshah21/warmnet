import SwiftUI

struct FormTextField: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom(AppFontName.workSansMedium, size: 13))
                .foregroundStyle(colorScheme == .dark ? AppColors.textSecondary : .secondary)
            
            TextField(placeholder.isEmpty ? title : placeholder, text: $text)
                .font(.custom(AppFontName.workSansRegular, size: 16))
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(colorScheme == .dark ? AppColors.charcoal : Color(.systemGray6))
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
    .background(AppColors.deepNavy)
}

