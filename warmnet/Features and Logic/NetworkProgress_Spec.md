# Network Progress Rings Feature

## Overview

The Network Progress Rings feature displays Apple Watch-style concentric progress rings showing how much of each network tier has been contacted within their respective time windows. This provides users with a visual representation of their network engagement.

## Visual Design

```
┌─────────────────────────────────────┐
│  Network Coverage                   │
│                                     │
│         ╭───────────────╮          │
│        ╱   ╭─────────╮   ╲         │
│       │   ╱  ╭─────╮  ╲   │        │
│       │  │  │  🟢  │  │   │        │
│       │   ╲  ╰─────╯  ╱   │        │
│        ╲   ╰─────────╯   ╱         │
│         ╰───────────────╯          │
│                                     │
│     🟢 5/7  •  🔵 12/15  •  🟡 23/45 │
└─────────────────────────────────────┘
```

### Ring Layout
- **Inner (Green)**: Inner Circle contacts - 14-day window
- **Middle (Blue)**: Key Relationships contacts - 60-day window  
- **Outer (Yellow)**: Broader Network contacts - 180-day window

### Dynamic Ring Visibility
- Rings only appear for tiers that have contacts
- If a tier has zero contacts, that ring is hidden
- The remaining rings resize appropriately

## Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                      HomeScreen                              │
│                           │                                  │
│                           ▼                                  │
│               NetworkProgressCard                            │
│                     │         │                              │
│                     ▼         ▼                              │
│    ConcentricProgressRings    NetworkProgressLegend          │
│              │                        │                      │
│              ▼                        ▼                      │
│    NetworkProgressRing        NetworkProgressLegendItem      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              NetworkProgressService                          │
│  - calculateAllProgress(contacts:) → [TierProgress]         │
│  - calculateProgress(contacts:, tier:) → TierProgress       │
│  - isContactedWithinWindow(contact:, days:) → Bool          │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    SwiftData                                 │
│         Contact (with interactions relationship)             │
└─────────────────────────────────────────────────────────────┘
```

## Progress Calculation Logic

### Window Periods
| Tier | Window | Color |
|------|--------|-------|
| Inner Circle | 14 days | Green |
| Key Relationships | 60 days | Blue |
| Broader Network | 180 days | Yellow |

### Algorithm
1. For each tier, filter contacts by priority
2. For each contact, check if ANY interaction exists within the window period
3. Calculate progress as: `contacted / total`
4. Return 0 if total is 0 (prevents division by zero)

### Contact "Contacted" Definition
A contact is considered "contacted" if they have at least one logged interaction within the tier's window period, counting backwards from today.

```swift
let windowStart = Calendar.current.date(byAdding: .day, value: -windowDays, to: Date())
let isContacted = contact.interactions.contains { $0.date >= windowStart }
```

## File Structure

```
warmnet/
├── Views/
│   ├── NetworkProgressCard.swift      # Main card component
│   ├── NetworkProgressRing.swift      # Ring view + ConcentricProgressRings
│   └── NetworkProgressLegend.swift    # Legend with counts
├── Models/
│   └── NetworkProgressService.swift   # Progress calculation logic
```

## Edge Cases

| Scenario | Behavior |
|----------|----------|
| Zero contacts in tier | Ring doesn't render, legend item hidden |
| All contacts contacted | Ring shows 100%, haptic feedback triggered (once per session) |
| New contact added | Counts as "not contacted", progress recalculates |
| Contact tier changed | Both old and new tier progress update in real-time |
| Contact deleted | Removed from count, progress recalculates |
| No interactions ever | All rings show 0% progress |

## Animations

1. **Loading Animation**: Shows ProgressView spinner on initial load
2. **Ring Animation**: Springs from 0 to actual progress on appear
3. **Progress Updates**: Animated transitions when values change
4. **Numeric Text**: Legend counts use `.contentTransition(.numericText())`

## Haptic Feedback

- Triggers **once per session** when a ring is first seen as complete
- Uses `UIImpactFeedbackGenerator(style: .medium)`
- Tracked via `completedTiersThisSession` Set to prevent repeated triggers

## Dependencies

- SwiftUI
- SwiftData
- Contact model (with interactions relationship)
- Priority enum (with color property)

## Testing Considerations

The `NetworkProgressService` is a pure enum with static functions, making it easy to unit test:

```swift
// Test cases to consider:
// - Empty contacts array
// - Contacts with no interactions
// - Contacts with interactions within window
// - Contacts with interactions outside window
// - Mixed scenarios
// - Window boundary edge cases (exactly 14/60/180 days ago)
```
