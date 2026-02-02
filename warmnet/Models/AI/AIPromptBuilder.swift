//
//  AIPromptBuilder.swift
//  warmnet
//
//  Created for AI Insights feature.
//

import Foundation

/// Builds prompts for the AI Foundation Models
struct AIPromptBuilder {
    
    // MARK: - System Prompt
    
    /// Builds the system prompt with full user context
    static func buildSystemPrompt(context: AIContextSnapshot) -> String {
        var prompt = """
        You are a helpful personal networking assistant for the Warmnet app. Your role is to help users maintain and strengthen their professional and personal relationships.
        
        """
        
        // User Profile
        if let name = context.userProfile.name, !name.isEmpty {
            prompt += "The user's name is \(name). "
        }
        
        if let goal = context.userProfile.relationshipGoal {
            prompt += "Their main goal is: \(goal). "
        }
        
        if let style = context.userProfile.communicationStyle {
            prompt += "Their communication style is: \(style). "
        }
        
        if !context.userProfile.challenges.isEmpty {
            prompt += "They've identified these challenges: \(context.userProfile.challenges.joined(separator: ", ")). "
        }
        
        prompt += "\n\n"
        
        // Network Overview
        prompt += """
        NETWORK OVERVIEW:
        - Total contacts: \(context.networkOverview.totalContacts)
        - Inner Circle (closest relationships): \(context.networkOverview.innerCircleCount)
        - Key Relationships (important connections): \(context.networkOverview.keyRelationshipsCount)
        - Broader Network (acquaintances): \(context.networkOverview.broaderNetworkCount)
        - Currently overdue for contact: \(context.networkOverview.overdueCount)
        
        """
        
        // Today's Status
        prompt += """
        TODAY'S STATUS:
        - Goals for today: \(context.todaysStatus.goalsCount) contacts to reach out to
        - Completed today: \(context.todaysStatus.completedToday)
        - Remaining: \(context.todaysStatus.remainingGoals.count)
        
        """
        
        if !context.todaysStatus.remainingGoals.isEmpty {
            let names = context.todaysStatus.remainingGoals.prefix(5).map { $0.name }
            prompt += "People to contact: \(names.joined(separator: ", "))\n"
        }
        
        // Activity Trends
        prompt += """
        
        RECENT ACTIVITY:
        - Interactions this week: \(context.activityTrends.interactionsLast7Days)
        - Interactions last 30 days: \(context.activityTrends.interactionsLast30Days)
        - Weekly trend: \(context.activityTrends.weeklyTrend.displayText)
        """
        
        if let mostActive = context.activityTrends.mostActiveInteractionType {
            prompt += "\n- Most common interaction type: \(mostActive)"
        }
        
        prompt += "\n"
        
        // Upcoming Events
        if !context.upcomingEvents.birthdaysThisWeek.isEmpty {
            let names = context.upcomingEvents.birthdaysThisWeek.map { $0.name }
            prompt += "\nUPCOMING BIRTHDAYS THIS WEEK: \(names.joined(separator: ", "))"
        }
        
        if !context.upcomingEvents.milestonesThisWeek.isEmpty {
            let milestones = context.upcomingEvents.milestonesThisWeek.map { "\($0.contactName): \($0.title)" }
            prompt += "\nUPCOMING MILESTONES THIS WEEK: \(milestones.joined(separator: "; "))"
        }
        
        // Tier Progress
        if !context.tierProgress.isEmpty {
            prompt += "\n\nNETWORK COVERAGE:"
            for tier in context.tierProgress {
                let percentage = Int(tier.progress * 100)
                prompt += "\n- \(tier.tierName): \(tier.contacted)/\(tier.total) contacted (\(percentage)%) in last \(tier.windowDays) days"
            }
        }
        
        // Guidelines
        prompt += """
        
        
        GUIDELINES:
        - Be concise and encouraging
        - Focus on actionable advice
        - Personalize suggestions based on the user's communication style
        - Acknowledge achievements and progress
        - When suggesting interactions, consider the relationship type and history
        - Keep responses warm and supportive, not robotic
        - Use natural language, avoid bullet points unless specifically helpful
        - Limit responses to 2-3 sentences for summaries, unless more detail is requested
        """
        
        return prompt
    }
    
    // MARK: - User Prompts by Insight Type
    
