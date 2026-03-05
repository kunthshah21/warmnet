# Reminder System Architecture

## Overview

The Reminder System is a sophisticated contact tracking mechanism that prevents "due date cliffs" by intelligently distributing contact reminders across time. It uses random distribution, variance recalculation, and smart daily queuing to ensure users maintain relationships without feeling overwhelmed.

## Core Components

### 1. TierConfiguration
- Defines reminder frequencies for each priority tier
- **Inner Circle**: 14 days (weight: 3, variance: ±15%)
- **Key Relationships**: 60 days (weight: 2, variance: ±15%)
- **Broader Network**: 180 days (weight: 1, variance: ±15%)

### 2. ReminderScheduler
Core algorithm implementation:

#### **New Contact Scheduling**
When a contact is created:
```
next_touch_date = current_date + RANDOM(0, frequency_days)
```
This spreads contacts naturally across the first cycle period.

#### **Post-Interaction Rescheduling**
After logging an interaction:
```
buffer = frequency_days × variance_percent
random_adjustment = RANDOM(-buffer, +buffer)
next_touch_date = current_date + frequency_days + random_adjustment
```
Variance prevents contacts from re-synchronizing over time.

#### **Custom Schedule Override**
For "Inner Circle" contacts, users can override the default tier-based frequency with a custom schedule.

**Configuration:**
- **Frequency**: Day(s) or Week(s)
- **Interval**: Number of units (e.g., every 2 weeks)
- **Specific Days**: For weekly schedules, specific days (e.g., Mon, Wed) can be selected.

**Logic:**
If `useCustomSchedule` is enabled, the standard variance logic is bypassed:
1. **Day-based**: 
   ```
   next_touch_date = current_date + interval_days
   ```
2. **Week-based (Simple)**: 
   ```
   next_touch_date = current_date + (interval_weeks * 7)
   ```
3. **Week-based (Specific Days)**:
   - Finds the next matching weekday from the selected set.
   - If the next match is later in the *current* week, schedule for that day.
   - If not, jump `interval_weeks` ahead and schedule for the first available matching day in that future week.

### 3. DailyQueueGenerator
Generates the daily list of contacts to reach out to:

**Algorithm:**
1. Filter contacts where `next_touch_date ≤ current_date`
2. Calculate priority score: `days_overdue × tier_weight`
3. Reserve top 2 slots for Inner Circle contacts (if available)
4. Fill remaining slots with highest priority scores
5. Return up to `max_queue_size` contacts

### 4. UserSettings
User-configurable preferences:
- `dailyQueueSize`: 3-10 contacts per day (default: 5)
- Stored as SwiftData model for persistence

## Data Flow

### Creating a New Contact
```
User adds contact
    ↓
ReminderScheduler.scheduleNewContact()
    ↓
Random offset calculated (0 to frequency_days)
    ↓
Contact.nextTouchDate set
    ↓
Contact saved to SwiftData
```

### Logging an Interaction
```
User logs interaction with contact
    ↓
Find and fulfill pending ManualReminders
    ↓
If repeating: create next occurrence
    ↓
ConnectionHealthEngine.recordInteraction()
    ↓
Calculate points earned (timing + bonuses)
Update connectionScore, streakCount
    ↓
ReminderScheduler.rescheduleAfterInteraction()
    ↓
Contact.nextTouchDate updated
Contact.lastContacted updated
    ↓
Contact saved to SwiftData
```

### Daily Queue Display
```
App launches or user views queue
    ↓
DailyQueueGenerator.fetchDailyQueue()
    ↓
UserSettings.dailyQueueSize retrieved
    ↓
All overdue contacts fetched
    ↓
Priority scores calculated
    ↓
Queue sorted and limited
    ↓
UI displays top N contacts
```

## Key Benefits

### 1. Prevents Clustering
Random distribution means contacts added at the same time don't all become due on the same day.

### 2. Maintains Distribution
Variance on recalculation prevents gradual re-synchronization over multiple cycles.

### 3. Reduces Cognitive Load
Daily queue limits ensure users see 3-10 contacts per day, not 50+.

### 4. Feels Natural
Small variances make the system feel less robotic and more human.

## Implementation Status

### ✅ Phase 1 (MVP) - IMPLEMENTED
- [x] Basic random distribution on contact creation
- [x] Variance on interaction logging
- [x] Simple daily queue (no urgency bonus)
- [x] User settings for queue size

### ✅ Phase 2 (Enhancement) - IMPLEMENTED
- [x] Urgency bonus for birthdays (within 7 days = +15 points)
- [x] Urgency bonus for milestones (within 14 days = +10 points)
- [x] Severely overdue bonus (2x past frequency = +20 points)
- [x] Milestone tracking system
- [x] Configurable bonus values in UserSettings
- [x] Bonus breakdown for UI display

