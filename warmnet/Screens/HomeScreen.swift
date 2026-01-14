import SwiftUI
import SwiftData

struct HomeScreen: View {
    @Environment(\.colorScheme) private var colorScheme
    @Query private var contacts: [Contact]
    @Query private var personalisationData: [PersonalisationData]

    @State private var showAddContact = false
    @State private var showMapSheet = false
    @State private var showLogInteraction = false
    @State private var showSettings = false
    @State private var preSelectedContact: Contact?
    
    private var profileData: PersonalisationData? {
        personalisationData.first
    }
    
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
    
    private var todaysGoals: [Contact] {
        let today = Calendar.current.startOfDay(for: Date())
        return contacts.filter { contact in
            let due = Calendar.current.startOfDay(for: contact.nextReminderDate)
            return due <= today
        }.sorted { $0.nextReminderDate < $1.nextReminderDate }
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
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Hi User")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                
                                Text("Welcome to Warmnet")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundStyle(headingColor)
                            }
                            
                            Spacer()
                            
                            Button {
                                showSettings = true
                            } label: {
                                if let photoData = profileData?.profilePhoto,
                                   let uiImage = UIImage(data: photoData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.crop.circle")
                                        .font(.largeTitle)
                                        .foregroundStyle(.primary)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        if !todaysGoals.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Reach Out")
                                    .font(.headline)
                                    .foregroundStyle(headingColor)
                                    .padding(.horizontal)
                                
                                Text("Today's Network Goals")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(todaysGoals) { contact in
                                            Button {
                                                preSelectedContact = contact
                                                showLogInteraction = true
                                            } label: {
                                                VStack(spacing: 8) {
                                                    AvatarView(name: contact.name, size: 50)
                                                    Text(contact.name)
                                                        .font(.caption)
                                                        .lineLimit(2)
                                                        .multilineTextAlignment(.center)
                                                        .foregroundStyle(.primary)
                                                        .frame(height: 32)
                                                }
                                                .frame(width: 100)
                                                .padding(.vertical, 12)
                                                .padding(.horizontal, 8)
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
                        
                        TodayAndWeeklyCard(contacts: contacts) { contact in
                            preSelectedContact = contact
                            showLogInteraction = true
                        }
                        
                        NetworkProgressCard()
                        
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
            .sheet(isPresented: $showLogInteraction, onDismiss: { preSelectedContact = nil }) {
                LogInteractionSheet(preSelectedContact: preSelectedContact)
                    .presentationDragIndicator(.visible)
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
        colorScheme == .dark ? Color("Background-dark") : Color(.sRGB, white: 1.0, opacity: 1)
    }

    private var backgroundBottomColor: Color {
        colorScheme == .dark ? Color("Background-dark").opacity(0.9) : Color(.sRGB, white: 0.95, opacity: 1)
    }

    private var headingColor: Color {
        colorScheme == .dark ? Color("Beige accent") : .primary
    }
    
    private var addContactButton: some View {
        Menu {
            Button {
                showAddContact = true
            } label: {
                Label("Add Contact", systemImage: "person.badge.plus")
            }
            
            Button {
                preSelectedContact = nil
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
                                colors: [Color("Blue-app"), Color("Blue-app").opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: Color("Blue-app").opacity(0.3), radius: 12, x: 0, y: 6)
        }
    }
}

#Preview {
    HomeScreen()
}
