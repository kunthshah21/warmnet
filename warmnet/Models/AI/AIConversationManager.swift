//
//  AIConversationManager.swift
//  warmnet
//
//  Created for AI Insights feature.
//

import Foundation

// MARK: - Chat Message

/// Represents a single message in a conversation
struct ChatMessage: Codable, Identifiable, Equatable {
    let id: UUID
    let role: MessageRole
    let content: String
    let timestamp: Date
    
    enum MessageRole: String, Codable {
        case user
        case assistant
        case system
    }
    
    init(id: UUID = UUID(), role: MessageRole, content: String, timestamp: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
}

// MARK: - Conversation Session

/// Represents a complete conversation session
struct ConversationSession: Codable, Identifiable {
    let id: UUID
    let startedAt: Date
    var messages: [ChatMessage]
    var lastUpdatedAt: Date
    
    init(id: UUID = UUID()) {
        self.id = id
        self.startedAt = Date()
        self.messages = []
        self.lastUpdatedAt = Date()
    }
    
    var isEmpty: Bool {
        messages.isEmpty
    }
    
    var messageCount: Int {
        messages.count
    }
}

// MARK: - Conversation Manager

/// Manages chat sessions and conversation memory
@Observable
class AIConversationManager {
    
    // MARK: - Properties
    
    /// Current active session
    private(set) var currentSession: ConversationSession?
    
    /// Maximum messages to keep in context window for AI
    private let maxHistorySize = 20
    
    /// Session expiry duration (24 hours)
    private let sessionExpiryHours = 24
    
    /// UserDefaults key for session persistence
    private let sessionStorageKey = "ai_conversation_session"
    
    // MARK: - Computed Properties
    
    /// All messages in the current session
    var messages: [ChatMessage] {
        currentSession?.messages ?? []
    }
    
    /// Recent history for AI context window (limited to maxHistorySize)
    var recentHistory: [ChatMessage] {
        Array(messages.suffix(maxHistorySize))
    }
    
    /// Whether there is an active session
    var hasActiveSession: Bool {
        currentSession != nil && !messages.isEmpty
    }
    
    /// Current session ID
    var currentSessionId: UUID? {
        currentSession?.id
    }
    
    /// When the session started
    var sessionStartedAt: Date? {
        currentSession?.startedAt
    }
    
    // MARK: - Initialization
    
    init() {
        // Try to restore previous session on init
        _ = loadSession()
    }
    
    // MARK: - Message Management
    
    /// Add a user message to the conversation
    func addUserMessage(_ content: String) {
        ensureActiveSession()
        let message = ChatMessage(role: .user, content: content)
        currentSession?.messages.append(message)
        currentSession?.lastUpdatedAt = Date()
        saveSession()
    }
    
    /// Add an assistant message to the conversation
    func addAssistantMessage(_ content: String) {
        ensureActiveSession()
        let message = ChatMessage(role: .assistant, content: content)
        currentSession?.messages.append(message)
        currentSession?.lastUpdatedAt = Date()
        saveSession()
    }
    
    /// Add a system message (for context/instructions)
    func addSystemMessage(_ content: String) {
        ensureActiveSession()
        let message = ChatMessage(role: .system, content: content)
        currentSession?.messages.append(message)
        currentSession?.lastUpdatedAt = Date()
        saveSession()
    }
    
    // MARK: - Session Management
    
    /// Start a new conversation session
    func startNewSession() {
        currentSession = ConversationSession()
        saveSession()
    }
    
    /// Clear the current session
    func clearSession() {
        currentSession = nil
        UserDefaults.standard.removeObject(forKey: sessionStorageKey)
    }
    
    /// Ensure there is an active session, creating one if needed
    private func ensureActiveSession() {
        if currentSession == nil {
            startNewSession()
        }
    }
    
    // MARK: - Persistence
    
    /// Save the current session to UserDefaults
    func saveSession() {
        guard let session = currentSession else { return }
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(session)
            UserDefaults.standard.set(data, forKey: sessionStorageKey)
        } catch { }
    }
    
    /// Load a previous session from UserDefaults
    /// Returns true if a valid session was loaded
    @discardableResult
    func loadSession() -> Bool {
        guard let data = UserDefaults.standard.data(forKey: sessionStorageKey) else {
            return false
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let session = try decoder.decode(ConversationSession.self, from: data)
            
            // Check if session is expired
            if isSessionExpired(session) {
                clearSession()
                return false
            }
            
            currentSession = session
            return true
        } catch {
            clearSession()
            return false
        }
    }
    
    /// Check if a session has expired
    private func isSessionExpired(_ session: ConversationSession) -> Bool {
        let expiryDate = Calendar.current.date(
            byAdding: .hour,
            value: sessionExpiryHours,
            to: session.lastUpdatedAt
        ) ?? session.lastUpdatedAt
        
        return Date() > expiryDate
    }
    
    // MARK: - Export
    
    /// Export the conversation as plain text
    func exportAsText() -> String {
        guard let session = currentSession else {
            return "No conversation to export."
        }
        
        var text = "Warmnet Conversation\n"
        text += "Started: \(formatDate(session.startedAt))\n"
        text += "---\n\n"
        
        for message in session.messages {
            let role = message.role == .user ? "You" : "Assistant"
            let time = formatTime(message.timestamp)
            text += "[\(time)] \(role):\n\(message.content)\n\n"
        }
        
        return text
    }
    
    /// Export the conversation as markdown
    func exportAsMarkdown() -> String {
        guard let session = currentSession else {
            return "No conversation to export."
        }
        
        var text = "# Warmnet Conversation\n\n"
        text += "**Started:** \(formatDate(session.startedAt))\n\n"
        text += "---\n\n"
        
        for message in session.messages {
            switch message.role {
            case .user:
                text += "**You:** \(message.content)\n\n"
            case .assistant:
                text += "_Assistant:_ \(message.content)\n\n"
            case .system:
                continue // Skip system messages in export
            }
        }
        
        return text
    }
    
    // MARK: - Helpers
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // MARK: - Statistics
    
    /// Get conversation statistics
    func getStats() -> ConversationStats {
        guard let session = currentSession else {
            return ConversationStats(
                messageCount: 0,
                userMessageCount: 0,
                assistantMessageCount: 0,
                duration: 0,
                averageResponseLength: 0
            )
        }
        
        let userMessages = session.messages.filter { $0.role == .user }
        let assistantMessages = session.messages.filter { $0.role == .assistant }
        
        let totalAssistantLength = assistantMessages.reduce(0) { $0 + $1.content.count }
        let averageLength = assistantMessages.isEmpty ? 0 : totalAssistantLength / assistantMessages.count
        
        let duration = Date().timeIntervalSince(session.startedAt)
        
        return ConversationStats(
            messageCount: session.messages.count,
            userMessageCount: userMessages.count,
            assistantMessageCount: assistantMessages.count,
            duration: duration,
            averageResponseLength: averageLength
        )
    }
}

// MARK: - Conversation Stats

struct ConversationStats {
    let messageCount: Int
    let userMessageCount: Int
    let assistantMessageCount: Int
    let duration: TimeInterval
    let averageResponseLength: Int
    
    var formattedDuration: String {
        let minutes = Int(duration / 60)
        if minutes < 1 {
            return "Less than a minute"
        } else if minutes == 1 {
            return "1 minute"
        } else if minutes < 60 {
            return "\(minutes) minutes"
        } else {
            let hours = minutes / 60
            return "\(hours) hour\(hours == 1 ? "" : "s")"
        }
    }
}
