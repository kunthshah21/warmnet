import SwiftUI
import SwiftData

struct HomeScreen: View {
    @Environment(\.colorScheme) private var colorScheme
    @Query private var contacts: [Contact]

    @State private var showAddContact = false
    @State private var showMapSheet = false
    @State private var showLogInteraction = false
    @State private var showSettings = false
    
    private var innerCircleCount: Int {
        contacts.filter { $0.priority == .innerCircle }.count
    }
    
    private var keyRelationshipsCount: Int {
        contacts.filter { $0.priority == .keyRelationships }.count
    }
    
    private var broaderNetworkCount: Int {
        contacts.filter { $0.priority == .broaderNetwork }.count
    }
    
    private var overdueContacts: [Contact] {
        contacts.filter { $0.isOverdue }.sorted { $0.nextReminderDate < $1.nextReminderDate }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [backgroundTopColor, backgroundBottomColor],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Custom Header
                        HStack {
                            Text("Home")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button {
                                showSettings = true
                            } label: {
                                Image(systemName: "person.crop.circle")
                                    .font(.largeTitle)
                                    .foregroundStyle(.primary)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        if !overdueContacts.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Reach Out")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(overdueContacts) { contact in
                                            NavigationLink(destination: ContactDetailScreen(contact: contact)) {
                                                VStack {
                                                    AvatarView(name: contact.name, size: 50)
                                                    Text(contact.name)
                                                        .font(.caption)
                                                        .lineLimit(1)
                                                        .foregroundStyle(.primary)
                                                }
                                                .padding()
                                                .background(Color(uiColor: .secondarySystemGroupedBackground))
                                                .cornerRadius(10)
                                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        WeeklyReminderCard(contacts: contacts)
                        
                        KPICard(
                            innerCircleCount: innerCircleCount,
                            keyRelationshipsCount: keyRelationshipsCount,
                            broaderNetworkCount: broaderNetworkCount
                        )
                        
                        MapPreviewCard {
                            showMapSheet = true
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 120) // Space for floating button
                }
                .scrollContentBackground(.visible)
                
                // Floating Add Contact Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        addContactButton
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 24)
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showAddContact) {
                AddContactSheet()
            }
            .sheet(isPresented: $showLogInteraction) {
                LogInteractionSheet()
            }
            .sheet(isPresented: $showMapSheet) {
                MapScreen(showsDismissButton: true)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showSettings) {
                SettingsScreen()
            }
        }
    }
    
    // MARK: - Subviews

    private var backgroundTopColor: Color {
        colorScheme == .dark ? Color(.sRGB, white: 0.02, opacity: 1) : Color(.sRGB, white: 1.0, opacity: 1)
    }

    private var backgroundBottomColor: Color {
        colorScheme == .dark ? Color(.sRGB, white: 0.10, opacity: 1) : Color(.sRGB, white: 0.95, opacity: 1)
    }
    
    private var addContactButton: some View {
        Menu {
            Button {
                showAddContact = true
            } label: {
                Label("Add Contact", systemImage: "person.badge.plus")
            }
            
            Button {
                showLogInteraction = true
            } label: {
                Label("Log Interaction", systemImage: "calendar.badge.plus")
            }
        } label: {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .blue.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: .blue.opacity(0.3), radius: 12, x: 0, y: 6)
        }
    }
}

#Preview {
    HomeScreen()
}
