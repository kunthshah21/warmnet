//
//  AIChatView.swift
//  warmnet
//
//  Created for AI Insights feature.
//

import SwiftUI

// MARK: - Chat Bubble

/// A single chat message bubble
struct ChatBubble: View {
    let message: ChatMessage
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var isUser: Bool {
        message.role == .user
    }
    
    private var bubbleColor: Color {
        if isUser {
            return AppColors.mutedBlue
        } else {
            return colorScheme == .dark
                ? Color(white: 0.2)
                : Color(white: 0.93)
        }
    }
    
    private var textColor: Color {
        if isUser {
            return .white
        } else {
            return colorScheme == .dark ? .white : .black
        }
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.custom(AppFontName.workSansRegular, size: 15))
                    .foregroundColor(textColor)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(bubbleColor)
                    .cornerRadius(18)
                    .cornerRadius(isUser ? 18 : 4, corners: isUser ? [.bottomRight] : [.bottomLeft])
                
                Text(formatTime(message.timestamp))
                    .font(.custom(AppFontName.workSansRegular, size: 11))
                    .foregroundColor(.secondary)
            }
            
            if !isUser {
                Spacer(minLength: 60)
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Streaming Text View

/// Displays streaming text with a typing indicator
struct StreamingTextView: View {
    let text: String
    let isStreaming: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var bubbleColor: Color {
        colorScheme == .dark
            ? Color(white: 0.2)
            : Color(white: 0.93)
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .bottom, spacing: 4) {
                    Text(text.isEmpty ? " " : text)
                        .font(.custom(AppFontName.workSansRegular, size: 15))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    if isStreaming {
                        TypingIndicator()
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(bubbleColor)
                .cornerRadius(18)
                .cornerRadius(4, corners: [.bottomLeft])
            }
            
            Spacer(minLength: 60)
        }
    }
}

// MARK: - Typing Indicator

/// Animated typing indicator dots
struct TypingIndicator: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.secondary)
                    .frame(width: 6, height: 6)
                    .offset(y: animationOffset(for: index))
            }
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 0.6)
                .repeatForever(autoreverses: true)
            ) {
                animationOffset = -4
            }
        }
    }
    
    private func animationOffset(for index: Int) -> CGFloat {
        let delay = Double(index) * 0.15
        return animationOffset * cos(delay * .pi)
    }
}

// MARK: - Chat Input Bar

/// Input bar for composing messages
struct ChatInputBar: View {
    @Binding var text: String
    let onSend: () -> Void
    let isLoading: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isFocused: Bool
    
    private var backgroundColor: Color {
        colorScheme == .dark
            ? Color(white: 0.15)
            : Color(white: 0.95)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("Ask about your network...", text: $text, axis: .vertical)
                .font(.custom(AppFontName.workSansRegular, size: 16))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(backgroundColor)
                .cornerRadius(20)
                .lineLimit(1...5)
                .focused($isFocused)
            
            Button(action: {
                if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading {
                    onSend()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(canSend ? AppColors.mutedBlue : Color.gray.opacity(0.3))
                        .frame(width: 36, height: 36)
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.7)
                    } else {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            .disabled(!canSend || isLoading)
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            colorScheme == .dark
                ? Color(white: 0.1)
                : Color.white
        )
    }
    
    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Empty State View

/// Shown when there are no messages yet
struct ChatEmptyStateView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let suggestions: [String]
    let onSuggestionTap: (String) -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 48))
                .foregroundColor(AppColors.mutedBlue.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("Network Assistant")
                    .font(.custom(AppFontName.workSansMedium, size: 20))
                    .foregroundColor(.primary)
                
                Text("Ask me anything about your network")
                    .font(.custom(AppFontName.workSansRegular, size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                Text("Try asking:")
                    .font(.custom(AppFontName.workSansRegular, size: 13))
                    .foregroundColor(.secondary)
                
                ForEach(suggestions, id: \.self) { suggestion in
                    Button {
                        onSuggestionTap(suggestion)
                    } label: {
                        Text(suggestion)
                            .font(.custom(AppFontName.workSansRegular, size: 14))
                            .foregroundColor(AppColors.mutedBlue)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                colorScheme == .dark
                                    ? Color(white: 0.15)
                                    : Color(white: 0.95)
                            )
                            .cornerRadius(20)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Spacer()
            Spacer()
        }
        .padding()
    }
}

// MARK: - Chat Header

/// Header for the chat screen
struct ChatHeaderView: View {
    let onClear: () -> Void
    let onExport: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Network Assistant")
                    .font(.custom(AppFontName.workSansMedium, size: 17))
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    
                    Text("On-device AI")
                        .font(.custom(AppFontName.workSansRegular, size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Menu {
                Button(action: onExport) {
                    Label("Export Conversation", systemImage: "square.and.arrow.up")
                }
                
                Button(role: .destructive, action: onClear) {
                    Label("Clear Conversation", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 22))
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(
            colorScheme == .dark
                ? Color(white: 0.1)
                : Color.white
        )
    }
}

// MARK: - Corner Radius Extension

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Shimmer Effect

/// Loading shimmer effect for AI insight cards
struct ShimmerView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ShimmerLine(width: 1.0)
            ShimmerLine(width: 0.9)
            ShimmerLine(width: 0.7)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct ShimmerLine: View {
    let width: CGFloat
    @State private var isAnimating = false
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var baseColor: Color {
        colorScheme == .dark
            ? Color(white: 0.2)
            : Color(white: 0.9)
    }
    
    private var shimmerColor: Color {
        colorScheme == .dark
            ? Color(white: 0.3)
            : Color(white: 0.95)
    }
    
    var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: 4)
                .fill(baseColor)
                .frame(width: geometry.size.width * width, height: 14)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    shimmerColor,
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: isAnimating ? geometry.size.width : -geometry.size.width)
                )
                .clipped()
        }
        .frame(height: 14)
        .onAppear {
            withAnimation(
                .linear(duration: 1.5)
                .repeatForever(autoreverses: false)
            ) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Previews

#Preview("Chat Bubble - User") {
    ChatBubble(
        message: ChatMessage(
            role: .user,
            content: "Who should I reach out to today?"
        )
    )
    .padding()
}

#Preview("Chat Bubble - Assistant") {
    ChatBubble(
        message: ChatMessage(
            role: .assistant,
            content: "Based on your network, I'd suggest reaching out to Sarah Johnson from your Inner Circle. You haven't connected in 12 days."
        )
    )
    .padding()
}

#Preview("Streaming Text") {
    StreamingTextView(
        text: "Let me check your network data...",
        isStreaming: true
    )
    .padding()
}

#Preview("Chat Input Bar") {
    ChatInputBar(
        text: .constant("Hello"),
        onSend: {},
        isLoading: false
    )
}

#Preview("Empty State") {
    ChatEmptyStateView(
        suggestions: [
            "Who should I contact today?",
            "How is my network health?",
            "Give me interaction ideas"
        ],
        onSuggestionTap: { _ in }
    )
}

#Preview("Shimmer") {
    ShimmerView()
        .padding()
}
