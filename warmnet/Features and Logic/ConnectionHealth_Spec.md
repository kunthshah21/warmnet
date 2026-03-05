# Connection Health Engine

## Overview

The Connection Health Engine is a unified system that integrates the automatic point-based reminder system with manual reminders. It introduces a persistent **connection score** for each contact that reflects the actual quality and recency of interactions, provides a feedback loop when reminders are fulfilled, and enables repeating manual reminders to actually repeat.

## Core Concepts

### Connection Health Score

Each contact has a `connectionScore` (0-100) that represents the current health of the relationship:

- **New contacts** start at 50 (neutral midpoint)
- **Healthy relationships** (regular, on-time interactions) trend toward 80-100
- **Neglected relationships** (missed reminders, overdue contacts) decay toward 0-30
- **Score affects queue priority** via a health penalty that boosts low-health contacts

### Unified Reminder Lifecycle

Manual reminders now have a lifecycle status:

| Status | Description |
|--------|-------------|
| `pending` | Active reminder waiting to be fulfilled |
| `completed` | Fulfilled by logging an interaction |
| `missed` | Not fulfilled within its time window |
| `snoozed` | Temporarily deferred |

When a user logs an interaction, the system automatically:
1. Finds any pending manual reminders for that contact
2. Marks them as `completed` and links to the interaction
3. If the reminder repeats, creates the next occurrence
4. Awards points to the connection score

## Data Model Changes

### Contact (new properties)

| Property | Type | Default | Purpose |
|----------|------|---------|---------|
| `connectionScore` | `Double` | `50.0` | Relationship health 0-100 |
| `streakCount` | `Int` | `0` | Consecutive on-time interactions |
| `totalInteractionCount` | `Int` | `0` | Lifetime interaction count |
| `averageResponseDays` | `Double` | `0.0` | Rolling average response time |
| `lastScoreUpdate` | `Date?` | `nil` | Timestamp for decay calculation |

### ManualReminder (new properties)

| Property | Type | Default | Purpose |
|----------|------|---------|---------|
| `statusRaw` | `String` | `"pending"` | Lifecycle state |
| `completedAt` | `Date?` | `nil` | When fulfilled |
| `linkedInteractionId` | `UUID?` | `nil` | Reference to fulfilling interaction |
| `sourceRaw` | `String` | `"manual"` | Origin (manual, automatic, urgent) |

### New Enums

```swift
enum ReminderStatus: String, Codable {
    case pending, completed, missed, snoozed
}

enum ReminderSource: String, Codable {
    case manual      // User-created
    case automatic   // System-generated
    case urgent      // User-created with urgent flag
}
```

## Scoring System

### Points Earned on Interaction

| Event | Points | Formula |
|-------|--------|---------|
| On-time interaction | +8 to +15 | `min(15, 8 + daysEarly × 0.5)` |
| Late interaction | +3 to +7 | `max(3, 8 - daysLate × 0.5)` |
| Manual reminder fulfilled | +2 | Bonus on top of timing points |
| Streak milestone | +3 | Every 3 consecutive on-time interactions |

### Passive Decay

Decay is applied when the app becomes active, based on days since `lastScoreUpdate`:

| Tier | Daily Decay Rate |
|------|-----------------|
| Inner Circle | -0.15 |
| Key Relationships | -0.05 |
| Broader Network | -0.02 |
| Severely Overdue (any tier) | -0.5 |

**Severely overdue** = overdue by more than 2× the tier's frequency period.

### Health Penalty in Queue

Low-health contacts get a priority boost in the daily queue:

```
health_penalty = max(0, (50 - connectionScore) × 0.3 × healthPenaltyMultiplier)
priority_score = (days_overdue × tier_weight) + urgency_bonus + health_penalty
```

This ensures that fading relationships naturally surface for attention.

## Configurable Multipliers

All scoring and decay values can be customized through **Advanced Scoring Settings** (Settings → Advanced → Scoring & Priorities). See `AdvancedScoring_Spec.md` for full documentation.

### Available Multipliers

| Setting | Range | Default | Effect |
|---------|-------|---------|--------|
| Per-Tier Frequency | 0.5–2.0 | 1.0 | Divides base frequency days (higher = more frequent) |
| Per-Tier Priority | 0.5–3.0 | 1.0 | Multiplies tier weight in queue |
| Scoring Sensitivity | 0.5–2.0 | 1.0 | Divides points earned (higher = stricter) |
| Decay Speed | 0.5–2.0 | 1.0 | Multiplies decay rates |
| Health Boost | 0.0–2.0 | 1.0 | Multiplies health penalty in queue |

### How Multipliers Flow

1. **TierConfiguration.forPriority(_:settings:)** applies frequency and priority multipliers
2. **ConnectionHealthEngine.recordInteraction()** applies scoring sensitivity
3. **ConnectionHealthEngine.applyDecay()** applies decay speed
4. **ConnectionHealthEngine.healthPenalty()** applies health boost multiplier
5. **DailyQueueGenerator** uses settings-aware tier config and health penalty

