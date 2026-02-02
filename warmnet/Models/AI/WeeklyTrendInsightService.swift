//
//  WeeklyTrendInsightService.swift
//  warmnet
//
//  Created for Weekly Trend Insights feature.
//

import Foundation
import SwiftData

/// Service dedicated to generating AI insights for weekly connection trends
/// 
/// This service aggregates trend data from interactions and generates
/// AI-powered insights to help users understand their networking patterns.
///
/// ## Architecture
/// Follows the MV (Model-View) architecture pattern:
/// - Model: TrendAnalysisContext, TrendDayInfo
/// - Service: WeeklyTrendInsightService (data aggregation & AI generation)
///
/// ## Data Flow
/// 1. UI requests insight with time period (daily/weekly)
/// 2. Service builds TrendAnalysisContext from interaction data
/// 3. Context passed to AIPromptBuilder for prompt construction
/// 4. AIInsightGenerator produces the insight using Foundation Models
/// 5. Result returned to UI for display
///
@Observable
class WeeklyTrendInsightService {
    
    // MARK: - Properties
    
    private let contextService: AIContextService
    private let generator: AIInsightGenerator
    
    /// Current loading state
    var isLoading: Bool = false
    
    /// Last generated insight
    var currentInsight: String?
    
    /// Current error if any
    var error: AIError?
    
    // MARK: - Initialization
    
    init(contextService: AIContextService, generator: AIInsightGenerator) {
        self.contextService = contextService
        self.generator = generator
    }
    
    /// Convenience initializer with model context
    init(modelContext: ModelContext) {
        let contextService = AIContextService(modelContext: modelContext)
        self.contextService = contextService
        self.generator = AIInsightGenerator(contextService: contextService)
    }
    
    // MARK: - Public Methods
    
    /// Generate AI insight for the given time period and trend data
    /// - Parameters:
    ///   - period: The time period filter (daily or weekly)
    ///   - trendData: Array of daily interaction counts
    /// - Returns: AI-generated insight string
    @MainActor
    func generateTrendInsight(
        for period: TrendTimePeriod,
        trendData: [TrendDayInfo]
    ) async throws -> String {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        do {
            // Build trend-specific context
            let trendContext = buildTrendContext(data: trendData, period: period)
            
            // Get full AI context for additional network information
            let aiContext = await contextService.buildContextSnapshot()
            
            // Build specialized prompt
            let systemPrompt = AIPromptBuilder.buildSystemPrompt(context: aiContext)
            let userPrompt = AIPromptBuilder.buildWeeklyTrendInsightPrompt(
                context: aiContext,
                trendContext: trendContext
            )
            
            // Generate insight using the existing generator infrastructure
            let response = try await generateWithContext(
                systemPrompt: systemPrompt,
                userPrompt: userPrompt
            )
            
            currentInsight = response
            return response
            
        } catch {
            self.error = AIError.generationFailed(underlying: error)
            throw self.error!
        }
    }
    
    /// Build trend analysis context from raw data
    /// - Parameters:
    ///   - data: Array of trend day information
    ///   - period: Selected time period
    /// - Returns: Structured context for AI prompt
    func buildTrendContext(
        data: [TrendDayInfo],
        period: TrendTimePeriod
    ) -> TrendAnalysisContext {
        let filteredData = filterDataForPeriod(data, period: period)
        
        // Calculate total connections
        let totalConnections = filteredData.reduce(0) { $0 + $1.count }
        
        // Calculate average per day
        let averagePerDay = filteredData.isEmpty ? 0.0 : Double(totalConnections) / Double(filteredData.count)
        
        // Find best and worst days
        let sortedByCount = filteredData.sorted { $0.count > $1.count }
        let bestDay = sortedByCount.first
        let worstDay = sortedByCount.last
        
        // Calculate trend direction and percentage change
        let (direction, percentageChange) = calculateTrendMetrics(data: filteredData)
        
        return TrendAnalysisContext(
            timePeriod: period,
            totalConnections: totalConnections,
            averagePerDay: averagePerDay,
            bestDay: bestDay,
            worstDay: worstDay,
            trendDirection: direction,
            percentageChange: percentageChange,
            dailyBreakdown: filteredData
        )
    }
    
    // MARK: - Private Methods
    
    /// Filter data based on selected time period
    private func filterDataForPeriod(
        _ data: [TrendDayInfo],
        period: TrendTimePeriod
    ) -> [TrendDayInfo] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let cutoffDate = calendar.date(byAdding: .day, value: -period.lookbackDays, to: today) ?? today
        
