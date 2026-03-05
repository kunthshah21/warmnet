//
//  AIWritingAssistantView.swift
//  warmnet
//
//  Created on 7 February 2026.
//

import SwiftUI

/// AI-assisted writing component that appears after a word count threshold
/// Displays "Ask Brive" indicator and generates contextual writing prompts
struct AIWritingAssistantView: View {
    @Binding var text: String
    @State private var currentPrompt: String = ""
    @State private var wordCountThreshold: Int = 50
    @State private var hasShownPrompt: Bool = false
    
    @Environment(\.colorScheme) private var colorScheme
    
    // Pre-defined prompts for testing (will be replaced with LLM integration)
    private let samplePrompts = [
        "How did this interaction make you feel?",
        "What was the most memorable part of this conversation?",
        "Was there anything unexpected that came up?",
        "What follow-up actions do you want to take?",
        "How did this strengthen your relationship?",
        "What did you learn about them during this interaction?",
        "Were there any shared interests or connections discovered?",
        "What topics would you like to explore next time?"
    ]
    
    private var wordCount: Int {
        let words = text.split(separator: " ").filter { !$0.isEmpty }
        return words.count
    }
    
    private var shouldShowIndicator: Bool {
        wordCount >= wordCountThreshold && !hasShownPrompt
    }
    
    private var indicatorBackgroundColor: Color {
        colorScheme == .dark
            ? Color(red: 0.20, green: 0.20, blue: 0.20)
            : Color(red: 0.95, green: 0.95, blue: 0.97)
    }
    
    private var indicatorTextColor: Color {
        colorScheme == .dark
            ? Color(red: 0.60, green: 0.75, blue: 1.0)
            : Color(red: 0.19, green: 0.41, blue: 1)
    }
    
    private var dividerColor: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.15)
            : Color.black.opacity(0.1)
    }
    
    private var promptBackgroundColor: Color {
        colorScheme == .dark
            ? Color(red: 0.15, green: 0.15, blue: 0.15)
            : Color(red: 0.98, green: 0.98, blue: 0.99)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if shouldShowIndicator {
                askBriveIndicator
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
            
            if hasShownPrompt && !currentPrompt.isEmpty {
                promptSection
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: shouldShowIndicator)
        .animation(.easeInOut(duration: 0.3), value: hasShownPrompt)
    }
    
    // MARK: - Ask Brive Indicator
    
    private var askBriveIndicator: some View {
        Button {
            HapticManager.impact(.medium)
            generatePrompt()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(indicatorTextColor)
                
                Text("Ask Brive")
                    .font(.custom(AppFontName.workSansMedium, size: 13))
                    .foregroundColor(indicatorTextColor)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(indicatorBackgroundColor)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(.plain)
        .padding(.top, 12)
    }
    
    // MARK: - Prompt Section
    
    private var promptSection: some View {
        VStack(spacing: 16) {
            // Divider with spacing
            Rectangle()
                .fill(dividerColor)
                .frame(height: 1)
                .padding(.vertical, 16)
            
            // Prompt content
            HStack(alignment: .top, spacing: 12) {
                // Prompt text
                Text(currentPrompt)
                    .font(.custom(AppFontName.workSansRegular, size: 15))
                    .italic()
                    .fontWeight(.semibold)
                    .foregroundColor(.primary.opacity(0.85))
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Refresh button
                Button {
                    HapticManager.impact(.light)
                    regeneratePrompt()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary.opacity(0.6))
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(indicatorBackgroundColor)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(promptBackgroundColor)
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private func generatePrompt() {
        currentPrompt = samplePrompts.randomElement() ?? samplePrompts[0]
        hasShownPrompt = true
        wordCountThreshold = 75 // Increase threshold for next prompt
    }
    
    private func regeneratePrompt() {
        withAnimation(.easeInOut(duration: 0.2)) {
            // Filter out current prompt to avoid showing the same one
            let availablePrompts = samplePrompts.filter { $0 != currentPrompt }
            currentPrompt = availablePrompts.randomElement() ?? samplePrompts.randomElement() ?? samplePrompts[0]
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var text = "This is a sample note with more than fifty words to test the AI writing assistant feature. We want to make sure the indicator appears at the right time and the prompt generation works correctly. Let's add a bit more text to really test the word counting functionality."
        
        var body: some View {
            VStack(spacing: 20) {
                TextEditor(text: $text)
                    .frame(height: 150)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                AIWritingAssistantView(text: $text)
                
                Spacer()
            }
            .padding()
        }
    }
    
    return PreviewWrapper()
}
