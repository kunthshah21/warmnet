import SwiftUI

struct FastLogCard: View {
    let contacts: [Contact]
    let onLogInteraction: (Contact) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(Color("Primary"))
                Text("Today's Network Goals")
                    .font(.headline)
                Spacer()
            }
            .padding(.bottom, 8)
            
            if contacts.isEmpty {
                Text("All caught up for today!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
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
                                    .strokeBorder(Color.secondary.opacity(0.6), lineWidth: 1.5)
                                    .background(Circle().fill(Color.clear))
                                Image(systemName: "plus")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(Color.secondary)
                            }
                            .frame(width: 20, height: 20)

                            Text(contact.name)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                    }
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    ZStack {
        Color(uiColor: .systemGroupedBackground)
            .ignoresSafeArea()
        FastLogCard(contacts: [], onLogInteraction: { _ in })
            .padding()
    }
}
