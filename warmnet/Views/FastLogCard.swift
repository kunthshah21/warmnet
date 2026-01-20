import SwiftUI

struct FastLogCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let contacts: [Contact]
    let onLogInteraction: (Contact) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(AppColors.mutedBlue)
                Text("Today's Network Goals")
                    .font(.custom(AppFontName.workSansMedium, size: 16))
                Spacer()
            }
            .padding(.bottom, 8)
            
            if contacts.isEmpty {
                Text("All caught up for today!")
                    .font(.custom(AppFontName.workSansRegular, size: 14))
                    .foregroundStyle(colorScheme == .dark ? AppColors.textSecondary : .secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else {
                ForEach(contacts) { contact in
                    Button {
                        onLogInteraction(contact)
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .strokeBorder(colorScheme == .dark ? AppColors.textTertiary : Color.secondary.opacity(0.6), lineWidth: 1.5)
                                    .background(Circle().fill(Color.clear))
                                Image(systemName: "plus")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(colorScheme == .dark ? AppColors.textSecondary : Color.secondary)
                            }
                            .frame(width: 20, height: 20)

                            Text(contact.name)
                                .font(.custom(AppFontName.workSansMedium, size: 15))
                                .foregroundStyle(colorScheme == .dark ? AppColors.textPrimary : .primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(colorScheme == .dark ? AppColors.textTertiary : .secondary)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                    }
                }
            }
        }
        .padding()
        .background(colorScheme == .dark ? AppColors.charcoal : Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    ZStack {
        AppColors.deepNavy
            .ignoresSafeArea()
        FastLogCard(contacts: [], onLogInteraction: { _ in })
            .padding()
    }
}
