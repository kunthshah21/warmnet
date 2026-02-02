//
//  AIChatScreen.swift
//  warmnet
//
//  Created for AI Insights feature.
//

import SwiftUI
import SwiftData

struct AIChatScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var aiGenerator: AIInsightGenerator?
    @State private var inputText = ""
    @State private var streamingResponse = ""
    @State private var showExportSheet = false
    @State private var exportedText = ""
    
    /// Initial insight type that triggered the chat (optional)
    let initialContext: InsightType?
    
    private var backgroundColor: Color {
        colorScheme == .dark
            ? AppColors.deepNavy
            : Color(red: 0xF1/255, green: 0xF2/255, blue: 0xF6/255)
    }
    
    private var messages: [ChatMessage] {
        aiGenerator?.conversationManager.messages ?? []
    }
    
    private var isStreaming: Bool {
        aiGenerator?.isStreaming ?? false
    }
    
    private var suggestions: [String] {
        [
            "Who should I reach out to today?",
            "How is my network health looking?",
            "Give me ideas for my next interaction",
            "What are my networking trends?"
        ]
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Messages area
                if messages.isEmpty && !isStreaming {
                    ChatEmptyStateView(
                        suggestions: suggestions,
                        onSuggestionTap: { suggestion in
                            inputText = suggestion
                            sendMessage()
                        }
                    )
                } else {
                    messagesScrollView
                }
                
                Divider()
                
                // Input bar
                ChatInputBar(
                    text: $inputText,
                    onSend: sendMessage,
                    isLoading: isStreaming
                )
            }
            .background(backgroundColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.custom(AppFontName.workSansMedium, size: 16))
                }
                
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text("Network Assistant")
                            .font(.custom(AppFontName.workSansMedium, size: 17))
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 6, height: 6)
                            
                            Text("On-device AI")
                                .font(.custom(AppFontName.workSansRegular, size: 11))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            exportConversation()
                        } label: {
                            Label("Export Conversation", systemImage: "square.and.arrow.up")
                        }
                        .disabled(messages.isEmpty)
                        
                        Button(role: .destructive) {
                            clearConversation()
                        } label: {
                            Label("Clear Conversation", systemImage: "trash")
                        }
                        .disabled(messages.isEmpty)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 20))
                    }
                }
            }
            .task {
                setupAI()
                await loadInitialContext()
            }
            .sheet(isPresented: $showExportSheet) {
                ShareSheet(items: [exportedText])
            }
        }
    }
    
    // MARK: - Messages Scroll View
    
    private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(messages) { message in
                        ChatBubble(message: message)
                            .id(message.id)
                    }
                    
                    // Streaming response
                    if isStreaming || !streamingResponse.isEmpty {
                        StreamingTextView(
                            text: streamingResponse,
                            isStreaming: isStreaming
                        )
                        .id("streaming")
                    }
                }
                .padding()
            }
            .scrollContentBackground(.visible)
            .onChange(of: messages.count) { _, _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: streamingResponse) { _, _ in
                scrollToBottom(proxy: proxy)
            }
        }
    }
    
    // MARK: - Actions
    
    private func setupAI() {
        let contextService = AIContextService(modelContext: modelContext)
        aiGenerator = AIInsightGenerator(contextService: contextService)
    }
    
    private func loadInitialContext() async {
        guard let context = initialContext, aiGenerator != nil else { return }
        
        // Add a welcome message based on context
        let welcomeMessage: String
        switch context {
        case .homeSummary:
            welcomeMessage = "I'm here to help with your networking! I can see your daily goals and network activity. What would you like to know?"
        case .networkAnalysis:
            welcomeMessage = "Let's dive deeper into your network! I can analyze your connections, trends, and suggest ways to strengthen relationships. What interests you?"
        case .interactionIdeas(_, let name):
            welcomeMessage = "I can help you connect with \(name)! Would you like some personalized interaction ideas?"
        case .networkOpportunity:
            welcomeMessage = "I've spotted some networking opportunities for you. Ask me about any specific contacts or relationships you'd like to strengthen."
        case .trendAnalysis:
            welcomeMessage = "I'm tracking your networking patterns. Ask me about your trends, or I can suggest ways to improve your consistency."
        case .contactDeepDive:
            welcomeMessage = "I can provide detailed insights about this contact and your relationship history. What would you like to know?"
        case .weeklyTrendInsight(timePeriod: let timePeriod):
            welcomeMessage = "Let's look at your \(timePeriod.rawValue.lowercased()) networking trends. I can summarize activity, highlight patterns, and suggest one action to improve. What would you like to explore?"
        }
        
        aiGenerator?.conversationManager.addAssistantMessage(welcomeMessage)
    }
    
    private func sendMessage() {
        let message = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty, let generator = aiGenerator else { return }
        
        inputText = ""
        streamingResponse = ""
        
        Task {
            do {
                _ = try await generator.streamChat(message: message) { chunk in
                    streamingResponse += chunk
                }
                streamingResponse = ""
            } catch {
                // Error is handled by the generator
                streamingResponse = ""
            }
        }
    }
    
    private func clearConversation() {
        aiGenerator?.clearConversation()
        streamingResponse = ""
    }
    
    private func exportConversation() {
        guard let manager = aiGenerator?.conversationManager else { return }
        exportedText = manager.exportAsText()
        showExportSheet = true
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.2)) {
            if isStreaming || !streamingResponse.isEmpty {
                proxy.scrollTo("streaming", anchor: .bottom)
            } else if let lastMessage = messages.last {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, PersonalisationData.self, Interaction.self, configurations: config)
    
    return AIChatScreen(initialContext: .homeSummary)
        .modelContainer(container)
}
