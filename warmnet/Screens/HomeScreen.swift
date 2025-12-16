import SwiftUI
import SwiftData

struct HomeScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Contact.name) private var contacts: [Contact]
    
    @State private var showAddContact = false
    @State private var searchText = ""
    
    private var filteredContacts: [Contact] {
        if searchText.isEmpty {
            return contacts
        }
        return contacts.filter { contact in
            contact.name.localizedCaseInsensitiveContains(searchText) ||
            contact.phoneNumber.contains(searchText) ||
            contact.reference.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if contacts.isEmpty {
                        emptyStateView
                    } else {
                        contactsListView
                    }
                    
                    // Bottom add button
                    addButtonSection
                }
            }
            .navigationTitle("Contacts")
            .searchable(text: $searchText, prompt: "Search contacts")
            .sheet(isPresented: $showAddContact) {
                AddContactSheet()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "person.2.circle")
                .font(.system(size: 80))
                .foregroundStyle(.tertiary)
            
            VStack(spacing: 8) {
                Text("No Contacts Yet")
                    .font(.title2.weight(.semibold))
                
                Text("Add your first contact to get started")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var contactsListView: some View {
        List {
            ForEach(filteredContacts) { contact in
                ContactRow(contact: contact)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deleteContact(contact)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    private var addButtonSection: some View {
        VStack {
            Divider()
            
            PrimaryButton("Add Contact", icon: "plus") {
                showAddContact = true
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Actions
    
    private func deleteContact(_ contact: Contact) {
        withAnimation {
            modelContext.delete(contact)
        }
    }
}

#Preview {
    HomeScreen()
        .modelContainer(for: Contact.self, inMemory: true)
}