## Data Flow

### Logging an Interaction

```
User logs interaction
    ↓
LogInteractionSheet.saveInteraction()
    ↓
Find pending ManualReminders for contact
    ↓
Mark first pending as .completed
Link interaction ID
    ↓
If repeatInterval != .never:
    Create next ManualReminder occurrence
    ↓
ConnectionHealthEngine.recordInteraction()
    ↓
Calculate timing (on-time vs late)
    ↓
Award points to connectionScore
Update streakCount, totalInteractionCount, averageResponseDays
    ↓
ReminderScheduler.rescheduleAfterInteraction()
    ↓
Update lastScoreUpdate, updatedAt
    ↓
Contact saved
```

### App Activation (Decay)

```
App becomes active
    ↓
warmnetApp.setupLocationNotificationService()
    ↓
Fetch all contacts
    ↓
ConnectionHealthEngine.applyDecay()
    ↓
For each contact:
    Calculate days since lastScoreUpdate
    Determine decay rate (tier + overdue status)
    Apply decay to connectionScore
    Update lastScoreUpdate
    ↓
Save context
```

### Creating a Manual Reminder

```
User creates reminder in AddReminderSheet
    ↓
ManualReminder created with:
    status: .pending
    source: .manual or .urgent
    ↓
nextTouchDate is NOT overwritten (key change!)
    ↓
Both reminder and automatic schedule coexist
```

## Key Design Decisions

### 1. Manual Reminders No Longer Overwrite nextTouchDate

Previously, creating a manual reminder would overwrite `contact.nextTouchDate`, disrupting the automatic scheduling system. Now they coexist:

- The automatic schedule continues based on tier frequency
- Manual reminders are tracked separately with their own lifecycle
- The UI can show both, prioritizing whichever is earliest

### 2. Interaction Fulfills Reminders Automatically

Users don't need to manually mark reminders as done. Logging any interaction for a contact automatically fulfills its pending reminders.

### 3. Repeat Intervals Now Work

The `repeatInterval` property on `ManualReminder` was previously stored but never acted on. Now when a reminder is fulfilled:

- If `repeatInterval != .never`, a new `ManualReminder` is created with the next occurrence date
- The new reminder has `status: .pending` and inherits all properties

### 4. Decay Runs on App Activation

No background tasks needed. Decay is calculated when the app becomes active, using elapsed time since `lastScoreUpdate`.

### 5. Backward Compatible

- All new properties have sensible defaults
- Existing data is migrated via `MigrationHelper.migrateConnectionHealth()`
- No schema version change required (SwiftData lightweight migration)

## Migration

On first app launch after update, `MigrationHelper.migrateConnectionHealth()` runs:

1. **For each Contact** without `lastScoreUpdate`:
   - Set `totalInteractionCount = interactions.count`
   - Calculate initial `connectionScore` based on interaction recency
   - Set `lastScoreUpdate = Date()`

2. **For each ManualReminder** with empty status/source:
   - Set `statusRaw = "pending"`
   - Set `sourceRaw` based on `isUrgent` flag

## Files Involved

| File | Role |
|------|------|
| `Models/DataModels/Contact.swift` | Connection health properties |
| `Models/DataModels/ManualReminder.swift` | Lifecycle properties, enums |
| `Models/ReminderSystem/ConnectionHealthEngine.swift` | Core scoring and decay logic |
| `Models/ReminderSystem/DailyQueueGenerator.swift` | Health penalty in priority score |
| `Models/ReminderSystem/TierConfiguration.swift` | Settings-aware frequency/priority config |
| `Models/ReminderSystem/UserSettings.swift` | Multiplier properties and helpers |
| `Models/ReminderSystem/ReminderScheduler.swift` | Scheduling with settings |
| `Screens/Contacts/LogInteractionSheet.swift` | Fulfill reminders on interaction |
| `Screens/Contacts/AddContactSheet.swift` | Schedule with settings |
| `Screens/Settings/AdvancedScoringScreen.swift` | UI for configuring multipliers |
| `Views/Dashboard/DashboardSheets.swift` | Create reminders without overwriting nextTouchDate |
| `Screens/Reminders/RemindersScreen.swift` | Filter to pending reminders |
| `Models/Utilities/MigrationHelper.swift` | Data migration |
| `warmnetApp.swift` | Decay trigger on app activation |

## Testing Considerations

- Verify score increases on interaction (8-15 points on-time, 3-7 late)
- Confirm streak bonus triggers at milestones (3, 6, 9...)
- Test decay calculation with multi-day gaps
- Verify severely overdue accelerates decay
- Test repeat reminder creation for all interval types
- Confirm pending filter in RemindersScreen
- Validate migration sets correct initial scores
- Test health penalty boosts low-score contacts in queue

## Future Enhancements

- Connection health visualization (progress rings, trends)
- Streak badges and achievements
- Analytics on relationship health over time
- Smart suggestions based on declining scores
- Notification when connection score drops below threshold
