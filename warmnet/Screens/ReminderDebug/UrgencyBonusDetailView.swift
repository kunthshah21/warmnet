//
//  UrgencyBonusDetailView.swift
//  warmnet
//
//  Created on 26/12/2025.
//

import SwiftUI
import SwiftData

struct UrgencyBonusDetailView: View {
    let queueContact: DailyQueueGenerator.QueueContact
    let settings: UserSettings?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
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
                    VStack(spacing: 24) {
                        // Contact Header
                        contactHeaderCard
                        
                        // Priority Score Breakdown
                        priorityScoreCard
                        
                        // Urgency Bonus Breakdown
                        urgencyBonusCard
                        
                        // Reminder Details
                        reminderDetailsCard
                        
                        // Contact Info
                        contactInfoCard
                        
                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }
            .navigationTitle("Contact Details")
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
    
    // MARK: - Contact Header
    
    private var contactHeaderCard: some View {
        VStack(spacing: 12) {
            // Avatar placeholder
            Circle()
                .fill(priorityGradient)
                .frame(width: 80, height: 80)
                .overlay(
                    Text(String(queueContact.contact.name.prefix(1)).uppercased())
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                )
            
            Text(queueContact.contact.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            if let priority = queueContact.contact.priority {
                HStack(spacing: 8) {
                    Circle()
                        .fill(priority.color)
                        .frame(width: 8, height: 8)
                    
                    Text(priority.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Priority Score Card
    
    private var priorityScoreCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.orange)
                Text("Priority Score")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            // Total Score
            HStack {
                Text("Total Score")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(String(format: "%.1f", queueContact.priorityScore))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
            
            Divider()
            
            // Formula breakdown
            VStack(alignment: .leading, spacing: 8) {
                Text("Calculation:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let priority = queueContact.contact.priority {
                    let config = TierConfiguration.forPriority(priority)
                    let baseScore = Double(queueContact.daysOverdue * config.tierWeight)
                    
                    HStack {
                        Text("(\(queueContact.daysOverdue) days × \(config.tierWeight) weight)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.1f", baseScore))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    if queueContact.urgencyBonus > 0 {
                        HStack {
                            Text("+ Urgency Bonus")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(String(format: "+%.1f", queueContact.urgencyBonus))
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.primary.opacity(0.05))
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Urgency Bonus Card
    
    private var urgencyBonusCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("Urgency Bonuses")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            if queueContact.bonusBreakdown.hasAnyBonus {
                // Birthday Bonus
                if queueContact.bonusBreakdown.hasBirthday {
                    BonusDetailRow(
                        icon: "🎂",
                        title: "Birthday Bonus",
                        description: queueContact.bonusBreakdown.birthdayDaysUntil.map { "Birthday in \($0) day\($0 == 1 ? "" : "s")" } ?? "Birthday soon",
                        points: queueContact.bonusBreakdown.birthdayBonus
                    )
                }
                
                // Milestone Bonus
                if queueContact.bonusBreakdown.hasMilestone {
                    if let milestone = queueContact.bonusBreakdown.upcomingMilestone {
                        BonusDetailRow(
                            icon: "🎯",
                            title: "Milestone Bonus",
                            description: milestone.title,
                            points: queueContact.bonusBreakdown.milestoneBonus
                        )
                    }
                }
                
                // Severely Overdue
                if queueContact.bonusBreakdown.isSeverelyOverdue {
                    BonusDetailRow(
                        icon: "⚠️",
                        title: "Severely Overdue",
                        description: "More than 2× past due date",
                        points: queueContact.bonusBreakdown.severelyOverdueBonus
                    )
                }
                
                Divider()
                
                HStack {
                    Text("Total Bonus")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("+\(Int(queueContact.bonusBreakdown.totalBonus)) pts")
                        .font(.headline)
                        .foregroundColor(.orange)
                }
            } else {
                Text("No urgency bonuses applied")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Reminder Details Card
    
    private var reminderDetailsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.blue)
                Text("Reminder Details")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            if let priority = queueContact.contact.priority {
                let config = TierConfiguration.forPriority(priority)
                
                DetailRow(label: "Frequency", value: "\(config.frequencyDays) days")
                DetailRow(label: "Tier Weight", value: "×\(config.tierWeight)")
                DetailRow(label: "Variance", value: "±\(Int(config.variancePercent * 100))%")
                
                Divider()
                
                DetailRow(label: "Days Overdue", value: "\(queueContact.daysOverdue) days", isHighlighted: true)
                
                if let nextTouch = queueContact.contact.nextTouchDate {
                    DetailRow(label: "Due Date", value: formatDate(nextTouch))
                }
                
                if let lastContacted = queueContact.contact.lastContacted {
                    DetailRow(label: "Last Contact", value: formatDate(lastContacted))
                } else {
                    DetailRow(label: "Last Contact", value: "Never", isHighlighted: true)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Contact Info Card
    
    private var contactInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(.purple)
                Text("Contact Information")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            if !queueContact.contact.phoneNumber.isEmpty {
                DetailRow(label: "Phone", value: queueContact.contact.fullPhoneNumber)
            }
            
            if !queueContact.contact.email.isEmpty {
                DetailRow(label: "Email", value: queueContact.contact.email)
            }
            
            if !queueContact.contact.company.isEmpty {
                DetailRow(label: "Company", value: queueContact.contact.company)
            }
            
            if !queueContact.contact.fullLocation.isEmpty {
                DetailRow(label: "Location", value: queueContact.contact.fullLocation)
            }
            
            if let birthday = queueContact.contact.birthday {
                DetailRow(label: "Birthday", value: formatDate(birthday, style: .medium))
            }
            
            DetailRow(label: "Interactions", value: "\(queueContact.contact.interactions.count)")
            DetailRow(label: "Milestones", value: "\(queueContact.contact.milestones.count)")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date, style: DateFormatter.Style = .short) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private var priorityGradient: LinearGradient {
        let score = queueContact.priorityScore
        if score >= 50 {
            return LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        } else if score >= 30 {
            return LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
        } else if score >= 15 {
            return LinearGradient(colors: [.yellow, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
        } else {
            return LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    private var backgroundTopColor: Color {
        colorScheme == .dark ? Color(red: 0.05, green: 0.05, blue: 0.1) : Color(red: 0.95, green: 0.97, blue: 1.0)
    }
    
    private var backgroundBottomColor: Color {
        colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.15) : Color(red: 0.85, green: 0.90, blue: 0.98)
    }
}

// MARK: - Supporting Views

struct BonusDetailRow: View {
    let icon: String
    let title: String
    let description: String
    let points: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(icon)
                    .font(.title3)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("+\(Int(points)) pts")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.leading, 32)
        }
        .padding(.vertical, 4)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    var isHighlighted: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isHighlighted ? .orange : .primary)
        }
    }
}

extension DailyQueueGenerator.QueueContact: Identifiable {
    var id: UUID { contact.id }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, configurations: config)
    let contact = Contact(name: "John Doe", priority: .innerCircle)
    
    let queueContact = DailyQueueGenerator.QueueContact(
        contact: contact,
        priorityScore: 45.5,
        daysOverdue: 15,
        urgencyBonus: 15.0,
        bonusBreakdown: UrgencyBonusCalculator.BonusBreakdown(
            birthdayBonus: 15.0,
            birthdayDaysUntil: 3,
            milestoneBonus: 0,
            upcomingMilestone: nil,
            severelyOverdueBonus: 0,
            totalBonus: 15.0
        )
    )
    
    return UrgencyBonusDetailView(queueContact: queueContact, settings: UserSettings())
        .modelContainer(container)
}
