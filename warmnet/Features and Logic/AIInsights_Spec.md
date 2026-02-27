# AI Insights System Architecture

## Overview

The AI Insights system provides personalized, context-aware networking recommendations using Apple's on-device Foundation Models framework (iOS 26+). The system analyzes user data from SwiftData to generate dynamic insights, supports conversational interactions, and maintains chat memory across sessions.

## Core Components

### 1. AIContextSnapshot
Location: `Models/AI/AIContextSnapshot.swift`

Defines all data structures used to pass context to the AI:

- **AIContextSnapshot**: Complete context for detailed insights
- **QuickInsightContext**: Lightweight context for home screen
- **ContactDetailContext**: Deep dive context for specific contacts
- **InsightType**: Enum defining available insight types

Key structures:
- `NetworkOverview`: Contact counts by tier, overdue status
- `ActivityTrends`: Interaction frequency, weekly trends
- `TodaysStatus`: Daily goals, completion status
- `UserProfileContext`: Personalization data
- `UpcomingEvents`: Birthdays, milestones

### 2. AIContextService
Location: `Models/AI/AIContextService.swift`

Aggregates data from SwiftData into context snapshots:

```swift
@Observable
class AIContextService {
    // Full context for insights and chat
    func buildContextSnapshot() async -> AIContextSnapshot
    
    // Lightweight context for home screen
    func getQuickInsightContext() -> QuickInsightContext
    
    // Contact-specific context
    func getContactContext(for contact: Contact) -> ContactDetailContext
}
```

**Data Sources:**
- `Contact` model (with priority, location, schedule)
- `Interaction` model (type, date, notes)
- `Milestone` model (upcoming events)
- `PersonalisationData` model (user preferences)
- `UserSettings` model (app configuration)
- `NetworkProgressService` (tier progress calculations)

### 3. AIPromptBuilder
Location: `Models/AI/AIPromptBuilder.swift`

Constructs prompts for Foundation Models:

```swift
struct AIPromptBuilder {
    // System prompt with full context
    static func buildSystemPrompt(context: AIContextSnapshot) -> String
    
    // User prompt for specific insight types
    static func buildUserPrompt(for type: InsightType, context: AIContextSnapshot) -> String
    
    // Chat prompt with conversation history
    static func buildChatPrompt(
        userMessage: String,
        context: AIContextSnapshot,
        history: [ChatMessage]
    ) -> String
}
```

**Insight Types:**
- `.homeSummary`: Daily status overview
- `.networkAnalysis`: Deep network analysis
- `.interactionIdeas`: Contact-specific suggestions
- `.networkOpportunity`: Opportunity identification
- `.trendAnalysis`: Activity trend analysis
- `.contactDeepDive`: Individual relationship insights

### 4. AIInsightGenerator
Location: `Models/AI/AIInsightGenerator.swift`

Core integration with Apple Foundation Models:

```swift
@Observable
class AIInsightGenerator {
    // Generate insight for cards
    func generateInsight(type: InsightType) async throws -> String
    
    // Quick insight for home screen
    func generateQuickInsight() async throws -> String
    
    // Chat with streaming support
    func chat(message: String) async throws -> String
    func streamChat(message: String, onChunk: @escaping (String) -> Void) async throws -> String
}
```

**Features:**
- Loading state management (`isGeneratingInsight`, `isStreaming`)
- Error handling with `AIError` enum
- Fallback responses for pre-iOS 26 devices
- Streaming text buffer for real-time display

### 5. AIConversationManager
Location: `Models/AI/AIConversationManager.swift`

Manages chat sessions and memory:

```swift
@Observable
class AIConversationManager {
    // Message management
    func addUserMessage(_ content: String)
    func addAssistantMessage(_ content: String)
    
    // Session management
    func startNewSession()
    func clearSession()
    func saveSession()
    func loadSession() -> Bool
    
    // Export
    func exportAsText() -> String
    func exportAsMarkdown() -> String
}
```

**Memory Strategy:**
- In-memory storage during session
- Persistence to UserDefaults (not SwiftData)
- Maximum 20 messages in context window
- 24-hour session expiry
- Session statistics tracking

## Data Flow

### Home Screen Insight Generation

