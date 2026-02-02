//
//  AIContextService.swift
//  warmnet
//
//  Created for AI Insights feature.
//

import Foundation
import SwiftData
import SwiftUI

/// Service that aggregates data from SwiftData into context snapshots for AI
@Observable
class AIContextService {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Public Methods
    
    /// Build a complete context snapshot for AI insight generation
    /// This is the main method used for detailed insights and chat
    func buildContextSnapshot() async -> AIContextSnapshot {
        await MainActor.run {
            AIContextSnapshot(
                generatedAt: Date(),
                networkOverview: fetchNetworkOverview(),
                activityTrends: fetchActivityTrends(),
                todaysStatus: fetchTodaysStatus(),
                userProfile: fetchUserProfile(),
                upcomingEvents: fetchUpcomingEvents(),
                tierProgress: fetchTierProgress()
            )
        }
    }
    
    /// Get lightweight context for home screen quick insights
    /// Faster to compute than full snapshot
    func getQuickInsightContext() -> QuickInsightContext {
        let contacts = fetchAllContacts()
        let interactions = fetchAllInteractions()
        let personalisationData = fetchPersonalisationData()
        
        let today = Calendar.current.startOfDay(for: Date())
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: today) ?? today
        let fourteenDaysAgo = Calendar.current.date(byAdding: .day, value: -14, to: today) ?? today
        
        // Today's goals
        let todaysGoals = contacts.filter { contact in
            let due = Calendar.current.startOfDay(for: contact.nextReminderDate)
            return due <= today
        }
        
        // Completed today (interactions logged today)
        let completedToday = interactions.filter { interaction in
            Calendar.current.isDateInToday(interaction.date)
        }.count
        
        // Overdue contacts
        let overdueCount = contacts.filter { $0.isOverdue }.count
        
        // Interactions this week
        let interactionsThisWeek = interactions.filter { $0.date >= sevenDaysAgo }.count
        
        // Interactions previous week (for trend)
        let interactionsPreviousWeek = interactions.filter {
            $0.date >= fourteenDaysAgo && $0.date < sevenDaysAgo
        }.count
        
        // Weekly trend
        let weeklyTrend: TrendDirection
        if interactionsThisWeek > interactionsPreviousWeek {
            weeklyTrend = .increasing
        } else if interactionsThisWeek < interactionsPreviousWeek {
            weeklyTrend = .decreasing
        } else {
            weeklyTrend = .stable
        }
        
        // Upcoming birthdays
        let hasUpcomingBirthdays = contacts.contains { contact in
            guard let birthday = contact.birthday else { return false }
            return isBirthdayWithinDays(birthday, days: 7)
        }
        
        // Network health score (0-100)
        let networkHealthScore = calculateNetworkHealthScore(contacts: contacts)
        
