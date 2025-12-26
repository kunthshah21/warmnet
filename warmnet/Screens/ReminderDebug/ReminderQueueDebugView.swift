//
//  ReminderQueueDebugView.swift
//  warmnet
//
//  Created on 26/12/2025.
//

import SwiftUI
import SwiftData

struct ReminderQueueDebugView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var queueContacts: [DailyQueueGenerator.QueueContact] = []
    @State private var allOverdueContacts: [DailyQueueGenerator.QueueContact] = []
    @State private var settings: UserSettings?
    @State private var showingAllOverdue = false
    @State private var selectedContact: DailyQueueGenerator.QueueContact?
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [backgroundTopColor, backgroundBottomColor],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Settings Overview
                    settingsCard
                    
                    // Daily Queue Section
                    dailyQueueSection
                    
                    // All Overdue Section
                    allOverdueSection
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
        }
        .navigationTitle("Reminder Debug")
        .navigationBarTitleDisplayMode(.large)
        .onAppear(perform: loadData)
        .sheet(item: $selectedContact) { queueContact in
            UrgencyBonusDetailView(queueContact: queueContact, settings: settings)
        }
    }
    
    // MARK: - Settings Card
    
    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("System Settings")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let settings = settings {
                VStack(alignment: .leading, spacing: 8) {
                    SettingRow(label: "Daily Queue Size", value: "\(settings.dailyQueueSize)")
                    SettingRow(label: "Urgency Bonus", value: settings.enableUrgencyBonus ? "Enabled ✓" : "Disabled")
                    
                    if settings.enableUrgencyBonus {
                        Divider()
                        SettingRow(label: "Birthday Bonus", value: "+\(Int(settings.birthdayBonusPoints)) pts")
                        SettingRow(label: "Milestone Bonus", value: "+\(Int(settings.milestoneBonusPoints)) pts")
                        SettingRow(label: "Overdue Bonus", value: "+\(Int(settings.severelyOverdueBonusPoints)) pts")
                    }
                }
            } else {
                Text("Loading settings...")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Daily Queue Section
    
    private var dailyQueueSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Daily Queue")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(queueContacts.count) contact\(queueContacts.count == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if queueContacts.isEmpty {
                EmptyQueueCard()
            } else {
                ForEach(Array(queueContacts.enumerated()), id: \.element.contact.id) { index, queueContact in
                    ContactDebugCard(
                        queueContact: queueContact,
                        index: index + 1,
                        onTap: { selectedContact = queueContact }
                    )
                }
            }
        }
    }
    
    // MARK: - All Overdue Section
    
    private var allOverdueSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("All Overdue Contacts")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: { showingAllOverdue.toggle() }) {
                    HStack(spacing: 4) {
                        Text("\(allOverdueContacts.count)")
                            .font(.subheadline)
                        Image(systemName: showingAllOverdue ? "chevron.up" : "chevron.down")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            if showingAllOverdue {
                if allOverdueContacts.isEmpty {
                    Text("No overdue contacts")
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                        )
                } else {
                    ForEach(Array(allOverdueContacts.enumerated()), id: \.element.contact.id) { index, queueContact in
                        ContactDebugCard(
                            queueContact: queueContact,
                            index: index + 1,
                            onTap: { selectedContact = queueContact }
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadData() {
        do {
            // Load settings
            settings = UserSettings.getOrCreate(from: modelContext)
            
            // Load daily queue with details
            queueContacts = try DailyQueueGenerator.fetchDailyQueueWithDetails(from: modelContext)
            
            // Load all overdue contacts
            let descriptor = FetchDescriptor<Contact>()
            let allContacts = try modelContext.fetch(descriptor)
            
            let overdueContacts = allContacts.filter { contact in
                ReminderScheduler.isOverdue(contact)
            }
            
            guard let settings = settings else { return }
            
            allOverdueContacts = overdueContacts.compactMap { contact -> DailyQueueGenerator.QueueContact? in
                guard let priority = contact.priority else { return nil }
                
                let daysOverdue = ReminderScheduler.daysOverdue(contact)
                let config = TierConfiguration.forPriority(priority)
                
                let urgencyBonus = UrgencyBonusCalculator.calculateBonus(
                    for: contact,
                    settings: settings
                )
                let bonusBreakdown = UrgencyBonusCalculator.getBonusBreakdown(
                    for: contact,
                    settings: settings
                )
                
                let priorityScore = Double(daysOverdue * config.tierWeight) + urgencyBonus
                
                return DailyQueueGenerator.QueueContact(
                    contact: contact,
                    priorityScore: priorityScore,
                    daysOverdue: daysOverdue,
                    urgencyBonus: urgencyBonus,
                    bonusBreakdown: bonusBreakdown
                )
            }
            .sorted { $0.priorityScore > $1.priorityScore }
            
        } catch {
            print("Failed to load reminder data: \(error)")
        }
    }
    
    // Background colors
    private var backgroundTopColor: Color {
        colorScheme == .dark ? Color(red: 0.05, green: 0.05, blue: 0.1) : Color(red: 0.95, green: 0.97, blue: 1.0)
    }
    
    private var backgroundBottomColor: Color {
        colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.15) : Color(red: 0.85, green: 0.90, blue: 0.98)
    }
}

// MARK: - Supporting Views

struct ContactDebugCard: View {
    let queueContact: DailyQueueGenerator.QueueContact
    let index: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Header with name and rank
                HStack {
                    Text("#\(index)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(priorityColor)
                        .cornerRadius(8)
                    
                    Text(queueContact.contact.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Priority and Tier
                HStack(spacing: 12) {
                    Label(
                        "Score: \(String(format: "%.1f", queueContact.priorityScore))",
                        systemImage: "star.fill"
                    )
                    .font(.caption)
                    .foregroundColor(.orange)
                    
                    if let priority = queueContact.contact.priority {
                        Text(priority.rawValue)
                            .font(.caption)
                            .foregroundColor(priority.color)
                    }
                }
                
                // Days overdue
                HStack(spacing: 12) {
                    Label(
                        "\(queueContact.daysOverdue) days overdue",
                        systemImage: "clock.fill"
                    )
                    .font(.caption)
                    .foregroundColor(.red)
                    
                    if queueContact.urgencyBonus > 0 {
                        Label(
                            "+\(Int(queueContact.urgencyBonus)) bonus",
                            systemImage: "exclamationmark.triangle.fill"
                        )
                        .font(.caption)
                        .foregroundColor(.orange)
                    }
                }
                
                // Urgency description
                if queueContact.bonusBreakdown.hasAnyBonus {
                    Text(queueContact.bonusBreakdown.urgencyDescription)
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.top, 4)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var priorityColor: Color {
        let score = queueContact.priorityScore
        if score >= 50 { return .red }
        if score >= 30 { return .orange }
        if score >= 15 { return .yellow }
        return .blue
    }
}

struct EmptyQueueCard: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.green)
            
            Text("All caught up!")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("No contacts need attention today")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}

struct SettingRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    NavigationStack {
        ReminderQueueDebugView()
            .modelContainer(for: [Contact.self, UserSettings.self])
    }
}