```
┌──────────────────────────────────────────────────────────────────┐
│                        HomeScreen                                 │
│                             │                                     │
│                             ▼                                     │
│                    AIInsightCard(.homeSummary)                   │
│                             │                                     │
│                             ▼                                     │
│                    AIInsightGenerator                             │
│                       │         │                                 │
│                       ▼         ▼                                 │
│           AIContextService    AIPromptBuilder                     │
│                  │                   │                            │
│                  ▼                   ▼                            │
│           SwiftData Query    Build System Prompt                  │
│                  │                   │                            │
│                  └───────┬───────────┘                            │
│                          ▼                                        │
│                 Foundation Models (on-device)                     │
│                          │                                        │
│                          ▼                                        │
│                  Generated Insight Text                           │
│                          │                                        │
│                          ▼                                        │
│                 Display in AIInsightCard                          │
└──────────────────────────────────────────────────────────────────┘
```

### Chat Conversation Flow

```
┌──────────────────────────────────────────────────────────────────┐
│                       AIChatScreen                                │
│                             │                                     │
│              User types message in ChatInputBar                   │
│                             │                                     │
│                             ▼                                     │
│            AIConversationManager.addUserMessage()                 │
│                             │                                     │
│                             ▼                                     │
│            AIInsightGenerator.streamChat()                        │
│                  │                   │                            │
│                  ▼                   ▼                            │
│      AIContextService        AIPromptBuilder                      │
│      buildContextSnapshot()  buildChatPrompt()                    │
│                  │                   │                            │
│                  └───────┬───────────┘                            │
│                          ▼                                        │
│              Foundation Models (streaming)                        │
│                          │                                        │
│              ┌───────────┼───────────┐                            │
│              ▼           ▼           ▼                            │
│           Chunk 1    Chunk 2    Chunk N                           │
│              │           │           │                            │
│              └───────────┼───────────┘                            │
│                          ▼                                        │
│            StreamingTextView updates in real-time                 │
│                          │                                        │
│                          ▼                                        │
│         AIConversationManager.addAssistantMessage()               │
└──────────────────────────────────────────────────────────────────┘
```

## File Structure

```
warmnet/
├── Models/
│   └── AI/                                    # Central AI folder
│       ├── AIContextSnapshot.swift            # Data structures & InsightType enum
│       ├── AIContextService.swift             # Data aggregation
│       ├── AIInsightGenerator.swift           # Foundation Models integration
│       ├── AIConversationManager.swift        # Chat memory
│       ├── AIPromptBuilder.swift              # Prompt construction
│       └── WeeklyTrendInsightService.swift    # NEW: Trend-specific insights
├── Views/
│   ├── AIInsightCard.swift                    # Insight display card
│   ├── AIChatView.swift                       # Chat UI components
│   ├── WeeklyTrendCard.swift                  # Trend card with sheet trigger
│   ├── WeeklyTrendDetailSheet.swift           # NEW: Detailed trend view
│   └── WeeklyTrendAIInsightView.swift         # NEW: AI insight component
├── Screens/
│   ├── HomeScreen.swift                       # Uses AIInsightCard
│   ├── InsightsScreen.swift                   # Uses AIInsightCard
│   └── AIChatScreen.swift                     # Full chat interface
└── Features and Logic/
    └── AIInsights_Spec.md                     # This documentation
```

## Weekly Trend Insights Feature

### Architecture Overview (MV Pattern)

The Weekly Trend Insights feature follows the **Model-View (MV) Architecture** pattern used throughout the warmnet application:

- **Model Layer**: Data structures (`TrendAnalysisContext`, `TrendDayInfo`, `TrendTimePeriod`) and services (`WeeklyTrendInsightService`)
- **View Layer**: UI components (`WeeklyTrendCard`, `WeeklyTrendDetailSheet`, `WeeklyTrendAIInsightView`)

This architecture separates concerns by keeping business logic and data handling in the Model layer while the View layer focuses purely on presentation.

### Components

#### 1. WeeklyTrendInsightService
Location: `Models/AI/WeeklyTrendInsightService.swift`

Dedicated service for generating AI insights specifically for weekly trend analysis:

```swift
@Observable
class WeeklyTrendInsightService {
    // Generate insight based on time period and current trend data
    func generateTrendInsight(
        for period: TrendTimePeriod,
        trendData: [TrendDayInfo]
    ) async throws -> String
    
    // Build specialized prompt with trend-specific context
    func buildTrendContext(
        data: [TrendDayInfo],
        period: TrendTimePeriod
    ) -> TrendAnalysisContext
}
```

**Features:**
- Builds `TrendAnalysisContext` from raw interaction data
- Calculates metrics: total connections, daily average, best/worst days
- Determines trend direction and percentage change
- Leverages existing AI infrastructure for insight generation

#### 2. TrendTimePeriod Enum
Location: `Models/AI/AIContextSnapshot.swift`