        return QuickInsightContext(
            todaysGoalsCount: todaysGoals.count,
            completedToday: completedToday,
            overdueCount: overdueCount,
            interactionsThisWeek: interactionsThisWeek,
            hasUpcomingBirthdays: hasUpcomingBirthdays,
            networkHealthScore: networkHealthScore,
            weeklyTrend: weeklyTrend,
            userName: personalisationData?.name
        )
    }
    
    /// Get detailed context for a specific contact
    func getContactContext(for contact: Contact) -> ContactDetailContext {
        let interactions = contact.interactions.sorted { $0.date > $1.date }
        let milestones = contact.milestones.filter { $0.date > Date() }.sorted { $0.date < $1.date }
        
        // Calculate interaction frequency
        let interactionFrequency = calculateInteractionFrequency(interactions: interactions)
        
        // Determine relationship strength
        let relationshipStrength = determineRelationshipStrength(
            contact: contact,
            interactionCount: interactions.count,
            frequency: interactionFrequency
        )
        
        return ContactDetailContext(
            contact: contactToSummary(contact),
            recentInteractions: interactions.prefix(10).map { interactionToSummary($0) },
            upcomingMilestones: milestones.prefix(5).map { milestoneToSummary($0) },
            interactionFrequency: interactionFrequency,
            totalInteractions: interactions.count,
            lastInteractionType: interactions.first?.interactionType.rawValue,
            relationshipStrength: relationshipStrength
        )
    }
    
    // MARK: - Private Fetch Methods
    
    private func fetchNetworkOverview() -> NetworkOverview {
        let contacts = fetchAllContacts()
        
        let innerCircleCount = contacts.filter { $0.priority == .innerCircle }.count
        let keyRelationshipsCount = contacts.filter { $0.priority == .keyRelationships }.count
        let broaderNetworkCount = contacts.filter { $0.priority == .broaderNetwork }.count
        let overdueCount = contacts.filter { $0.isOverdue }.count
        let contactsWithReminders = contacts.filter { $0.nextTouchDate != nil }.count
        
        return NetworkOverview(
            totalContacts: contacts.count,
            innerCircleCount: innerCircleCount,
            keyRelationshipsCount: keyRelationshipsCount,
            broaderNetworkCount: broaderNetworkCount,
            overdueCount: overdueCount,
            contactsWithReminders: contactsWithReminders
        )
    }
    
    private func fetchActivityTrends() -> ActivityTrends {
        let interactions = fetchAllInteractions()
        let today = Calendar.current.startOfDay(for: Date())
        
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: today) ?? today
        let fourteenDaysAgo = Calendar.current.date(byAdding: .day, value: -14, to: today) ?? today
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: today) ?? today
        
        // Count interactions by time period
        let last7Days = interactions.filter { $0.date >= sevenDaysAgo }
        let previous7Days = interactions.filter { $0.date >= fourteenDaysAgo && $0.date < sevenDaysAgo }
        let last30Days = interactions.filter { $0.date >= thirtyDaysAgo }
        
        // Interaction type breakdown
        var typeBreakdown: [String: Int] = [:]
        for interaction in last30Days {
            let type = interaction.interactionType.rawValue
            typeBreakdown[type, default: 0] += 1
        }
        
        // Most active type
        let mostActiveType = typeBreakdown.max { $0.value < $1.value }?.key
        
        // Recent interactions (last 10)
        let recentInteractions = interactions
            .sorted { $0.date > $1.date }
            .prefix(10)
            .map { interactionToSummary($0) }
        
        return ActivityTrends(
            interactionsLast7Days: last7Days.count,
            interactionsLast30Days: last30Days.count,
            interactionsPrevious7Days: previous7Days.count,
            mostActiveInteractionType: mostActiveType,
            interactionTypeBreakdown: typeBreakdown,
            recentInteractions: Array(recentInteractions)
        )
    }
    
    private func fetchTodaysStatus() -> TodaysStatus {
        let contacts = fetchAllContacts()
        let interactions = fetchAllInteractions()
        let today = Calendar.current.startOfDay(for: Date())
        
        // Contacts due today or overdue
        let dueContacts = contacts.filter { contact in
            let due = Calendar.current.startOfDay(for: contact.nextReminderDate)
            return due <= today
        }
        
        // Contacts interacted with today
        let contactedTodayIds = Set(
            interactions
                .filter { Calendar.current.isDateInToday($0.date) }
                .compactMap { $0.contact?.id }
        )
        
        let completedToday = contactedTodayIds.count
        
        // Remaining goals (due but not contacted today)
        let remainingGoals = dueContacts
            .filter { !contactedTodayIds.contains($0.id) }
            .sorted { $0.nextReminderDate < $1.nextReminderDate }
            .prefix(10)
            .map { contactToSummary($0) }
        
        // Overdue contacts
        let overdueContacts = contacts
            .filter { $0.isOverdue }
            .sorted { $0.nextReminderDate < $1.nextReminderDate }
            .prefix(10)
            .map { contactToSummary($0) }
        
        return TodaysStatus(
            goalsCount: dueContacts.count,
            completedToday: completedToday,
            remainingGoals: Array(remainingGoals),
            overdueContacts: Array(overdueContacts)
        )
    }
    
    private func fetchUserProfile() -> UserProfileContext {
        let personalisationData = fetchPersonalisationData()
        
        return UserProfileContext(
            name: personalisationData?.name,
            relationshipGoal: personalisationData?.relationshipGoal?.rawValue,
            communicationStyle: personalisationData?.communicationStyle?.rawValue,
            challenges: personalisationData?.challenges.map { $0.rawValue } ?? [],
            connectionSize: personalisationData?.connectionSize?.rawValue,
            hasCompletedOnboarding: personalisationData?.isComplete ?? false
        )
    }
    
    private func fetchUpcomingEvents() -> UpcomingEvents {
        let contacts = fetchAllContacts()
        let today = Date()
        
        let sevenDaysFromNow = Calendar.current.date(byAdding: .day, value: 7, to: today) ?? today
        let thirtyDaysFromNow = Calendar.current.date(byAdding: .day, value: 30, to: today) ?? today
        
        // Birthdays this week
        let birthdaysThisWeek = contacts
            .filter { contact in
                guard let birthday = contact.birthday else { return false }
                return isBirthdayWithinDays(birthday, days: 7)
            }
            .map { contactToSummary($0, hasBirthdaySoon: true) }
        
        // Birthdays this month (excluding this week)
        let birthdaysThisMonth = contacts
            .filter { contact in
                guard let birthday = contact.birthday else { return false }
                return isBirthdayWithinDays(birthday, days: 30) && !isBirthdayWithinDays(birthday, days: 7)
            }
            .map { contactToSummary($0, hasBirthdaySoon: true) }
        
        // Collect all milestones
        var milestonesThisWeek: [MilestoneSummary] = []
        var milestonesThisMonth: [MilestoneSummary] = []
        
        for contact in contacts {
            for milestone in contact.milestones {
                if milestone.date >= today && milestone.date <= sevenDaysFromNow {
                    milestonesThisWeek.append(milestoneToSummary(milestone))
                } else if milestone.date > sevenDaysFromNow && milestone.date <= thirtyDaysFromNow {
                    milestonesThisMonth.append(milestoneToSummary(milestone))
                }
            }
        }
        
        return UpcomingEvents(
            birthdaysThisWeek: birthdaysThisWeek,
            birthdaysThisMonth: birthdaysThisMonth,
            milestonesThisWeek: milestonesThisWeek.sorted { $0.date < $1.date },
            milestonesThisMonth: milestonesThisMonth.sorted { $0.date < $1.date }
        )
    }
    
    private func fetchTierProgress() -> [TierProgressSummary] {
        let contacts = fetchAllContacts()
        let allProgress = NetworkProgressService.calculateAllProgress(contacts: contacts)
        
        return allProgress.map { progress in
            TierProgressSummary(
                id: progress.tier.rawValue,
                tierName: progress.tier.rawValue,
                contacted: progress.contacted,
                total: progress.total,
                windowDays: progress.windowDays
            )
        }
    }
    
    // MARK: - Data Fetching Helpers
    
    private func fetchAllContacts() -> [Contact] {
        let descriptor = FetchDescriptor<Contact>()
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    private func fetchAllInteractions() -> [Interaction] {
        let descriptor = FetchDescriptor<Interaction>()
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    private func fetchPersonalisationData() -> PersonalisationData? {
        let descriptor = FetchDescriptor<PersonalisationData>()
        return try? modelContext.fetch(descriptor).first
    }
    
    // MARK: - Conversion Helpers
    
    private func contactToSummary(_ contact: Contact, hasBirthdaySoon: Bool = false) -> ContactSummary {
        let daysOverdue: Int?
        if contact.isOverdue {
            daysOverdue = Calendar.current.dateComponents([.day], from: contact.nextReminderDate, to: Date()).day
        } else {
            daysOverdue = nil
        }
        
        let lastContactedDaysAgo: Int?
        if let lastContacted = contact.lastContacted {
            lastContactedDaysAgo = Calendar.current.dateComponents([.day], from: lastContacted, to: Date()).day
        } else {
            lastContactedDaysAgo = nil
        }
        
        let hasUpcomingMilestone = contact.milestones.contains { milestone in
            let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: milestone.date).day ?? 0
            return daysUntil >= 0 && daysUntil <= 14
        }
        
        return ContactSummary(
            id: contact.id,
            name: contact.name,
            priority: contact.priority?.rawValue,
            daysOverdue: daysOverdue,
            company: contact.company.isEmpty ? nil : contact.company,
            jobTitle: contact.jobTitle.isEmpty ? nil : contact.jobTitle,
            lastContactedDaysAgo: lastContactedDaysAgo,
            city: contact.city.isEmpty ? nil : contact.city,
            hasBirthdaySoon: hasBirthdaySoon || isBirthdayWithinDays(contact.birthday, days: 7),
            hasUpcomingMilestone: hasUpcomingMilestone
        )
    }
    
    private func interactionToSummary(_ interaction: Interaction) -> InteractionSummary {
        let daysAgo = Calendar.current.dateComponents([.day], from: interaction.date, to: Date()).day ?? 0
        
        return InteractionSummary(
            id: interaction.id,
            contactName: interaction.contact?.name ?? "Unknown",
            contactId: interaction.contact?.id ?? UUID(),
            type: interaction.interactionType.rawValue,
            daysAgo: daysAgo,
            hasNotes: !interaction.notes.isEmpty,
            date: interaction.date
        )
    }
    
    private func milestoneToSummary(_ milestone: Milestone) -> MilestoneSummary {
        let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: milestone.date).day ?? 0
        
        return MilestoneSummary(
            id: milestone.id,
            title: milestone.title,
            contactName: milestone.contact?.name ?? "Unknown",
            contactId: milestone.contact?.id ?? UUID(),
            daysUntil: daysUntil,
            date: milestone.date
        )
    }
    
    // MARK: - Calculation Helpers
    
    private func isBirthdayWithinDays(_ birthday: Date?, days: Int) -> Bool {
        guard let birthday = birthday else { return false }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Get this year's birthday
        var birthdayComponents = calendar.dateComponents([.month, .day], from: birthday)
        birthdayComponents.year = calendar.component(.year, from: today)
        
        guard let thisYearBirthday = calendar.date(from: birthdayComponents) else { return false }
        
        // Check if it's within the window
        let startOfToday = today
        let endOfWindow = calendar.date(byAdding: .day, value: days, to: startOfToday) ?? startOfToday
        
        // Handle birthday that already passed this year
        var targetBirthday = thisYearBirthday
        if thisYearBirthday < startOfToday {
            birthdayComponents.year = calendar.component(.year, from: today) + 1
            targetBirthday = calendar.date(from: birthdayComponents) ?? thisYearBirthday
        }
        
        return targetBirthday >= startOfToday && targetBirthday <= endOfWindow
    }
    
    private func calculateNetworkHealthScore(contacts: [Contact]) -> Double {
        guard !contacts.isEmpty else { return 100.0 }
        
        let overdueCount = contacts.filter { $0.isOverdue }.count
        let overdueRatio = Double(overdueCount) / Double(contacts.count)
        
        // Base score starts at 100, reduced by overdue ratio
        var score = 100.0 - (overdueRatio * 50.0)
        
        // Bonus for tier balance
        let innerCircle = contacts.filter { $0.priority == .innerCircle }.count
        let keyRelationships = contacts.filter { $0.priority == .keyRelationships }.count
        let broaderNetwork = contacts.filter { $0.priority == .broaderNetwork }.count
        
        if innerCircle > 0 && keyRelationships > 0 && broaderNetwork > 0 {
            score += 10.0
        }
        
        return min(100.0, max(0.0, score))
    }
    
    private func calculateInteractionFrequency(interactions: [Interaction]) -> Double {
        guard interactions.count >= 2 else { return 0.0 }
        
        let sortedDates = interactions.map { $0.date }.sorted()
        var totalDays = 0.0
        
        for i in 1..<sortedDates.count {
            let days = Calendar.current.dateComponents([.day], from: sortedDates[i-1], to: sortedDates[i]).day ?? 0
            totalDays += Double(days)
        }
        
        return totalDays / Double(interactions.count - 1)
    }
    
    private func determineRelationshipStrength(
        contact: Contact,
        interactionCount: Int,
        frequency: Double
    ) -> RelationshipStrength {
        // No interactions = at risk
        guard interactionCount > 0 else { return .atRisk }
        
        let expectedFrequency = Double(contact.reminderInterval)
        
        // If overdue by more than 2x the interval = at risk
        if contact.isOverdue {
            let daysOverdue = Calendar.current.dateComponents([.day], from: contact.nextReminderDate, to: Date()).day ?? 0
            if daysOverdue > contact.reminderInterval * 2 {
                return .atRisk
            } else if daysOverdue > contact.reminderInterval {
                return .needsAttention
            }
        }
        
        // Check frequency vs expected
        if frequency > 0 && frequency <= expectedFrequency * 0.8 {
            return .strong
        } else if frequency <= expectedFrequency * 1.2 {
            return .healthy
        } else {
            return .needsAttention
        }
    }
}
