//
//  AIInsightGenerator.swift
//  warmnet
//
//  Created for AI Insights feature.
//

import Foundation
import SwiftUI
import SwiftData

// MARK: - AI Error Types

enum AIError: Error, LocalizedError {
    case modelNotAvailable
    case generationFailed(underlying: Error)
    case contextBuildFailed
    case sessionNotStarted
    case streamingFailed
    case cancelled
    
    var errorDescription: String? {
        switch self {
        case .modelNotAvailable:
            return "AI features are not available on this device."
        case .generationFailed(let error):
            return "Failed to generate insight: \(error.localizedDescription)"
        case .contextBuildFailed:
            return "Unable to gather context for insights."
        case .sessionNotStarted:
            return "AI session could not be started."
        case .streamingFailed:
            return "Streaming response failed."
        case .cancelled:
            return "Request was cancelled."
        }
    }
}

// MARK: - AI Insight Generator

/// Core service for generating AI insights using Foundation Models
@Observable
class AIInsightGenerator {
    
    // MARK: - Properties
    
    private let contextService: AIContextService
    let conversationManager: AIConversationManager
    
    /// Current loading state
    var isGeneratingInsight = false
    
    /// Current streaming state
    var isStreaming = false
    
    /// Last generated insight
    var currentInsight: String?
    
    /// Current error if any
    var error: AIError?
    
    /// Streaming text buffer
    var streamingText: String = ""
    
    // MARK: - Initialization
    
    init(contextService: AIContextService, conversationManager: AIConversationManager = AIConversationManager()) {
        self.contextService = contextService
        self.conversationManager = conversationManager
    }
    
    // MARK: - Insight Generation
    