```swift
enum TrendTimePeriod: String, CaseIterable, Codable {
    case daily = "Daily"    // Last 7 days
    case weekly = "Weekly"  // Last 4 weeks (28 days)
}
```

#### 3. TrendAnalysisContext
Location: `Models/AI/AIContextSnapshot.swift`

Context structure passed to AI for trend analysis:

```swift
struct TrendAnalysisContext: Codable {
    let timePeriod: TrendTimePeriod
    let totalConnections: Int
    let averagePerDay: Double
    let bestDay: TrendDayInfo?
    let worstDay: TrendDayInfo?
    let trendDirection: TrendDirection
    let percentageChange: Double
    let dailyBreakdown: [TrendDayInfo]
}
```

#### 4. UI Components

**WeeklyTrendDetailSheet** (`Views/Insights/WeeklyTrendDetailSheet.swift`):
- Time period filter (segmented control)
- Enhanced bar chart visualization
- Statistics cards (Total, Avg/Day, Best Day)
- AI Insights section

**WeeklyTrendAIInsightView** (`Views/AI/WeeklyTrendAIInsightView.swift`):
- Loading shimmer animation
- Error state with retry
- Refresh button for regenerating insights

### Data Flow Diagram

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                         Weekly Trend Insights Flow                            │
│                                                                               │
│  ┌─────────────────┐                                                          │
│  │ WeeklyTrendCard │ (Overview Section)                                       │
│  │                 │                                                          │
│  │  [User Taps]    │                                                          │
│  └────────┬────────┘                                                          │
│           │                                                                   │
│           ▼                                                                   │
│  ┌─────────────────────────────────────────────────────────────────┐          │
│  │              WeeklyTrendDetailSheet (Sheet Modal)                │          │
│  │                                                                  │          │
│  │  ┌──────────────────────┐                                        │          │
│  │  │ Time Period Filter   │ ◄─── User selects Daily/Weekly         │          │
│  │  │ [Daily] [Weekly]     │                                        │          │
│  │  └──────────┬───────────┘                                        │          │
│  │             │                                                    │          │
│  │             ▼                                                    │          │
│  │  ┌──────────────────────┐                                        │          │
│  │  │   Enhanced Chart     │ ◄─── Filters data by selected period   │          │
│  │  │   + Statistics       │                                        │          │
│  │  └──────────────────────┘                                        │          │
│  │             │                                                    │          │
│  │             ▼                                                    │          │
│  │  ┌──────────────────────────────────────────────────────────┐    │          │
│  │  │           WeeklyTrendAIInsightView                        │    │          │
│  │  │                       │                                   │    │          │
│  │  │                       ▼                                   │    │          │
│  │  │           WeeklyTrendInsightService                       │    │          │
│  │  │                │              │                           │    │          │
│  │  │                ▼              ▼                           │    │          │
│  │  │    buildTrendContext()  AIContextService                  │    │          │
│  │  │                │              │                           │    │          │
│  │  │                └──────┬───────┘                           │    │          │
│  │  │                       ▼                                   │    │          │
│  │  │              AIPromptBuilder                              │    │          │
│  │  │    buildWeeklyTrendInsightPrompt()                        │    │          │
│  │  │                       │                                   │    │          │
│  │  │                       ▼                                   │    │          │
│  │  │         Foundation Models (iOS 26+)                       │    │          │
│  │  │              or Fallback                                  │    │          │
│  │  │                       │                                   │    │          │
│  │  │                       ▼                                   │    │          │
│  │  │            AI Insight Text                                │    │          │
│  │  │     "Your networking activity has been..."                │    │          │
│  │  └──────────────────────────────────────────────────────────┘    │          │
│  └──────────────────────────────────────────────────────────────────┘          │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Prompt Engineering for Trends

The `buildWeeklyTrendInsightPrompt()` method constructs prompts that:

1. **Provide trend data context**:
   - Total connections in the period
   - Average connections per day
   - Best and worst performing days
   - Trend direction (increasing/decreasing/stable)
   - Percentage change

2. **Include network context**:
   - Total contacts in network
   - Overdue contact count
   - Recent interaction counts

3. **Request actionable insights**:
   - Explain what the trend reveals
   - Identify strengths or areas for improvement
   - Suggest one specific action

### InsightType Extension

The `InsightType` enum now includes:

```swift
case weeklyTrendInsight(timePeriod: TrendTimePeriod)
```

This type is handled by `WeeklyTrendInsightService` directly using `buildWeeklyTrendInsightPrompt()` for specialized trend analysis.

## Context Sources

The AI has access to the following data:

