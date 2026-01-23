import SwiftUI
import SwiftData

struct HomeScreen: View {
    @Environment(\.colorScheme) private var colorScheme
    @Query private var contacts: [Contact]
    @Query private var personalisationData: [PersonalisationData]

    @State private var showAddContact = false
    @State private var showLogInteraction = false
    @State private var showSettings = false
    @State private var showNotifications = false
    @State private var showMapSheet = false
    @State private var preSelectedContact: Contact?
    
    private var profileData: PersonalisationData? {
        personalisationData.first
    }
    
    private var userName: String {
        profileData?.name ?? ""
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
    
    private var upcomingReminders: [Contact] {
        contacts.sorted { $0.nextReminderDate < $1.nextReminderDate }
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
                        // Top Dashboard Card - extends to edges
                        TopDashboardCard(
                            userName: userName,
                            profilePhoto: profileData?.profilePhoto,
                            todaysGoals: todaysGoals,
                            innerCircleCount: innerCircleCount,
                            keyRelationshipsCount: keyRelationshipsCount,
                            broaderNetworkCount: broaderNetworkCount,
                            onProfileTap: {
                                showSettings = true
                            },
                            onNotificationTap: {
                                showNotifications = true
                            },
                            onContactTap: { contact in
                                preSelectedContact = contact
                            }
                        )
                        
                        // Other cards with horizontal padding
                        VStack(spacing: 16) {
                            TodayAndWeeklyCard(contacts: contacts) { contact in
                                preSelectedContact = contact
                            }
                            
                            NetworkProgressCard()
                        }
                        .padding(.horizontal, 16)
                    .padding(.bottom, 120) // Space for floating button
                }
            }
            .ignoresSafeArea(edges: .top)
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
                LogInteractionSheet(preSelectedContact: nil)
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $preSelectedContact) { contact in
                LogInteractionSheet(preSelectedContact: contact)
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showMapSheet) {
                MapScreen(showsDismissButton: true)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showNotifications) {
                NotificationsSheet(
                    upcomingReminders: upcomingReminders,
                    onContactTap: { contact in
                        showNotifications = false
                        preSelectedContact = contact
                    }
                )
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
        colorScheme == .dark ? AppColors.deepNavy : Color(.sRGB, white: 0.98, opacity: 1)
    }

    private var backgroundBottomColor: Color {
        colorScheme == .dark ? AppColors.charcoal.opacity(0.95) : Color(.sRGB, white: 0.94, opacity: 1)
    }

    private var headingColor: Color {
        colorScheme == .dark ? AppColors.softBeige : .primary
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
                        .fill(AppGradients.blueGlow)
                )
                .shadow(color: AppColors.mutedBlue.opacity(0.3), radius: 12, x: 0, y: 6)
        }
    }
}

// MARK: - Preview with Sample Data

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, PersonalisationData.self, configurations: config)
    
    // Create sample contacts for preview - set nextTouchDate to today so they appear in todaysGoals
    let today = Date()
    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
    
    let sampleContacts = [
        Contact(name: "Sarah Johnson", priority: .innerCircle, nextTouchDate: today),
        Contact(name: "Mike Chen", priority: .keyRelationships, nextTouchDate: today),
        Contact(name: "Emma Wilson", priority: .innerCircle, nextTouchDate: yesterday),
        Contact(name: "James Brown", priority: .broaderNetwork, nextTouchDate: today),
        Contact(name: "Lisa Park", priority: .keyRelationships, nextTouchDate: yesterday),
        Contact(name: "David Kim", priority: .broaderNetwork),
        Contact(name: "Anna Martinez", priority: .innerCircle)
    ]
    
    for contact in sampleContacts {
        container.mainContext.insert(contact)
    }
    
    // Create sample profile data
    let profileData = PersonalisationData()
    profileData.name = "Kunth"
    container.mainContext.insert(profileData)
    
    return HomeScreen()
        .modelContainer(container)
}
