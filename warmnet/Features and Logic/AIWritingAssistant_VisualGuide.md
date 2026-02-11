# AI Writing Assistant - Visual Design Guide

## Component Anatomy

### State 1: Before Threshold (< 50 words)
```
┌─────────────────────────────────────┐
│ Notes (optional)                    │
│ ┌─────────────────────────────────┐ │
│ │ Add details about the           │ │
│ │ interaction... (user typing)    │ │
│ │                                 │ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘

No AI assistant visible yet.
```

### State 2: Threshold Reached (50+ words)
```
┌─────────────────────────────────────┐
│ Notes (optional)                    │
│ ┌─────────────────────────────────┐ │
│ │ We had a great conversation     │ │
│ │ about AI and machine learning   │ │
│ │ at the coffee shop. They shared │ │
│ │ insights about neural networks  │ │
│ │ and deep learning applications. │ │
│ │ Really enjoyed discussing the   │ │
│ │ future of technology together.  │ │
│ │ We plan to meet again next      │ │
│ │ month to continue the chat.     │ │
│ └─────────────────────────────────┘ │
│                                     │
│     ╔═══════════════════╗           │
│     ║ ✨ Ask Brive     ║  ← Clickable
│     ╚═══════════════════╝           │
└─────────────────────────────────────┘

Capsule button appears below text field
Subtle animation: fade + scale
```

### State 3: Prompt Displayed
```
┌─────────────────────────────────────┐
│ Notes (optional)                    │
│ ┌─────────────────────────────────┐ │
│ │ We had a great conversation     │ │
│ │ about AI and machine learning   │ │
│ │ at the coffee shop. They shared │ │
│ │ insights about neural networks  │ │
│ │ and deep learning applications. │ │
│ │ Really enjoyed discussing the   │ │
│ │ future of technology together.  │ │
│ │ We plan to meet again next      │ │
│ │ month to continue the chat.     │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ───────────────────────────────────  │ ← Divider
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ How did this interaction make   │ │
│ │ you feel?                    ↻  │ │ ← Refresh
│ │                                 │ │
│ │ (Italicized, semi-bold prompt)  │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘

Light divider separates writing flow
Prompt appears with background container
Refresh button on the right
```

## Color Specifications

### Light Mode
```
┌────────────────────────────────────┐
│ ╔════════════════╗                 │
│ ║ ✨ Ask Brive  ║  Background: #F2F2F7
│ ╚════════════════╝  Text: #3069FF (blue)
│                                    │
│ ───────────────────────  Divider: rgba(0,0,0,0.1)
│                                    │
│ ┌────────────────────────────────┐ │
│ │ Prompt text...              ↻ │ │
│ │                               │ │
│ │ Background: #FAFAFC           │ │
│ │ Text: rgba(0,0,0,0.85)        │ │
│ └────────────────────────────────┘ │
└────────────────────────────────────┘
```

### Dark Mode
```
┌────────────────────────────────────┐
│ ╔════════════════╗                 │
│ ║ ✨ Ask Brive  ║  Background: #333333
│ ╚════════════════╝  Text: #99BFFF (soft blue)
│                                    │
│ ───────────────────────  Divider: rgba(255,255,255,0.15)
│                                    │
│ ┌────────────────────────────────┐ │
│ │ Prompt text...              ↻ │ │
│ │                               │ │
│ │ Background: #262626           │ │
│ │ Text: rgba(255,255,255,0.85)  │ │
│ └────────────────────────────────┘ │
└────────────────────────────────────┘
```

## Typography Details

### "Ask Brive" Indicator
- Font: WorkSans-Medium
- Size: 13pt
- Weight: Medium
- Icon: sparkles (SF Symbol, 12pt, semibold)

### Prompt Text
- Font: WorkSans-Regular
- Size: 15pt
- Style: Italic
- Weight: Semibold
- Line Spacing: 3pt
- Color: Primary with 85% opacity

