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
2. Calculate priority score: `(days_overdue × tier_weight) + urgency_bonus + health_penalty`
3. Reserve top 2 slots for Inner Circle contacts (if available)
4. Fill remaining slots with highest priority scores
5. Return up to `max_queue_size` contacts

### 4. ConnectionHealthEngine
Manages persistent connection health scores and integrates manual reminders:

**Key Functions:**
- `recordInteraction()`: Awards points based on timing, updates streakCount, handles manual reminder fulfillment
- `applyDecay()`: Applies passive decay on app activation based on tier and overdue status
- `healthPenalty()`: Calculates boost for low-health contacts in queue

**Scoring:**
- On-time interaction: +8 to +15 points
- Late interaction: +3 to +7 points
- Manual reminder bonus: +2 points
- Streak milestone (every 3): +3 points
- Daily decay: -0.02 to -0.5 per day (varies by tier and overdue status)

### 5. UserSettings
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
Find pending ManualReminders for contact
    ↓
Mark reminder as .completed (link interaction)
    ↓
If repeating: create next occurrence
    ↓
ConnectionHealthEngine.recordInteraction()
    ↓
Calculate points (timing + manual bonus + streak)
Update connectionScore, streakCount
    ↓
ReminderScheduler.rescheduleAfterInteraction()
    ↓
Contact.nextTouchDate updated
Contact.lastContacted updated
    ↓
Contact saved to SwiftData
```
