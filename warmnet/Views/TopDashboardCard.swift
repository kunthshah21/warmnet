//
//  TopDashboardCard.swift
//  warmnet
//
//  Created on 14/01/2026.
//

import SwiftUI
import SwiftData

/// Main dashboard card combining profile, notifications, today's goals, and network health
struct TopDashboardCard: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let userName: String
    let profilePhoto: Data?
    let todaysGoals: [Contact]
    let innerCircleCount: Int
    let keyRelationshipsCount: Int
    let broaderNetworkCount: Int
    let onProfileTap: () -> Void
    let onNotificationTap: () -> Void
    let onContactTap: (Contact) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // MARK: - Header Row
            headerRow
            
            // MARK: - Today's Network Goals
            if !todaysGoals.isEmpty {
                todaysGoalsSection
            }
            
            // MARK: - Network Health
            networkHealthSection
        }
        .padding(.horizontal, 20)
        .padding(.top, 60) // Account for safe area
        .padding(.bottom, 24)
        .background(
            // Extend background into safe area at top
            GeometryReader { geo in
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 32,
                    bottomTrailingRadius: 32,
                    topTrailingRadius: 0
                )
                .fill(cardBackgroundColor)
                .shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 8)
                .frame(height: geo.size.height + geo.safeAreaInsets.top)
                .offset(y: -geo.safeAreaInsets.top)
            }
        )
    }
    
    // MARK: - Header Row
    
    private var headerRow: some View {
        HStack {
            // Profile button with greeting
            Button(action: onProfileTap) {
                HStack(spacing: 12) {
                    profileImage
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Hello,")
                            .font(.custom(AppFontName.overpassVariable, size: 14))
                            .foregroundStyle(.secondary)
                        
                        Text(userName.isEmpty ? "User" : userName)
                            .font(.custom(AppFontName.workSansMedium, size: 18))
                            .foregroundStyle(.primary)
                    }
                }
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // Notification button
            Button(action: onNotificationTap) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("Blue-app").opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "bell.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color("Blue-app"))
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    private var profileImage: some View {
        Group {
            if let photoData = profilePhoto,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                ZStack {
                    Circle()
                        .fill(Color("Blue-app").gradient)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
        }
    }
    
    // MARK: - Today's Goals Section
    
    private var todaysGoalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Network Goals")
                .font(.custom(AppFontName.workSansMedium, size: 16))
                .foregroundStyle(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(todaysGoals) { contact in
                        Button {
                            onContactTap(contact)
                        } label: {
                            goalContactCard(for: contact)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    private func goalContactCard(for contact: Contact) -> some View {
        VStack(spacing: 8) {
            AvatarView(name: contact.name, size: 44)
            
            Text(contact.name.components(separatedBy: " ").first ?? contact.name)
                .font(.custom(AppFontName.overpassVariable, size: 12))
                .lineLimit(1)
                .foregroundStyle(.primary)
        }
        .frame(width: 70)
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(goalCardBackgroundColor)
        )
    }
    
    // MARK: - Network Health Section
    
    private var networkHealthSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Network Health")
                .font(.custom(AppFontName.workSansMedium, size: 16))
                .foregroundStyle(.primary)
            
            HStack(spacing: 0) {
                kpiItem(
                    count: innerCircleCount,
                    label: "Inner Circle",
                    icon: "star.fill",
                    color: Color("Green-app")
                )
                
                Divider()
                    .frame(height: 40)
                
                kpiItem(
                    count: keyRelationshipsCount,
                    label: "Key",
                    icon: "person.2.fill",
                    color: Color("Blue-app")
                )
                
                Divider()
                    .frame(height: 40)
                
                kpiItem(
                    count: broaderNetworkCount,
                    label: "Broader",
                    icon: "person.3.fill",
                    color: .yellow
                )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(networkHealthBackgroundColor)
            )
        }
    }
    
    private func kpiItem(count: Int, label: String, icon: String, color: Color) -> some View {
        VStack(alignment: .center, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
                
                Text("\(count)")
                    .font(.custom(AppFontName.workSansMedium, size: 20))
                    .fontWeight(.bold)
                    .contentTransition(.numericText())
            }
            
            Text(label)
                .font(.custom(AppFontName.overpassVariable, size: 11))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Colors
    
    private var cardBackgroundColor: Color {
        colorScheme == .dark
            ? Color(uiColor: .secondarySystemGroupedBackground)
            : Color(uiColor: .systemBackground)
    }
    
    private var goalCardBackgroundColor: Color {
        colorScheme == .dark
            ? Color(uiColor: .tertiarySystemGroupedBackground)
            : Color(uiColor: .secondarySystemGroupedBackground)
    }
    
    private var networkHealthBackgroundColor: Color {
        colorScheme == .dark
            ? Color(uiColor: .tertiarySystemGroupedBackground)
            : Color("Red-app").opacity(0.1)
    }
}

// MARK: - Notifications Sheet

struct NotificationsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let upcomingReminders: [Contact]
    let onContactTap: (Contact) -> Void
    
    var body: some View {
        NavigationStack {
            Group {
                if upcomingReminders.isEmpty {
                    emptyState
                } else {
                    remindersList
                }
            }
            .navigationTitle("Reminders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("No upcoming reminders")
                .font(.custom(AppFontName.workSansMedium, size: 18))
                .foregroundStyle(.secondary)
            
            Text("Your scheduled contacts will appear here")
                .font(.custom(AppFontName.overpassVariable, size: 14))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var remindersList: some View {
        List {
            Section {
                ForEach(upcomingReminders.prefix(10)) { contact in
                    Button {
                        onContactTap(contact)
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            AvatarView(name: contact.name, size: 40)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(contact.name)
                                    .font(.custom(AppFontName.workSansMedium, size: 16))
                                    .foregroundStyle(.primary)
                                
                                Text(formattedDate(contact.nextReminderDate))
                                    .font(.custom(AppFontName.overpassVariable, size: 13))
                                    .foregroundStyle(contact.isOverdue ? Color("Red-app") : .secondary)
                            }
                            
                            Spacer()
                            
                            if contact.isOverdue {
                                Text("Overdue")
                                    .font(.custom(AppFontName.overpassVariable, size: 12))
                                    .foregroundStyle(Color("Red-app"))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color("Red-app").opacity(0.15))
                                    )
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("Upcoming")
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, configurations: config)
    
    // Create sample contacts
    let sampleContacts = [
        Contact(name: "Sarah Johnson", priority: .innerCircle),
        Contact(name: "Mike Chen", priority: .keyRelationships),
        Contact(name: "Emma Wilson", priority: .innerCircle),
        Contact(name: "James Brown", priority: .broaderNetwork),
        Contact(name: "Lisa Park", priority: .keyRelationships)
    ]
    
    for contact in sampleContacts {
        container.mainContext.insert(contact)
    }
    
    return ZStack {
        Color(uiColor: .systemGroupedBackground)
            .ignoresSafeArea()
        
        ScrollView {
            VStack(spacing: 16) {
                TopDashboardCard(
                    userName: "Kunth",
                    profilePhoto: nil,
                    todaysGoals: sampleContacts,
                    innerCircleCount: 3,
                    keyRelationshipsCount: 2,
                    broaderNetworkCount: 2,
                    onProfileTap: {},
                    onNotificationTap: {},
                    onContactTap: { _ in }
                )
                .ignoresSafeArea(edges: .top)
                
                // Placeholder for other content
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    .frame(height: 120)
                    .padding(.horizontal, 16)
            }
        }
    }
    .modelContainer(container)
}
