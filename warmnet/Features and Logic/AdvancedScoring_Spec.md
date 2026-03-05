# Advanced Scoring Settings

## Overview

The Advanced Scoring Settings feature provides power users with global control over the Connection Health Engine's behavior. Through intuitive sliders, users can customize reminder frequencies, priority weights, and scoring behavior without modifying individual contacts.

## Access

**Settings** → **Advanced** → **Scoring & Priorities**

Located in the Settings page (accessed via the profile icon on the Home screen).

## UI Structure

### Per-Tier Settings (3 sections)

Each tier (Inner Circle, Key Relationships, Broader Network) has two sliders:

#### Contact Frequency Slider
- **Range**: "Less Often" (0.5×) to "More Often" (2.0×)
- **Effect**: Multiplies the base frequency days by 1/value
- **Display**: Shows computed days (e.g., "~7 days")

| Tier | Base Days | @ 0.5× (Less Often) | @ 2.0× (More Often) |
|------|-----------|---------------------|---------------------|
| Inner Circle | 14 | ~28 days | ~7 days |
| Key Relationships | 60 | ~120 days | ~30 days |
| Broader Network | 180 | ~360 days | ~90 days |

#### Queue Priority Slider
- **Range**: "Low" (0.5×) to "High" (3.0×)
- **Effect**: Multiplies the tier weight in priority score calculation
- **Display**: Shows computed weight value

| Tier | Base Weight | @ 0.5× (Low) | @ 3.0× (High) |
|------|-------------|--------------|---------------|
| Inner Circle | 3 | 2 | 9 |
| Key Relationships | 2 | 1 | 6 |
| Broader Network | 1 | 1 | 3 |

### Scoring Behavior Section

#### Scoring Sensitivity
- **Range**: "Forgiving" (0.5×) to "Strict" (2.0×)
- **Effect**: Divides points earned per interaction by this value
- **Forgiving**: Interactions worth more points, scores rise faster
- **Strict**: Interactions worth fewer points, requires consistency

#### Decay Speed
- **Range**: "Slow" (0.5×) to "Fast" (2.0×)
- **Effect**: Multiplies all decay rates
- **Slow**: Scores drop gradually when inactive
- **Fast**: Scores drop quickly when inactive

#### Health Boost
- **Range**: "Off" (0.0×) to "Aggressive" (2.0×)
- **Effect**: Multiplies the health penalty in queue priority calculation
- **Off**: Low-health contacts get no priority boost
- **Aggressive**: Low-health contacts surface prominently in queue

### Queue Section

#### Daily Contacts
- **Type**: Stepper (3-10)
- **Effect**: Maximum contacts in daily queue
- **Default**: 5

### Reset to Defaults

Button to restore all advanced settings to their default values (1.0 multipliers).

## Data Model

All settings are stored in `UserSettings.swift`:

```swift
// Per-Tier Frequency Multipliers (0.5 to 2.0)
var innerCircleFrequencyMultiplier: Double = 1.0
var keyRelationshipsFrequencyMultiplier: Double = 1.0
var broaderNetworkFrequencyMultiplier: Double = 1.0

// Per-Tier Priority Weight Multipliers (0.5 to 3.0)
var innerCirclePriorityMultiplier: Double = 1.0
var keyRelationshipsPriorityMultiplier: Double = 1.0
var broaderNetworkPriorityMultiplier: Double = 1.0

// Global Scoring Multipliers
var scoringGainMultiplier: Double = 1.0      // 0.5 to 2.0
var decayRateMultiplier: Double = 1.0        // 0.5 to 2.0
var healthPenaltyMultiplier: Double = 1.0    // 0.0 to 2.0
```

### Helper Methods

```swift
func frequencyMultiplier(for priority: Priority) -> Double
func priorityMultiplier(for priority: Priority) -> Double
func setFrequencyMultiplier(_ value: Double, for priority: Priority)
func setPriorityMultiplier(_ value: Double, for priority: Priority)
func setScoringGainMultiplier(_ value: Double)
func setDecayRateMultiplier(_ value: Double)
func setHealthPenaltyMultiplier(_ value: Double)
func resetAdvancedToDefaults()
var hasCustomAdvancedSettings: Bool
```

## Engine Integration

### TierConfiguration

Uses the settings-aware overload:

```swift
static func forPriority(_ priority: Priority, settings: UserSettings) -> TierConfiguration
```

Applied in:
- `DailyQueueGenerator.generateQueue()`
- `DailyQueueGenerator.fetchDailyQueueWithDetails()`
- `ReminderScheduler.scheduleNewContact()`
- `ReminderScheduler.rescheduleAfterInteraction()`

### ConnectionHealthEngine

Methods accept optional UserSettings:

```swift
static func recordInteraction(..., settings: UserSettings? = nil, ...)
static func applyDecay(to contacts: [Contact], settings: UserSettings? = nil, ...)
static func healthPenalty(for contact: Contact, settings: UserSettings? = nil) -> Double
```

## Use Cases

### Example 1: Prioritize Inner Circle

A user wants to connect more frequently with their closest contacts:
- Inner Circle Frequency: 2.0× ("More Often") → ~7 days instead of 14
- Inner Circle Priority: 2.0× → Weight 6 instead of 3

### Example 2: Low-Maintenance Mode

A user going through a busy period wants less pressure:
- All Frequency sliders: 0.5× ("Less Often") → doubles all intervals
- Scoring Sensitivity: 0.5× ("Forgiving") → interactions worth more
- Decay Speed: 0.5× ("Slow") → scores drop slowly

### Example 3: Focus on Neglected Relationships

A user wants to catch up with fading connections:
- Health Boost: 2.0× ("Aggressive") → low-health contacts prioritized
- Daily Contacts: 7 → more contacts per day

## Files

| File | Purpose |
|------|---------|
| `Screens/Settings/AdvancedScoringScreen.swift` | UI for advanced settings |
| `Screens/Settings/SettingsScreen.swift` | Navigation link to Advanced |
| `Models/ReminderSystem/UserSettings.swift` | Multiplier properties and helpers |
| `Models/ReminderSystem/TierConfiguration.swift` | Settings-aware overload |
| `Models/ReminderSystem/ConnectionHealthEngine.swift` | Scoring with multipliers |
| `Models/ReminderSystem/ReminderScheduler.swift` | Scheduling with settings |
| `Models/ReminderSystem/DailyQueueGenerator.swift` | Queue with settings |

## Future Enhancements

- Per-contact overrides (individual frequency/priority)
- Presets (e.g., "Busy Mode", "Reconnect Mode")
- Visual preview of how settings affect the queue
- Import/export settings