| Data Source | Information | Use Case |
|-------------|-------------|----------|
| Contact | Name, tier, location, company, schedule | Personalized recommendations |
| Interaction | Type, date, notes, contact link | Activity analysis, trends |
| Milestone | Title, date, contact link | Event-aware suggestions |
| PersonalisationData | Goals, style, challenges | Tailored communication |
| UserSettings | Queue size, preferences | App context |
| NetworkProgressService | Tier coverage stats | Health scoring |
| DailyQueueGenerator | Overdue contacts, priority | Goal identification |
| WeeklyTrendInsightService | Trend analysis, daily breakdown | Weekly trend AI insights |

## Conversation Memory

### Storage Strategy

- **In-memory**: Active session messages
- **UserDefaults**: Session persistence for resumption
- **NOT SwiftData**: Conversations are ephemeral, not core data

### Session Lifecycle

1. **Start**: New session created on first message or app launch
2. **Active**: Messages added with timestamps
3. **Persist**: Auto-save after each message
4. **Resume**: Load on AIChatScreen appear
5. **Expire**: Clear after 24 hours of inactivity
6. **Clear**: User can manually clear via menu

### Context Window Management

- Maximum 20 messages retained for AI context
- Older messages preserved for export but not sent to model
- System prompt rebuilt fresh for each request

## Prompt Engineering

### System Prompt Structure

```
1. Role definition
2. User profile (name, goals, style, challenges)
3. Network overview (counts by tier, overdue)
4. Today's status (goals, completed, remaining)
5. Recent activity (interactions, trends)
6. Upcoming events (birthdays, milestones)
7. Tier progress (coverage percentages)
8. Response guidelines
```

### Response Guidelines (Embedded in Prompt)

- Be concise and encouraging
- Focus on actionable advice
- Personalize based on communication style
- Acknowledge achievements
- Keep summaries to 2-3 sentences
- Avoid bullet points unless helpful

## Edge Cases

| Scenario | Behavior |
|----------|----------|
| No contacts in database | Generic welcome message, suggest adding contacts |
| All goals completed | Celebration message, suggest proactive outreach |
| iOS < 26 | Fallback to contextual pre-written responses |
| Foundation Models unavailable | Fallback responses, no error shown to user |
| Network generation fails | Retry button displayed, error logged |
| Session expired | New session created silently |
| Empty conversation | Show suggestions in empty state |

## Privacy Considerations

- **On-device processing**: All AI inference runs locally
- **No cloud calls**: Foundation Models do not send data externally
- **No conversation storage**: Chat history in UserDefaults, not synced
- **User control**: Clear conversation option always available
- **Export option**: User can export conversations locally

## Testing Considerations

### Unit Tests
- `AIContextService`: Verify snapshot construction from mock data
- `AIPromptBuilder`: Validate prompt structure and content
- `AIConversationManager`: Test session persistence and limits
- `WeeklyTrendInsightService`: Test trend context building and metrics calculation
- `TrendAnalysisContext`: Verify percentage change and direction calculations

### Integration Tests
- Full insight generation flow with sample data
- Chat streaming with mock responses
- Session resumption after app restart
- Weekly trend insight generation with varying data patterns
- Time period filter state persistence

### UI Tests
- Loading states in AIInsightCard
- Chat scroll behavior with streaming
- Empty state and suggestions
- Error retry flow
- WeeklyTrendDetailSheet time period filter toggle
- WeeklyTrendAIInsightView loading shimmer and refresh
- Bar chart scaling with different data ranges

## Implementation Status

### Completed
- [x] AIContextSnapshot data structures
- [x] AIContextService data aggregation
- [x] AIPromptBuilder prompt construction
- [x] AIInsightGenerator with fallback support
- [x] AIConversationManager with persistence
- [x] AIInsightCard UI updates
- [x] AIChatView components
- [x] AIChatScreen full interface
- [x] HomeScreen integration
- [x] InsightsScreen integration
- [x] WeeklyTrendInsightService for trend analysis
- [x] WeeklyTrendDetailSheet with time period filters
- [x] WeeklyTrendAIInsightView component
- [x] TrendTimePeriod and TrendAnalysisContext data structures
- [x] buildWeeklyTrendInsightPrompt() prompt builder

### Future Enhancements
- [ ] Foundation Models API integration (when SDK available)
- [ ] Custom adapter training for networking domain
- [ ] Voice input support
- [ ] Contact-specific chat deep links
- [ ] Insight caching with invalidation
- [ ] Analytics on insight engagement
- [ ] Weekly trend notification with AI summary
- [ ] Export trend data as report