    /// Generate an insight for the specified type
    /// This is the main method for generating card insights
    @MainActor
    func generateInsight(type: InsightType) async throws -> String {
        isGeneratingInsight = true
        error = nil
        
        defer { isGeneratingInsight = false }
        
        do {
            // Build context
            let context = await contextService.buildContextSnapshot()
            
            // Build prompts
            let systemPrompt = AIPromptBuilder.buildSystemPrompt(context: context)
            let userPrompt = AIPromptBuilder.buildUserPrompt(for: type, context: context)
            
            // Generate using Foundation Models
            let response = try await generateWithFoundationModels(
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
    
    /// Generate a quick insight for the home screen
    @MainActor
    func generateQuickInsight() async throws -> String {
        isGeneratingInsight = true
        error = nil
        
        defer { isGeneratingInsight = false }
        
        do {
            let quickContext = contextService.getQuickInsightContext()
            let prompt = AIPromptBuilder.buildQuickInsightPrompt(context: quickContext)
            
            let response = try await generateWithFoundationModels(
                systemPrompt: "",
                userPrompt: prompt
            )
            
            currentInsight = response
            return response
            
        } catch {
            self.error = AIError.generationFailed(underlying: error)
            throw self.error!
        }
    }
    
    // MARK: - Chat
    
    /// Send a chat message and get a streaming response
    @MainActor
    func chat(message: String) async throws -> String {
        isStreaming = true
        streamingText = ""
        error = nil
        
        defer { isStreaming = false }
        
        // Add user message to conversation
        conversationManager.addUserMessage(message)
        
        do {
            // Build context
            let context = await contextService.buildContextSnapshot()
            
            // Build prompts
            let systemPrompt = AIPromptBuilder.buildSystemPrompt(context: context)
            let chatPrompt = AIPromptBuilder.buildChatPrompt(
                userMessage: message,
                context: context,
                history: conversationManager.recentHistory
            )
            
            // Generate response
            let response = try await generateWithFoundationModels(
                systemPrompt: systemPrompt,
                userPrompt: chatPrompt
            )
            
            // Add assistant response to conversation
            conversationManager.addAssistantMessage(response)
            
            return response
            
        } catch {
            self.error = AIError.generationFailed(underlying: error)
            throw self.error!
        }
    }
    
    /// Stream a chat response (for real-time display)
    @MainActor
    func streamChat(message: String, onChunk: @escaping (String) -> Void) async throws -> String {
        isStreaming = true
        streamingText = ""
        error = nil
        
        defer { isStreaming = false }
        
        // Add user message to conversation
        conversationManager.addUserMessage(message)
        
        do {
            // Build context
            let context = await contextService.buildContextSnapshot()
            
            // Build prompts
            let systemPrompt = AIPromptBuilder.buildSystemPrompt(context: context)
            let chatPrompt = AIPromptBuilder.buildChatPrompt(
                userMessage: message,
                context: context,
                history: conversationManager.recentHistory
            )
            
            // Stream response
            let response = try await streamWithFoundationModels(
                systemPrompt: systemPrompt,
                userPrompt: chatPrompt,
                onChunk: { [weak self] chunk in
                    self?.streamingText += chunk
                    onChunk(chunk)
                }
            )
            
            // Add assistant response to conversation
            conversationManager.addAssistantMessage(response)
            
            return response
            
        } catch {
            self.error = AIError.streamingFailed
            throw self.error!
        }
    }
    
    // MARK: - Foundation Models Integration
    
    /// Generate response using Apple Foundation Models
    /// This is a placeholder that will use the actual FoundationModels framework
    private func generateWithFoundationModels(
        systemPrompt: String,
        userPrompt: String
    ) async throws -> String {
        // TODO: Replace with actual Foundation Models API when available
        // For now, we'll use a fallback that generates contextual responses
        
        // Simulate network delay for realistic UX
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Check if we should use actual Foundation Models
        if #available(iOS 26, *) {
            return try await generateWithSystemLanguageModel(
                systemPrompt: systemPrompt,
                userPrompt: userPrompt
            )
        } else {
            // Fallback for older iOS versions
            return generateFallbackResponse(userPrompt: userPrompt)
        }
    }
    
    /// Stream response using Apple Foundation Models
    private func streamWithFoundationModels(
        systemPrompt: String,
        userPrompt: String,
        onChunk: @escaping (String) -> Void
    ) async throws -> String {
        // TODO: Replace with actual streaming API when available
        
        if #available(iOS 26, *) {
            return try await streamWithSystemLanguageModel(
                systemPrompt: systemPrompt,
                userPrompt: userPrompt,
                onChunk: onChunk
            )
        } else {
            // Fallback: simulate streaming
            let response = generateFallbackResponse(userPrompt: userPrompt)
            for word in response.split(separator: " ") {
                try await Task.sleep(nanoseconds: 50_000_000) // 50ms per word
                onChunk(String(word) + " ")
            }
            return response
        }
    }
    
    // MARK: - iOS 26+ Foundation Models
    
    @available(iOS 26, *)
    private func generateWithSystemLanguageModel(
        systemPrompt: String,
        userPrompt: String
    ) async throws -> String {
        // Import and use FoundationModels framework
        // This will be the actual implementation once the framework is available
        
        /*
        import FoundationModels
        
        let model = SystemLanguageModel.default
        let session = model.startSession(systemPrompt: systemPrompt)
        return try await session.respond(to: userPrompt)
        */
        
        // Placeholder until FoundationModels is available in the SDK
        return generateContextualFallback(systemPrompt: systemPrompt, userPrompt: userPrompt)
    }
    
    @available(iOS 26, *)
    private func streamWithSystemLanguageModel(
        systemPrompt: String,
        userPrompt: String,
        onChunk: @escaping (String) -> Void
    ) async throws -> String {
        // Import and use FoundationModels framework for streaming
        
        /*
        import FoundationModels
        
        let model = SystemLanguageModel.default
        var fullResponse = ""
        
        for try await chunk in model.stream(prompt: systemPrompt + "\n\n" + userPrompt) {
            fullResponse += chunk
            onChunk(chunk)
        }
        
        return fullResponse
        */
        
        // Placeholder: simulate streaming
        let response = generateContextualFallback(systemPrompt: systemPrompt, userPrompt: userPrompt)
        var fullResponse = ""
        
        for word in response.split(separator: " ") {
            try await Task.sleep(nanoseconds: 30_000_000) // 30ms per word
            let chunk = String(word) + " "
            fullResponse += chunk
            onChunk(chunk)
        }
        
        return fullResponse.trimmingCharacters(in: .whitespaces)
    }
    
    // MARK: - Fallback Responses
    
    /// Generate a contextual fallback response based on the prompt
    private func generateContextualFallback(systemPrompt: String, userPrompt: String) -> String {
        // Parse context from system prompt to generate relevant responses
        let prompt = userPrompt.lowercased()
        
        if prompt.contains("summary") || prompt.contains("status") {
            return "Your network is looking healthy! You have a few contacts to reach out to today. Consider starting with your Inner Circle connections—they're the relationships that matter most."
        } else if prompt.contains("analysis") || prompt.contains("patterns") {
            return "Looking at your networking activity, you've been consistent with your outreach this week. Your Key Relationships tier could use a bit more attention—try scheduling a quick check-in with someone from that group."
        } else if prompt.contains("ideas") || prompt.contains("interaction") {
            return "Here are some ideas: 1) Send a quick text checking in on how their week is going. 2) Share an article or resource relevant to their work. 3) Suggest a brief coffee chat or video call to catch up properly."
        } else if prompt.contains("opportunity") {
            return "I notice you haven't connected with some of your broader network in a while. These lighter-touch relationships can be valuable for unexpected opportunities. A simple 'thinking of you' message can go a long way."
        } else if prompt.contains("trend") {
            return "Your engagement has been steady. To keep the momentum going, try setting a daily reminder to reach out to at least one person. Small, consistent actions build strong networks over time."
        } else if prompt.contains("caught up") || prompt.contains("achievement") {
            return "Great job staying on top of your network! Since you're all caught up, this is a perfect time to strengthen existing relationships. Consider reaching out to someone you haven't spoken to in a while, just to say hello."
        } else {
            return "I'm here to help with your networking! You can ask me about your contacts, get interaction ideas, or understand your networking trends. What would you like to know?"
        }
    }
    
    /// Generate fallback response for pre-iOS 26
    private func generateFallbackResponse(userPrompt: String) -> String {
        generateContextualFallback(systemPrompt: "", userPrompt: userPrompt)
    }
    
    // MARK: - Utility Methods
    
    /// Reset the generator state
    func reset() {
        isGeneratingInsight = false
        isStreaming = false
        currentInsight = nil
        error = nil
        streamingText = ""
    }
    
    /// Clear conversation and reset
    func clearConversation() {
        conversationManager.clearSession()
        reset()
    }
}

// MARK: - Preview Helper

extension AIInsightGenerator {
    /// Create a preview instance with mock data
    static func preview(modelContext: ModelContext) -> AIInsightGenerator {
        let contextService = AIContextService(modelContext: modelContext)
        return AIInsightGenerator(contextService: contextService)
    }
}