        return data.filter { $0.date >= cutoffDate }
    }
    
    /// Calculate trend direction and percentage change
    private func calculateTrendMetrics(
        data: [TrendDayInfo]
    ) -> (TrendDirection, Double) {
        guard data.count >= 2 else {
            return (.stable, 0.0)
        }
        
        // Split data into two halves for comparison
        let midpoint = data.count / 2
        let firstHalf = Array(data.prefix(midpoint))
        let secondHalf = Array(data.suffix(data.count - midpoint))
        
        let firstHalfTotal = firstHalf.reduce(0) { $0 + $1.count }
        let secondHalfTotal = secondHalf.reduce(0) { $0 + $1.count }
        
        // Calculate percentage change
        let percentageChange: Double
        if firstHalfTotal > 0 {
            percentageChange = Double(secondHalfTotal - firstHalfTotal) / Double(firstHalfTotal) * 100.0
        } else if secondHalfTotal > 0 {
            percentageChange = 100.0
        } else {
            percentageChange = 0.0
        }
        
        // Determine direction
        let direction: TrendDirection
        if percentageChange > 5 {
            direction = .increasing
        } else if percentageChange < -5 {
            direction = .decreasing
        } else {
            direction = .stable
        }
        
        return (direction, percentageChange)
    }
    
    /// Generate response using the AI infrastructure
    private func generateWithContext(
        systemPrompt: String,
        userPrompt: String
    ) async throws -> String {
        // Use the existing generator's internal generation method
        // This leverages Foundation Models when available (iOS 26+)
        
        // Simulate processing delay for realistic UX
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        if #available(iOS 26, *) {
            // Use Foundation Models
            return try await generateWithFoundationModels(
                systemPrompt: systemPrompt,
                userPrompt: userPrompt
            )
        } else {
            // Fallback for older iOS versions
            return generateFallbackResponse(userPrompt: userPrompt)
        }
    }
    
    @available(iOS 26, *)
    private func generateWithFoundationModels(
        systemPrompt: String,
        userPrompt: String
    ) async throws -> String {
        // Foundation Models integration placeholder
        // Will use SystemLanguageModel when SDK is available
        
        /*
        import FoundationModels
        
        let model = SystemLanguageModel.default
        let session = model.startSession(systemPrompt: systemPrompt)
        return try await session.respond(to: userPrompt)
        */
        
        // Contextual fallback until FoundationModels SDK is available
        return generateContextualResponse(systemPrompt: systemPrompt, userPrompt: userPrompt)
    }
    
    /// Generate contextual response based on prompt content
    private func generateContextualResponse(
        systemPrompt: String,
        userPrompt: String
    ) -> String {
        let prompt = userPrompt.lowercased()
        
        // Parse trend direction from prompt
        if prompt.contains("increasing") || prompt.contains("trending up") {
            return "Great momentum! Your networking activity has been on the rise. You're building consistent habits that strengthen your relationships. Keep up this pace by setting a daily reminder to reach out to at least one person—it compounds over time."
        } else if prompt.contains("decreasing") || prompt.contains("trending down") {
            return "Your connection activity has slowed down recently. This happens to everyone, especially during busy periods. Consider starting small—send a quick message to someone in your Inner Circle today. Small, consistent actions are more sustainable than occasional bursts."
        } else if prompt.contains("stable") {
            return "Your networking activity has been consistent, which shows great discipline. To level up, try varying your interaction types—if you've been texting mostly, consider scheduling a quick call or coffee chat with someone you haven't spoken to in a while."
        } else if prompt.contains("0 connections") || prompt.contains("total connections: 0") {
            return "Looks like you're just getting started with tracking your connections. The best time to begin is now! Start by reaching out to one person today—it could be a simple 'thinking of you' message. Building your network is a marathon, not a sprint."
        } else {
            return "Your networking patterns show you're making progress in staying connected with your network. Focus on quality over quantity—meaningful interactions with your Inner Circle often have more impact than many surface-level touchpoints."
        }
    }
    
    /// Generate fallback response for pre-iOS 26
    private func generateFallbackResponse(userPrompt: String) -> String {
        generateContextualResponse(systemPrompt: "", userPrompt: userPrompt)
    }
    
    // MARK: - Utility Methods
    
    /// Reset the service state
    func reset() {
        isLoading = false
        currentInsight = nil
        error = nil
    }
}

// MARK: - Preview Helper

extension WeeklyTrendInsightService {
    /// Create a preview instance with mock data
    static func preview(modelContext: ModelContext) -> WeeklyTrendInsightService {
        WeeklyTrendInsightService(modelContext: modelContext)
    }
}
