import SwiftUI
import SwiftData

struct ContactsScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Contact.name) private var contacts: [Contact]
    @Query private var personalisationData: [PersonalisationData]
    
    @State private var showAddContact = false
    @State private var showContactImport = false
    @State private var searchText = ""
    @State private var selectedPriority: Priority? = nil
    
    private var displayName: String {
        personalisationData.first?.name ?? "My Card"
    }
    
    private var groupedContacts: [(key: String, value: [Contact])] {
        let filtered = contacts.filter { contact in
            let matchesSearch = searchText.isEmpty || contact.name.localizedCaseInsensitiveContains(searchText)
            let effectivePriority = contact.priority ?? .broaderNetwork
            let matchesPriority = selectedPriority == nil || effectivePriority == selectedPriority
            return matchesSearch && matchesPriority
        }
        
        let grouped = Dictionary(grouping: filtered) { contact in
            String(contact.name.prefix(1)).uppercased()
        }
        
        return grouped.sorted { $0.key < $1.key }
    }
    
    private let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ#".map { String($0) }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    Text("Contacts")
                        .font(.custom(AppFontName.workSansMedium, size: 32))
                        .fontWeight(.bold)
                    Spacer()
                    Button {
                        showAddContact = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppColors.mutedBlue)
                    }
                    
                    Menu {
                        Button {
                            showContactImport = true
                        } label: {
                            Label("Add from Contacts", systemImage: "person.crop.circle.badge.plus")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppColors.mutedBlue)
                            .rotationEffect(.degrees(90))
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 8)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search", text: $searchText)
                }
                .padding(8)
                .background(Color(uiColor: .systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 16)

                // Priority Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterButton(title: "All", isSelected: selectedPriority == nil) {
                            withAnimation { selectedPriority = nil }
                        }
                        
                        ForEach(Priority.allCases, id: \.self) { priority in
                            FilterButton(title: priority.rawValue, isSelected: selectedPriority == priority, color: priority.color) {
                                withAnimation { selectedPriority = priority }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(uiColor: .systemBackground))
                
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
                                        Text(displayName)
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
                                        .foregroundStyle(AppColors.mutedBlue)
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
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showAddContact) {
                AddContactSheet()
            }
            .sheet(isPresented: $showContactImport) {
                NavigationStack {
                    ContactSelectScreen(onFlowComplete: {
                        showContactImport = false
                    }, isOnboarding: false)
                }
            }
        }
    }
    
    private func deleteContact(_ contact: Contact) {
        withAnimation {
            modelContext.delete(contact)
        }
    }
}

struct FilterButton: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let isSelected: Bool
    var color: Color = AppColors.mutedBlue
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom(AppFontName.workSansMedium, size: 13))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? color.opacity(0.2) : (colorScheme == .dark ? AppColors.charcoal : Color.gray.opacity(0.1)))
                )
                .overlay(
                    Capsule()
                        .strokeBorder(isSelected ? color : Color.clear, lineWidth: 1)
                )
                .foregroundStyle(isSelected ? color : (colorScheme == .dark ? AppColors.textPrimary : .primary))
        }
    }
}

#Preview {
    ContactsScreen()
        .modelContainer(for: Contact.self, inMemory: true)
}

