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
    @State private var showAddReminderSheet = false
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
    
    // Get greeting based on time of day
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good morning,"
        case 12..<17:
            return "Good afternoon,"
        case 17..<21:
            return "Good evening,"
        default:
            return "Good night,"
        }
    }
    
    // AI-generated summary placeholder
    private var aiSummary: String {
        if todaysGoals.isEmpty {
            return "You're all caught up! This is a great time to explore new connections or strengthen existing relationships in your network."
        } else {
            return "This month, you've focused on connecting with professionals in the biotech and AI sectors. The trend shows a growing interest in collaborative projects at the intersection of these fields."
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // MARK: - Top Card (pulled from top)
                        VStack(spacing: 20) {
                            // MARK: - Header Row
                            headerRow
                                .padding(.top, 20)
                            
                            // MARK: - Add Network Reminder CTA
                            addReminderButton
                            
                            // MARK: - AI Summary
                            aiSummarySection
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 60) // Account for safe area
                        .padding(.bottom, 40)
                        .background(
                            colorScheme == .dark
                                ? Color(red: 0.11, green: 0.11, blue: 0.13)
                                : Color.white
                        )
                        .cornerRadius(60, corners: [.bottomLeft, .bottomRight])
                        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                        
                        VStack(spacing: 25) {
                            // MARK: - Today's Network Goals
                            TodaysNetworkGoalsView(
                                contacts: todaysGoals,
                                onContactTap: { contact in
                                    preSelectedContact = contact
                                },
                                onSeeAllTap: {
                                    // Navigate to full list or reminders
                                    showNotifications = true
                                }
                            )
                            
                            // MARK: - Overview Section
                            OverviewSectionView(
                                onWeeklyTrendTap: {
                                    // Handle weekly trend tap
                                },
                                onProgressTap: {
                                    // Handle progress tap
                                },
                                onNetworkHealthTap: {
                                    // Handle network health tap
                                }
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 25)
                        .padding(.bottom, 120) // Space for floating button
                    }
                }
                .ignoresSafeArea(edges: .top)
                .scrollContentBackground(.hidden)
                
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
            .sheet(isPresented: $showAddReminderSheet) {
                AddReminderSheet()
            }
        }
    }
    
    // MARK: - Header Row
    
    private var headerRow: some View {
        HStack(alignment: .bottom) {
            // Greeting text on left
            let titleString: AttributedString = {
                let name = userName.isEmpty ? "User" : userName
                var a = AttributedString("\(greeting)\n\(name)!")
                
                // Apply base font to the whole string
                a.font = .system(size: 28, weight: .bold)
                a.foregroundColor = .primary
                
                // Apply blue color to name
                if let rangeName = a.range(of: name) {
                    a[rangeName].foregroundColor = Color(red: 0.38, green: 0.51, blue: 0.98)
                }
                return a
            }()
            
            Text(titleString)
            
            Spacer()
            
            // Icons on right
            HStack(spacing: 14) {
                // Notification button
                Button {
                    showNotifications = true
                } label: {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(.primary.opacity(0.7))
                }
                .buttonStyle(.plain)
                
                // Profile button
                ProfileIconView(
                    profilePhoto: profileData?.profilePhoto,
                    size: 63,
                    action: {
                        showSettings = true
                    }
                )
            }
        }
    }
    
    // MARK: - Add Reminder Button
    
    private var addReminderButton: some View {
        Button {
            showAddReminderSheet = true
        } label: {
            Text("Add Network Reminder")
                .font(.custom(AppFontName.workSansMedium, size: 16))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(Color(red: 0.09, green: 0.09, blue: 0.11))
                .cornerRadius(100)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - AI Summary Section
    
    private var aiSummarySection: some View {
        Text(aiSummary)
            .font(.custom(AppFontName.workSansRegular, size: 15))
            .lineSpacing(4)
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Subviews

    private var backgroundColor: Color {
        colorScheme == .dark
            ? AppColors.deepNavy
            : Color(red: 0xF1/255, green: 0xF2/255, blue: 0xF6/255)
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