### Refresh Button
- Icon: arrow.clockwise (SF Symbol)
- Size: 14pt
- Weight: Semibold
- Container: Circle, 32×32pt

## Spacing & Layout

### Indicator Button
- Horizontal padding: 14pt
- Vertical padding: 8pt
- Corner radius: Capsule (fully rounded)
- Top margin: 12pt
- Shadow: Black 8% opacity, 4pt radius, 0x 2y offset

### Prompt Container
- Padding: 14pt all sides
- Corner radius: 12pt
- Background: Subtle gray (adapts to mode)
- Divider margin: 16pt vertical

### Overall Component
- Spacing between indicator and divider: 16pt
- Spacing between divider and prompt: 16pt

## Animation Specifications

### Indicator Appearance
```
Animation: .easeInOut(duration: 0.3)
Transition: 
  - opacity: 0 → 1
  - scale: 0.95 → 1.0
```

### Prompt Display
```
Animation: .easeInOut(duration: 0.3)
Transition:
  - opacity: 0 → 1
  - move: top edge
```

### Refresh Button Press
```
Animation: .easeInOut(duration: 0.2)
Effect: Prompt text cross-fades to new prompt
```

## Interaction Flow

```
User types
    ↓
Word count < 50
    ↓
Nothing shown
    ↓
Word count ≥ 50
    ↓
"Ask Brive" appears (animated)
    ↓
User taps indicator
    ↓
Indicator disappears
    ↓
Divider + Prompt appear (animated)
    ↓
User can tap ↻ to refresh
    ↓
New prompt cross-fades in
    ↓
User continues typing (threshold now 75 words)
    ↓
Word count ≥ 75
    ↓
"Ask Brive" appears again
```

## Responsive Behavior

### iPhone (Small screens)
- Full width minus standard padding
- Single column layout
- Refresh button stays visible on right

### iPhone (Large screens)
- Same layout as small screens
- More breathing room with padding

### iPad
- Component scales naturally
- Maximum width constraints respected
- Touch targets remain accessible

## Accessibility Features

### Dynamic Type Support
- All text respects system font size preferences
- Minimum touch target: 44×44pt (iOS standard)
- Spacing adjusts with text scaling

### VoiceOver Support
- Indicator button: "Ask Brive button. Tap to get a writing prompt."
- Refresh button: "Refresh prompt button. Tap to generate a new prompt."
- Prompt text: Reads full prompt content

### Color Contrast
- Light mode text/background: 7.2:1 (AAA rated)
- Dark mode text/background: 8.1:1 (AAA rated)
- Blue indicator text: 4.5:1 minimum (AA rated)

## Integration Context

### LogInteractionSheet
```
Notes (optional)          ← Section header
[Text Field]             ← Multi-line input
[AI Assistant]           ← Our component
                         ← Scrollable area
[Save Interaction]       ← Bottom button
```

### AddContactSheet
```
[Contact Form Fields]
...
Notes                    ← Section header
[Text Editor]           ← Large text input
[AI Assistant]          ← Our component
...
[Done Button]
```

## Design Rationale

### Why Capsule Button?
- Consistent with iOS design patterns
- Clearly actionable/tappable
- Stands out without being intrusive
- Matches other pill-shaped UI elements in the app

### Why Sparkles Icon?
- Universal symbol for AI/magic
- Friendly and approachable
- Not too technical or intimidating
- Well-recognized in modern UI

### Why Divider?
- Creates visual separation
- Indicates shift in content type
- Doesn't interrupt reading flow
- Subtle but effective boundary

### Why Italics + Semibold?
- Italics: Indicates suggested/assistant content
- Semibold: Ensures readability despite italic style
- Differentiates from user-written content
- Professional yet conversational tone

### Why Bottom-Right Refresh?
- Standard position for secondary actions
- Doesn't interfere with reading
- Easy thumb reach on mobile
- Matches common UI patterns