    /// Builds the user prompt for a specific insight type
    static func buildUserPrompt(for type: InsightType, context: AIContextSnapshot) -> String {
        switch type {
        case .homeSummary:
            return buildHomeSummaryPrompt(context: context)
            
        case .networkAnalysis:
            return buildNetworkAnalysisPrompt(context: context)
            
        case .interactionIdeas(let contactId, let contactName):
            return buildInteractionIdeasPrompt(contactId: contactId, contactName: contactName, context: context)
            
        case .networkOpportunity:
            return buildNetworkOpportunityPrompt(context: context)
            
        case .trendAnalysis:
            return buildTrendAnalysisPrompt(context: context)
            
        case .contactDeepDive(let contactId):
            return buildContactDeepDivePrompt(contactId: contactId, context: context)
            
        case .weeklyTrendInsight:
            // For weekly trend insight, use the dedicated method with TrendAnalysisContext
            // This case is handled separately via buildWeeklyTrendInsightPrompt
            return buildTrendAnalysisPrompt(context: context)
        }
    }
    
    private static func buildHomeSummaryPrompt(context: AIContextSnapshot) -> String {
        if context.todaysStatus.isAllCaughtUp {
            return """
            The user is all caught up with their networking goals! Generate a brief, encouraging message (2-3 sentences) that:
            1. Celebrates their achievement
            2. Suggests a proactive networking action they could take
            
            Consider their communication style and any upcoming events like birthdays.
            """
        } else {
            return """
            Generate a brief daily summary (2-3 sentences) for the user that:
            1. Acknowledges their current networking status
            2. Highlights the most important contact to reach out to today
            3. Provides motivation or a specific tip
            
            Focus on being helpful and encouraging, not overwhelming.
            """
        }
    }
    
    private static func buildNetworkAnalysisPrompt(context: AIContextSnapshot) -> String {
        return """
        Provide a thoughtful analysis of the user's networking patterns (3-4 sentences). Include:
        1. An observation about their recent activity trends
        2. Insight into which relationship tier might need more attention
        3. A specific, actionable suggestion to improve their network health
        
        Be analytical but warm. Reference specific numbers from their data when relevant.
        """
    }
    
    private static func buildInteractionIdeasPrompt(contactId: UUID, contactName: String, context: AIContextSnapshot) -> String {
        // Find contact details in context
        let contactInfo = context.todaysStatus.remainingGoals.first { $0.id == contactId }
            ?? context.todaysStatus.overdueContacts.first { $0.id == contactId }
        
        var prompt = """
        Suggest 3 specific interaction ideas for reaching out to \(contactName).
        """
        
        if let contact = contactInfo {
            if let company = contact.company {
                prompt += " They work at \(company)."
            }
            if let jobTitle = contact.jobTitle {
                prompt += " Their role is \(jobTitle)."
            }
            if let daysAgo = contact.lastContactedDaysAgo {
                prompt += " Last contacted \(daysAgo) days ago."
            }
            if contact.hasBirthdaySoon {
                prompt += " Their birthday is coming up soon!"
            }
        }
        
        prompt += """
        
        
        Consider the user's communication style when suggesting ideas. Make suggestions specific and easy to act on.
        Format as a numbered list.
        """
        
        return prompt
    }
    
    private static func buildNetworkOpportunityPrompt(context: AIContextSnapshot) -> String {
        var prompt = """
        Based on the user's network data, identify one networking opportunity they might be missing. This could be:
        - A connection they haven't reached out to in a while
        - A pattern in their interactions that suggests room for improvement
        - A way to leverage their existing relationships
        
        """
        
        // Add context about neglected relationships
        let severelyOverdue = context.todaysStatus.overdueContacts.filter { ($0.daysOverdue ?? 0) > 30 }
        if !severelyOverdue.isEmpty {
            let names = severelyOverdue.prefix(3).map { $0.name }
            prompt += "Notably overdue contacts: \(names.joined(separator: ", ")). "
        }
        
        prompt += """
        
        Provide a specific, actionable suggestion (2-3 sentences). Be encouraging, not guilt-inducing.
        """
        
        return prompt
    }
    
    private static func buildTrendAnalysisPrompt(context: AIContextSnapshot) -> String {
        let trend = context.activityTrends.weeklyTrend
        let changePercent = abs(Int(context.activityTrends.weeklyChangePercentage))
        
        return """
        Analyze the user's networking trends. Their activity is \(trend.displayText) (\(changePercent)% change from last week).
        
        Interactions last 7 days: \(context.activityTrends.interactionsLast7Days)
        Interactions previous 7 days: \(context.activityTrends.interactionsPrevious7Days)
        
        Provide insight into:
        1. What this trend means for their networking goals
        2. One specific action to either maintain momentum or get back on track
        
        Keep it brief (2-3 sentences) and constructive.
        """
    }
    
