//
//  AIContextSnapshot.swift
//  warmnet
//
//  Created for AI Insights feature.
//

import Foundation

// MARK: - Main Context Snapshot

/// Complete context snapshot for AI insight generation
/// This is computed on-demand, not persisted to storage
struct AIContextSnapshot: Codable {
    let generatedAt: Date
    let networkOverview: NetworkOverview
    let activityTrends: ActivityTrends
    let todaysStatus: TodaysStatus
    let userProfile: UserProfileContext
    let upcomingEvents: UpcomingEvents
    let tierProgress: [TierProgressSummary]
}

// MARK: - Network Overview

struct NetworkOverview: Codable {
    let totalContacts: Int
    let innerCircleCount: Int
    let keyRelationshipsCount: Int
    let broaderNetworkCount: Int
    let overdueCount: Int
    let contactsWithReminders: Int
    
    var tierBreakdown: [String: Int] {
        [
            "innerCircle": innerCircleCount,
            "keyRelationships": keyRelationshipsCount,
            "broaderNetwork": broaderNetworkCount
        ]
    }
}

// MARK: - Activity Trends

struct ActivityTrends: Codable {
    let interactionsLast7Days: Int
    let interactionsLast30Days: Int
    let interactionsPrevious7Days: Int
    let mostActiveInteractionType: String?
    let interactionTypeBreakdown: [String: Int]
    let recentInteractions: [InteractionSummary]
    
    var weeklyTrend: TrendDirection {
        if interactionsLast7Days > interactionsPrevious7Days {
            return .increasing
        } else if interactionsLast7Days < interactionsPrevious7Days {
            return .decreasing
        } else {
            return .stable
        }
    }
    
    var weeklyChangePercentage: Double {
        guard interactionsPrevious7Days > 0 else {
            return interactionsLast7Days > 0 ? 100.0 : 0.0
        }
        return Double(interactionsLast7Days - interactionsPrevious7Days) / Double(interactionsPrevious7Days) * 100.0
    }
}

enum TrendDirection: String, Codable {
    case increasing = "increasing"
    case decreasing = "decreasing"
    case stable = "stable"
    
    var displayText: String {
        switch self {
        case .increasing: return "trending up"
        case .decreasing: return "trending down"
        case .stable: return "stable"
        }
    }
    
    var emoji: String {
        switch self {
        case .increasing: return "📈"
        case .decreasing: return "📉"
        case .stable: return "➡️"
        }
    }
}

// MARK: - Today's Status

struct TodaysStatus: Codable {
    let goalsCount: Int
    let completedToday: Int
    let remainingGoals: [ContactSummary]
    let overdueContacts: [ContactSummary]
    
    var completionPercentage: Double {
        guard goalsCount > 0 else { return 100.0 }
        return Double(completedToday) / Double(goalsCount) * 100.0
    }
    
    var isAllCaughtUp: Bool {
        remainingGoals.isEmpty && overdueContacts.isEmpty
    }
}

// MARK: - User Profile Context

struct UserProfileContext: Codable {
    let name: String?
    let relationshipGoal: String?
    let communicationStyle: String?
    let challenges: [String]
    let connectionSize: String?
    let hasCompletedOnboarding: Bool
}

// MARK: - Upcoming Events

struct UpcomingEvents: Codable {
    let birthdaysThisWeek: [ContactSummary]
    let birthdaysThisMonth: [ContactSummary]
    let milestonesThisWeek: [MilestoneSummary]
    let milestonesThisMonth: [MilestoneSummary]
    
    var hasUpcomingBirthdays: Bool {
        !birthdaysThisWeek.isEmpty || !birthdaysThisMonth.isEmpty
    }
    
    var hasUpcomingMilestones: Bool {
        !milestonesThisWeek.isEmpty || !milestonesThisMonth.isEmpty
    }
}

// MARK: - Tier Progress Summary

struct TierProgressSummary: Codable, Identifiable {
    let id: String
    let tierName: String
    let contacted: Int
    let total: Int
    let windowDays: Int
    
    var progress: Double {
        guard total > 0 else { return 0.0 }
        return Double(contacted) / Double(total)
    }
    
    var isComplete: Bool {
        total > 0 && contacted >= total
    }
    
    var displayText: String {
        "\(contacted)/\(total)"
    }
}

// MARK: - Contact Summary

struct ContactSummary: Codable, Identifiable {
    let id: UUID
    let name: String
    let priority: String?
    let daysOverdue: Int?
    let company: String?
    let jobTitle: String?
    let lastContactedDaysAgo: Int?
    let city: String?
    let hasBirthdaySoon: Bool
    let hasUpcomingMilestone: Bool
    
