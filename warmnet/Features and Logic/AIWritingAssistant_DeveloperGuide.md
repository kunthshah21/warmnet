# AI Writing Assistant - Developer Usage Guide

## Quick Start

### Basic Integration

To integrate the AI Writing Assistant into any text input view:

```swift
import SwiftUI

struct MyView: View {
    @State private var notes: String = ""
    
    var body: some View {
        VStack {
            // Your text input
            TextField("Enter notes...", text: $notes, axis: .vertical)
                .lineLimit(4...8)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // Add AI Writing Assistant
            AIWritingAssistantView(text: $notes)
        }
    }
}
```

That's it! The component handles everything else automatically.

## Component API

### Required Parameters

```swift
AIWritingAssistantView(text: Binding<String>)
```

- `text`: A binding to the text being monitored
  - Type: `@Binding var text: String`
  - The component will monitor word count and display prompts accordingly

### No Optional Parameters
The component is fully self-contained with sensible defaults.

## How It Works

### 1. Automatic Word Counting
The component monitors the bound text and counts words in real-time:

```swift
private var wordCount: Int {
    let words = text.split(separator: " ").filter { !$0.isEmpty }
    return words.count
}
```

### 2. Threshold Management
- Initial threshold: 50 words
- After first prompt shown: 75 words
- Threshold persists for the lifetime of the component

### 3. State Management
Internal state variables:
- `currentPrompt`: Currently displayed prompt
- `wordCountThreshold`: Dynamic threshold (50 or 75)
- `hasShownPrompt`: Whether a prompt has been displayed

## Customization Options (Future)

The component is designed for future extensibility. Potential customization points:

```swift
// Future API (not yet implemented)
AIWritingAssistantView(
    text: $notes,
    initialThreshold: 50,           // Custom initial threshold
    subsequentThreshold: 75,        // Custom subsequent threshold
    promptProvider: customProvider, // Custom prompt generation
    theme: .custom(colors)          // Custom color scheme
)
```

## Integration Examples

### Example 1: TextField (Multi-line)
```swift
VStack(alignment: .leading, spacing: 12) {
    Text("Notes")
        .font(.headline)
    
    TextField("Add details...", text: $notes, axis: .vertical)
        .lineLimit(4...8)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    
    AIWritingAssistantView(text: $notes)
}
.padding()
```

### Example 2: TextEditor
```swift
VStack(alignment: .leading, spacing: 0) {
    ZStack(alignment: .topLeading) {
        if text.isEmpty {
            Text("Placeholder")
                .foregroundStyle(.secondary)
                .padding(.top, 8)
                .padding(.leading, 4)
        }
        TextEditor(text: $text)
            .frame(minHeight: 100)
    }
    
    AIWritingAssistantView(text: $text)
        .padding(.horizontal, -16) // Adjust for Form padding
}
```

### Example 3: Custom Styled Input
```swift
VStack {
    // Custom styled input
    ZStack(alignment: .topLeading) {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(.systemBackground))
            .shadow(radius: 5)
        
        TextEditor(text: $journalEntry)
            .padding()
    }
    .frame(height: 200)
    
    AIWritingAssistantView(text: $journalEntry)
}
.padding()
```

## Sample Prompts Reference

The component currently uses 8 pre-defined prompts:

1. **Emotional Reflection**
   - "How did this interaction make you feel?"

2. **Memory Capture**
   - "What was the most memorable part of this conversation?"

3. **Surprise Discovery**
   - "Was there anything unexpected that came up?"

4. **Action Planning**
   - "What follow-up actions do you want to take?"

5. **Relationship Building**
   - "How did this strengthen your relationship?"

6. **Learning**
   - "What did you learn about them during this interaction?"

7. **Connection Discovery**
   - "Were there any shared interests or connections discovered?"

8. **Future Planning**
   - "What topics would you like to explore next time?"

## Common Patterns

### Pattern 1: Form Integration
```swift
Form {
    Section("Details") {
        TextField("Name", text: $name)
        TextField("Email", text: $email)
    }
    
    Section("Notes") {
        VStack(alignment: .leading, spacing: 0) {
            TextEditor(text: $notes)
                .frame(minHeight: 100)
            
            AIWritingAssistantView(text: $notes)
                .padding(.horizontal, -16) // Compensate for Form padding
        }
    }
}
```

### Pattern 2: Scrollable View
```swift
ScrollView {
    VStack(spacing: 20) {
        // Other content
        
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Thoughts")
                .font(.headline)
            
            TextField("Write here...", text: $thoughts, axis: .vertical)
                .lineLimit(4...10)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            AIWritingAssistantView(text: $thoughts)
        }
        .padding()
    }
}
.scrollDismissesKeyboard(.interactively)
```

### Pattern 3: Sheet/Modal
```swift
NavigationStack {
    VStack(spacing: 20) {
        TextField("Notes", text: $notes, axis: .vertical)
            .lineLimit(5...10)
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        
        AIWritingAssistantView(text: $notes)
        
        Spacer()
        
        Button("Save") {
            // Save action
        }
        .buttonStyle(.borderedProminent)
    }
    .padding()
    .navigationTitle("Add Note")
    .navigationBarTitleDisplayMode(.inline)
}
```

## Troubleshooting