    private static func buildContactDeepDivePrompt(contactId: UUID, context: AIContextSnapshot) -> String {
        return """
        Provide insights about strengthening this specific relationship. Consider:
        - The contact's tier and expected contact frequency
        - Any recent interactions
        - Upcoming events (birthdays, milestones)
        
        Give 2-3 specific, personalized suggestions for deepening this connection.
        """
    }
    
    // MARK: - Weekly Trend Insight Prompt
    
    /// Builds a specialized prompt for weekly trend analysis insights
    static func buildWeeklyTrendInsightPrompt(
        context: AIContextSnapshot,
        trendContext: TrendAnalysisContext
    ) -> String {
        let periodName = trendContext.timePeriod == .daily ? "daily" : "weekly"
        let trend = trendContext.trendDirection
        let changePercent = abs(Int(trendContext.percentageChange))
        
        var prompt = """
        Analyze the user's networking connection trends for the \(periodName) view.
        
        TREND DATA:
        - Total connections: \(trendContext.totalConnections)
        - Average per day: \(trendContext.formattedAverage)
        - Trend direction: \(trend.displayText) (\(trendContext.formattedPercentageChange) change)
        """
        
        if let bestDay = trendContext.bestDay {
            prompt += "\n- Best day: \(bestDay.fullFormattedDate) with \(bestDay.count) connections"
        }
        
        if let worstDay = trendContext.worstDay, trendContext.totalConnections > 0 {
            prompt += "\n- Lowest day: \(worstDay.fullFormattedDate) with \(worstDay.count) connections"
        }
        
        // Add daily breakdown summary
        if !trendContext.dailyBreakdown.isEmpty {
            let recentDays = trendContext.dailyBreakdown.suffix(7)
            let daysSummary = recentDays.map { "\($0.formattedDate): \($0.count)" }.joined(separator: ", ")
            prompt += "\n- Recent activity: \(daysSummary)"
        }
        
        prompt += """
        
        
        NETWORK CONTEXT:
        - Total contacts in network: \(context.networkOverview.totalContacts)
        - Currently overdue: \(context.networkOverview.overdueCount)
        - Interactions this week: \(context.activityTrends.interactionsLast7Days)
        - Interactions last 30 days: \(context.activityTrends.interactionsLast30Days)
        
        Provide a helpful insight (2-3 sentences) that:
        1. Explains what the trend pattern reveals about their networking habits
        2. Identifies one strength or area of improvement based on the data
        3. Suggests one specific, actionable step to improve or maintain their momentum
        
        Be encouraging and constructive. Focus on patterns and actionable advice.
        """
        
        return prompt
    }
    
    // MARK: - Chat Prompt
    
    /// Builds a chat prompt with conversation history
    static func buildChatPrompt(
        userMessage: String,
        context: AIContextSnapshot,
        history: [ChatMessage]
    ) -> String {
        var prompt = ""
        
        // Include recent conversation history
        if !history.isEmpty {
            prompt += "CONVERSATION HISTORY:\n"
            for message in history.suffix(10) {
                let role = message.role == .user ? "User" : "Assistant"
                prompt += "\(role): \(message.content)\n"
            }
            prompt += "\n"
        }
        
        prompt += "User: \(userMessage)\n\n"
        prompt += "Respond helpfully to the user's message. Keep your response concise and relevant to their networking needs. If they're asking about specific contacts or data, reference the context provided in your system prompt."
        
        return prompt
    }
    
    // MARK: - Quick Insight Prompts
    
    /// Builds a quick prompt for home screen from lightweight context
    static func buildQuickInsightPrompt(context: QuickInsightContext) -> String {
        var systemContext = "You are a networking assistant. "
        
        if let name = context.userName {
            systemContext += "The user is \(name). "
        }
        
        systemContext += """
        Today's status: \(context.todaysGoalsCount) goals, \(context.completedToday) completed. \
        \(context.overdueCount) overdue contacts. \
        \(context.interactionsThisWeek) interactions this week (\(context.weeklyTrend.displayText)). \
        Network health: \(Int(context.networkHealthScore))%.
        """
        
        if context.hasUpcomingBirthdays {
            systemContext += " There are upcoming birthdays this week."
        }
        
        let userPrompt: String
        if context.isAllCaughtUp {
            userPrompt = "Generate a brief (1-2 sentences) encouraging message. The user is caught up on their networking!"
        } else {
            userPrompt = "Generate a brief (1-2 sentences) summary of their networking status with one actionable tip."
        }
        
        return systemContext + "\n\n" + userPrompt
    }
}
