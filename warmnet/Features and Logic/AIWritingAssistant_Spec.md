# AI Writing Assistant Feature Specification

## Overview
The AI Writing Assistant (nicknamed "Brive") provides intelligent writing prompts during diary/note entry to help users reflect more deeply on their interactions and relationships.

## Implementation Date
February 7, 2026

## Feature Components

### 1. AIWritingAssistantView.swift
**Location:** `warmnet/Views/AIWritingAssistantView.swift`

A reusable SwiftUI component that monitors text input and provides contextual writing prompts.

### 2. Integration Points
- **LogInteractionSheet.swift**: Integrated into the notes section when logging interactions with contacts
- **AddContactSheet.swift**: Integrated into the contact notes section

## User Flow

### Initial State
- User begins typing notes in any integrated text field
- Word count is monitored in real-time

### Trigger Condition
- When user reaches **50 words** or more
- A subtle "Ask Brive" indicator appears below the text input
- Visual design: Capsule-shaped bubble with sparkles icon and text

### Prompt Generation
1. User taps "Ask Brive" indicator
2. System displays a writing prompt below a light divider
3. Prompt appears with:
   - Italicized, semi-bold text for visual distinction
   - Light background container (adapts to dark/light mode)
   - Refresh button on the right side

### Subsequent Prompts
- After first prompt is shown, threshold increases to **75 words**
- Each subsequent prompt request requires 75 additional words
- Users can regenerate prompts using the refresh button

## Technical Details

### Word Counting Logic
```swift
private var wordCount: Int {
    let words = text.split(separator: " ").filter { !$0.isEmpty }
    return words.count
}
```

### Threshold Management
- Initial threshold: 50 words
- Post-first-prompt: 75 words
- Threshold increases only after user actively requests a prompt

### Sample Prompts (Phase 1)
Currently using pre-defined prompts for UI implementation:
1. "How did this interaction make you feel?"
2. "What was the most memorable part of this conversation?"
3. "Was there anything unexpected that came up?"
4. "What follow-up actions do you want to take?"
5. "How did this strengthen your relationship?"
6. "What did you learn about them during this interaction?"
7. "Were there any shared interests or connections discovered?"
8. "What topics would you like to explore next time?"

### Future Enhancement
Phase 2 will replace sample prompts with LLM-generated prompts based on:
- Current text content
- Contact relationship history
- Interaction patterns
- User's writing style and preferences

## Design System Integration

### Colors (Dark/Light Mode Adaptive)

**Indicator Bubble:**
- Dark mode: `Color(red: 0.20, green: 0.20, blue: 0.20)`
- Light mode: `Color(red: 0.95, green: 0.95, blue: 0.97)`

**Indicator Text:**
- Dark mode: `Color(red: 0.60, green: 0.75, blue: 1.0)` (soft blue)
- Light mode: `Color(red: 0.19, green: 0.41, blue: 1)` (primary blue)

**Prompt Background:**
- Dark mode: `Color(red: 0.15, green: 0.15, blue: 0.15)`
- Light mode: `Color(red: 0.98, green: 0.98, blue: 0.99)`

**Divider:**
- Dark mode: `Color.white.opacity(0.15)`
- Light mode: `Color.black.opacity(0.1)`

### Typography
- Indicator: WorkSans-Medium, 13pt
- Prompt text: WorkSans-Regular, 15pt, italic, semibold
- Icons: SF Symbols (sparkles, arrow.clockwise)

### Animations
- Fade + scale transition for indicator appearance
- Fade + move transition for prompt section
- Duration: 0.3s ease-in-out

## Edge Cases Handled

### Less than 50 words
- No indicator appears
- Feature remains invisible until threshold is met

### Empty text
- Word count correctly returns 0
- No indicator shown

### Repeated refresh
- Filters out current prompt to avoid showing the same one
- Falls back to any prompt if all have been shown

### Multiple integrations
- Component is stateful per instance
- Each text field maintains independent word count and threshold

## Architecture Compliance

### MV Architecture
- **Model**: Word counting logic, prompt selection
- **View**: SwiftUI components with proper state management

### SwiftUI Best Practices
- Uses `@Binding` for text synchronization
- Proper environment integration (`colorScheme`)
- Smooth animations with `.transition()` and `.animation()` modifiers
- Clean separation of concerns (subviews for indicator and prompt)

### Design System Adherence
- Uses `AppColors` and `AppFontName` constants
- Consistent with existing component styling (e.g., `AIInsightCard`)
- Proper dark/light mode support throughout

## Future Enhancements (Phase 2)

### LLM Integration
- [ ] Connect to AI service for dynamic prompt generation
- [ ] Analyze current note content for context
- [ ] Consider contact relationship metadata
- [ ] Personalize based on user writing patterns

### Advanced Features
- [ ] Prompt categories (reflection, planning, emotional, practical)
- [ ] User preference for prompt frequency
- [ ] Ability to dismiss/hide prompts
- [ ] Save favorite prompts
- [ ] Analytics on prompt effectiveness

### Memory System
- [ ] Track which prompts were most helpful
- [ ] Learn from user's response patterns
- [ ] Avoid repetitive prompt themes
- [ ] Adaptive threshold based on user behavior

## Testing Recommendations

### Manual Testing
1. Type less than 50 words - verify no indicator appears
2. Type exactly 50 words - verify indicator appears
3. Tap indicator - verify prompt displays correctly
4. Tap refresh - verify new prompt loads
5. Continue typing 75+ words - verify next indicator appears
6. Test in both light and dark mode
7. Test on different screen sizes

### Integration Testing
- Verify in LogInteractionSheet
- Verify in AddContactSheet
- Test with TextEditor and TextField components
- Ensure no performance impact on typing

## Performance Considerations
- Word counting is O(n) but runs on small text inputs
- State updates are minimal and localized
- Animations use efficient SwiftUI transitions
- No network calls in Phase 1 (all local)

## Accessibility
- All interactive elements use standard SwiftUI buttons
- Text sizing respects dynamic type
- Color contrast meets WCAG guidelines
- Icons paired with text labels for clarity