### Issue: Indicator Not Appearing

**Problem**: "Ask Brive" indicator doesn't show after 50 words

**Solution**: Check that:
1. Text is properly bound with `$` prefix
2. Word count includes actual words (spaces count as separators)
3. Component is visible in view hierarchy

**Debug**: Add temporary logging
```swift
.onChange(of: text) { _, newValue in
    print("Word count:", newValue.split(separator: " ").count)
}
```

### Issue: Indicator in Wrong Position

**Problem**: Indicator overlaps with other elements

**Solution**: Adjust spacing in parent container
```swift
VStack(alignment: .leading, spacing: 12) { // Explicit spacing
    TextField(...)
    AIWritingAssistantView(text: $notes)
}
```

### Issue: Prompt Not Refreshing

**Problem**: Refresh button doesn't change prompt

**Solution**: This should work automatically. If not:
- Ensure you're tapping the refresh button (↻)
- Check that prompts array is properly populated
- Verify button action is connected

### Issue: Form Padding Issues

**Problem**: Component doesn't align properly in Form

**Solution**: Use negative horizontal padding
```swift
AIWritingAssistantView(text: $notes)
    .padding(.horizontal, -16) // Compensate for Form's automatic padding
```

## Performance Considerations

### Word Counting Performance
- **Complexity**: O(n) where n is text length
- **Impact**: Negligible for typical diary entries (< 1000 words)
- **Optimization**: Already uses efficient `split(separator:)` method

### Memory Usage
- **State**: Minimal (one string, two integers, one boolean)
- **Overhead**: ~100 bytes per instance
- **Concern**: None, even with multiple instances

### Animation Performance
- **Transitions**: Hardware-accelerated SwiftUI animations
- **Frame Rate**: 60 FPS on modern devices
- **Battery Impact**: Negligible

## Best Practices

### ✅ Do:
- Use with multi-line text inputs (TextField with `.vertical` axis or TextEditor)
- Place directly below the text input for visual continuity
- Allow adequate vertical spacing for prompt display
- Test in both light and dark modes

### ❌ Don't:
- Use with single-line text fields (defeats the purpose)
- Hide or constrain the component's height
- Manually manage threshold or prompt state
- Override the component's animations

## Testing Your Integration

### Manual Test Checklist

1. **Word Count Threshold**
   - [ ] Type 49 words → no indicator
   - [ ] Type 50 words → indicator appears
   - [ ] Type 51 words → indicator still visible

2. **Prompt Display**
   - [ ] Tap "Ask Brive" → prompt appears
   - [ ] Divider is visible and properly styled
   - [ ] Prompt text is readable and properly formatted

3. **Refresh Functionality**
   - [ ] Tap refresh button → prompt changes
   - [ ] Tap again → different prompt appears
   - [ ] Prompts don't repeat immediately

4. **Subsequent Thresholds**
   - [ ] After showing prompt, type 74 more words → no new indicator
   - [ ] Type 75 more words → indicator reappears
   - [ ] Tap indicator → second prompt appears

5. **Visual Testing**
   - [ ] Test in light mode → proper contrast
   - [ ] Test in dark mode → proper contrast
   - [ ] Test on iPhone SE → proper layout
   - [ ] Test on iPhone 15 Pro Max → proper layout
   - [ ] Test on iPad → proper layout

6. **Edge Cases**
   - [ ] Clear all text → indicator disappears
   - [ ] Paste 100 words at once → indicator appears
   - [ ] Delete text below threshold → indicator disappears

## Examples in Codebase

### LogInteractionSheet.swift
```swift
// Lines 168-183
VStack(alignment: .leading, spacing: 12) {
    Text("Notes (optional)")
        .font(.headline)
        .foregroundStyle(.secondary)
    
    TextField("Add details about the interaction...", text: $notes, axis: .vertical)
        .lineLimit(4...8)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    
    // AI Writing Assistant
    AIWritingAssistantView(text: $notes)
}
.padding(.horizontal)
```

### AddContactSheet.swift
```swift
// Lines 297-313
Section {
    VStack(alignment: .leading, spacing: 0) {
        ZStack(alignment: .topLeading) {
            if notes.isEmpty {
                Text("Notes")
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
                    .padding(.leading, 4)
            }
            TextEditor(text: $notes)
                .frame(minHeight: 100)
        }
        
        // AI Writing Assistant
        AIWritingAssistantView(text: $notes)
            .padding(.horizontal, -16)
    }
}
```

## Future Enhancements

When LLM integration is added, the usage will remain the same, but you'll be able to configure it:

```swift
// Future API concept
AIWritingAssistantView(text: $notes)
    .promptProvider(.llm(model: .gpt4))
    .contextMemory(contactHistory)
    .personalizedFor(user)
```

The component is designed to maintain backward compatibility, so existing integrations will automatically benefit from LLM improvements without code changes.

## Support & Questions

For issues or questions about the AI Writing Assistant:

1. Check this documentation first
2. Review the specification: `AIWritingAssistant_Spec.md`
3. See visual guide: `AIWritingAssistant_VisualGuide.md`
4. Examine the source code: `AIWritingAssistantView.swift`

Component version: 1.0.0 (Phase 1 - UI Implementation)
Last updated: February 7, 2026