    init(
        id: UUID,
        name: String,
        priority: String? = nil,
        daysOverdue: Int? = nil,
        company: String? = nil,
        jobTitle: String? = nil,
        lastContactedDaysAgo: Int? = nil,
        city: String? = nil,
        hasBirthdaySoon: Bool = false,
        hasUpcomingMilestone: Bool = false
    ) {
        self.id = id
        self.name = name
        self.priority = priority
        self.daysOverdue = daysOverdue
        self.company = company
        self.jobTitle = jobTitle
        self.lastContactedDaysAgo = lastContactedDaysAgo
        self.city = city
        self.hasBirthdaySoon = hasBirthdaySoon
        self.hasUpcomingMilestone = hasUpcomingMilestone
    }
}

// MARK: - Interaction Summary

struct InteractionSummary: Codable, Identifiable {
    let id: UUID
    let contactName: String
    let contactId: UUID
    let type: String
    let daysAgo: Int
    let hasNotes: Bool
    let date: Date
}

// MARK: - Milestone Summary

struct MilestoneSummary: Codable, Identifiable {
    let id: UUID
    let title: String
    let contactName: String
    let contactId: UUID
    let daysUntil: Int
    let date: Date
}

// MARK: - Quick Insight Context (Lightweight)

/// Lightweight context for home screen quick insights
/// Faster to compute than full snapshot
struct QuickInsightContext {
    let todaysGoalsCount: Int
    let completedToday: Int
    let overdueCount: Int
    let interactionsThisWeek: Int
    let hasUpcomingBirthdays: Bool
    let networkHealthScore: Double
    let weeklyTrend: TrendDirection
    let userName: String?
    
    var isAllCaughtUp: Bool {
        todaysGoalsCount == 0 && overdueCount == 0
    }
    
    var remainingGoals: Int {
        max(0, todaysGoalsCount - completedToday)
    }
}

// MARK: - Contact Detail Context (For Deep Dives)

/// Detailed context for a specific contact
struct ContactDetailContext: Codable {
    let contact: ContactSummary
    let recentInteractions: [InteractionSummary]
    let upcomingMilestones: [MilestoneSummary]
    let interactionFrequency: Double // Average days between interactions
    let totalInteractions: Int
    let lastInteractionType: String?
    let relationshipStrength: RelationshipStrength
}

enum RelationshipStrength: String, Codable {
    case strong = "strong"
    case healthy = "healthy"
    case needsAttention = "needs_attention"
    case atRisk = "at_risk"
    
    var displayText: String {
        switch self {
        case .strong: return "Strong"
        case .healthy: return "Healthy"
        case .needsAttention: return "Needs Attention"
        case .atRisk: return "At Risk"
        }
    }
}

// MARK: - Insight Types

/// Types of insights that can be generated
enum InsightType: Equatable {
    case homeSummary
    case networkAnalysis
    case interactionIdeas(contactId: UUID, contactName: String)
    case networkOpportunity
    case trendAnalysis
    case contactDeepDive(contactId: UUID)
    case weeklyTrendInsight(timePeriod: TrendTimePeriod)
    
    var title: String {
        switch self {
        case .homeSummary:
            return "Daily Summary"
        case .networkAnalysis:
            return "Network Analysis"
        case .interactionIdeas:
            return "Interaction Ideas"
        case .networkOpportunity:
            return "Network Opportunities"
        case .trendAnalysis:
            return "Trend Analysis"
        case .contactDeepDive:
            return "Contact Insights"
        case .weeklyTrendInsight:
            return "Weekly Trend Insights"
        }
    }
}

// MARK: - Trend Time Period

/// Time period options for trend analysis filtering
enum TrendTimePeriod: String, CaseIterable, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    
    var displayName: String {
        rawValue
    }
    
    /// Number of days to look back for this time period
    var lookbackDays: Int {
        switch self {
        case .daily:
            return 7  // Last 7 days for daily view
        case .weekly:
            return 28 // Last 4 weeks for weekly view
        }
    }
}

// MARK: - Trend Analysis Context

/// Context structure for detailed trend analysis
struct TrendAnalysisContext: Codable {
    let timePeriod: TrendTimePeriod
    let totalConnections: Int
    let averagePerDay: Double
    let bestDay: TrendDayInfo?
    let worstDay: TrendDayInfo?
    let trendDirection: TrendDirection
    let percentageChange: Double
    let dailyBreakdown: [TrendDayInfo]
    
    var formattedAverage: String {
        String(format: "%.1f", averagePerDay)
    }
    
    var formattedPercentageChange: String {
        let sign = percentageChange >= 0 ? "+" : ""
        return "\(sign)\(Int(percentageChange))%"
    }
}

/// Information about a specific day's trend data
struct TrendDayInfo: Codable, Identifiable {
    let id: UUID
    let date: Date
    let count: Int
    
    init(date: Date, count: Int) {
        self.id = UUID()
        self.date = date
        self.count = count
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    var fullFormattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}
