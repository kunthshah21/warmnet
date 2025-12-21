import SwiftUI
import SwiftData

struct ContactsScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Contact.name) private var contacts: [Contact]
    
    @State private var showAddContact = false
    @State private var searchText = ""
    
    private var groupedContacts: [(key: String, value: [Contact])] {
        let filtered = contacts.filter { contact in
            searchText.isEmpty ||
            contact.name.localizedCaseInsensitiveContains(searchText)
        }
        
        let grouped = Dictionary(grouping: filtered) { contact in
            String(contact.name.prefix(1)).uppercased()
        }
        
        return grouped.sorted { $0.key < $1.key }
    }
    
    private let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ#".map { String($0) }
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ZStack {
                    List {
                        // My Card Section
                        if searchText.isEmpty {
                            Section {
                                HStack(spacing: 16) {
                                    // Placeholder for My Card Avatar
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .font(.title)
                                                .foregroundStyle(.gray)
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Kunth Shah")
                                            .font(.title3.weight(.semibold))
                                        Text("My Card")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        
                        ForEach(groupedContacts, id: \.key) { key, contacts in
                            Section(header: Text(key).font(.headline).fontWeight(.bold)) {
                                ForEach(contacts) { contact in
                                    ZStack {
                                        ContactRow(contact: contact)
                                        NavigationLink(destination: ContactDetailScreen(contact: contact)) {
                                            EmptyView()
                                        }
                                        .opacity(0)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            deleteContact(contact)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .id(key)
                        }
                    }
                    .listStyle(.plain)
                    
                    // A-Z Index Bar
                    if !groupedContacts.isEmpty {
                        HStack {
                            Spacer()
                            VStack(spacing: 2) {
                                ForEach(alphabet, id: \.self) { letter in
                                    Text(letter)
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(.blue)
                                        .frame(width: 20)
                                        .onTapGesture {
                                            withAnimation {
                                                // Find the closest section
                                                if let section = groupedContacts.first(where: { $0.key >= letter }) {
                                                    proxy.scrollTo(section.key, anchor: .top)
                                                }
                                            }
                                        }
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.trailing, 4)
                        }
                    }
                }
            }
            .navigationTitle("Contacts")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddContact = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddContact) {
                AddContactSheet()
            }
        }
    }
    
    private func deleteContact(_ contact: Contact) {
        withAnimation {
            modelContext.delete(contact)
        }
    }
}

#Preview {
    ContactsScreen()
        .modelContainer(for: Contact.self, inMemory: true)
}