### ✅ Phase 3 (Connection Health) - IMPLEMENTED
- [x] Connection Health Engine with persistent scoring
- [x] Manual reminder lifecycle (pending → completed/missed)
- [x] Health penalty in priority score formula
- [x] Passive decay based on tier and overdue status
- [x] Streak tracking and milestone bonuses
- [x] Repeat reminder support (reminders now actually repeat)
- [x] Migration helper for existing data

> **See also:** [ConnectionHealth_Spec.md](./ConnectionHealth_Spec.md) for full documentation.

### 🔲 Phase 4 (Optimization) - PLANNED
- [ ] Bulk import even distribution
- [ ] Advanced queue filtering
- [ ] Analytics dashboard
- [ ] Adaptive frequency suggestions
- [ ] Connection health visualization

## Usage Examples

### Scheduling a New Contact
```swift
let contact = Contact(name: "Sarah", priority: .innerCircle)
ReminderScheduler.scheduleNewContact(contact)
// nextTouchDate set to Date() + 0-14 days randomly
```

### Logging an Interaction
```swift
let interaction = Interaction(date: Date(), interactionType: .call, contact: contact)
ReminderScheduler.rescheduleAfterInteraction(contact)
// nextTouchDate set to Date() + 14 days ± 2 days variance
```

### Fetching Daily Queue
```swift
let context = modelContext
let queue = try DailyQueueGenerator.fetchDailyQueue(from: context)
// Returns up to 5 contacts (or user's configured amount)
```

### Fetching Daily Queue with Urgency Details (for UI)
```swift
let context = modelContext
let queueWithDetails = try DailyQueueGenerator.fetchDailyQueueWithDetails(from: context)

for item in queueWithDetails {
    print("Contact: \(item.contact.name)")
    print("Priority Score: \(item.priorityScore)")
    print("Urgency Bonus: \(item.urgencyBonus)")
    print("Urgency Reason: \(item.bonusBreakdown.urgencyDescription)")
    // e.g., "🎂 Birthday in 3 days • ⚠️ Very overdue"
}
```

### Configuring Urgency Bonuses
```swift
let settings = UserSettings.getOrCreate(from: context)

// Enable/disable urgency bonuses
settings.updateUrgencyBonus(enabled: true)

// Customize bonus point values
settings.updateUrgencyBonus(
    birthdayPoints: 20.0,      // Increase birthday priority
    milestonePoints: 15.0,     // Increase milestone priority
    overduePoints: 25.0        // Increase overdue priority
)
```

## Urgency Bonus System

### Overview
The urgency bonus system adds time-sensitive priority boosts to contacts, ensuring important events aren't missed.

### Bonus Types

**1. Birthday Bonus (+15 points default)**
- Triggers when birthday is within 7 days
- Calculates annual occurrence automatically
- Configurable via `UserSettings.birthdayBonusPoints`

**2. Milestone Bonus (+10 points default)**
- Triggers when milestone is within 14 days
- Examples: anniversaries, work events, special occasions
- Configurable via `UserSettings.milestoneBonusPoints`

**3. Severely Overdue Bonus (+20 points default)**
- Triggers when contact is 2× past their tier frequency
- Inner Circle: 28+ days overdue
- Key Relationships: 120+ days overdue
- Broader Network: 360+ days overdue
- Configurable via `UserSettings.severelyOverdueBonusPoints`

### Priority Score Formula

```
priority_score = (days_overdue × tier_weight) + urgency_bonus + health_penalty

Where:
- days_overdue = max(0, current_date - next_touch_date)
- tier_weight = 3 (Inner), 2 (Key), 1 (Broader)
- urgency_bonus = birthday_bonus + milestone_bonus + overdue_bonus
- health_penalty = max(0, (50 - connectionScore) × 0.3)
```

The `health_penalty` boosts contacts with low connection health scores, ensuring fading relationships surface in the queue. See [ConnectionHealth_Spec.md](./ConnectionHealth_Spec.md) for details on how connection scores are calculated.

### UI Integration

The `BonusBreakdown` struct provides UI-friendly information:

```swift
let breakdown = UrgencyBonusCalculator.getBonusBreakdown(
    for: contact,
    settings: settings
)

if breakdown.hasAnyBonus {
    // Show urgency indicator
    Text(breakdown.urgencyDescription)
        .foregroundColor(.orange)
    // e.g., "🎂 Birthday in 3 days • 🎯 Work anniversary in 10 days"
}
```

## Testing Considerations

- Verify random distribution produces values within expected range
- Confirm variance prevents synchronization over multiple cycles
- Test queue generation with various contact counts
- Validate user settings persistence
- Ensure timezone handling for date calculations
- Test birthday bonus triggers within 7-day window
- Verify milestone bonus with multiple upcoming milestones
- Confirm severely overdue bonus at 2× frequency threshold
- Test urgency bonus can be disabled via UserSettings
- Validate bonus breakdown provides accurate UI descriptions
