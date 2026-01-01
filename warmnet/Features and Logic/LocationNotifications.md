# Location-Based Notification System

## Overview

The location notification system alerts users when they enter a city where their contacts live. This helps users maintain relationships by prompting them to connect with contacts while traveling or visiting different areas.

## Architecture

### Components

```
┌─────────────────────────────────────────────────────────────┐
│                      warmnetApp                              │
│  - Sets up services on launch                               │
│  - Provides ModelContext to services                        │
│  - Handles notification action callbacks                    │
└──────────────────────┬──────────────────────────────────────┘
                       │
         ┌─────────────┴─────────────┐
         ▼                           ▼
┌─────────────────────┐    ┌─────────────────────┐
│ LocationNotification│    │ NotificationManager │
│      Service        │    │                     │
│                     │    │ - UNUserNotification│
│ - Geofence setup    │───▶│   Center wrapper    │
│ - Region monitoring │    │ - Permission mgmt   │
│ - Entry handling    │    │ - Notification      │
│                     │    │   scheduling        │
└─────────┬───────────┘    └─────────────────────┘
          │
          ▼
┌─────────────────────┐    ┌─────────────────────┐
│ContactLocationMatcher│    │ NotificationHistory │
│                     │    │                     │
│ - City prioritization│    │ - Cooldown tracking │
│ - Contact matching  │    │ - Snooze management │
│ - Geocoding         │    │ - History cleanup   │
└─────────────────────┘    └─────────────────────┘
```

### Models

| Model | Purpose |
|-------|---------|
| `NotificationHistory` | Tracks when notifications were sent, manages cooldowns and snoozing |
| `UserSettings` (extended) | Stores notification preferences (enabled, cooldown, quiet hours) |

### Services

| Service | Purpose |
|---------|---------|
| `LocationNotificationService` | Core orchestrator for geofencing, region monitoring, and notification triggering |
| `NotificationManager` | Handles UNUserNotificationCenter interactions, permissions, and notification scheduling |
| `ContactLocationMatcher` | Utility for finding contacts by city and prioritizing cities for geofencing |

## Data Flow

### Geofence Setup (App Launch)

```
App launches
    ↓
warmnetApp.setupLocationNotificationService()
    ↓
Check if locationNotificationsEnabled in UserSettings
    ↓
Fetch all contacts with city data
    ↓
ContactLocationMatcher.prioritizeCitiesForGeofencing()
    ↓
Geocode top 20 cities to get coordinates
    ↓
Create CLCircularRegion for each city (15km radius)
    ↓
locationManager.startMonitoring(for: region)
```

### Notification Trigger (Region Entry)

```
User enters monitored region (iOS triggers event)
    ↓
locationManager(_:didEnterRegion:)
    ↓
LocationNotificationService.handleRegionEntry()
    ↓
Check UserSettings.locationNotificationsEnabled
    ↓
Check UserSettings.isInQuietHours
    ↓
Check NotificationHistory.canNotify() (cooldown)
    ↓
Fetch contacts in city from SwiftData
    ↓
NotificationManager.scheduleLocationNotification()
    ↓
NotificationHistory.record() (save to history)
```

### Notification Action (User Response)

```
User taps notification or action button
    ↓
NotificationManager.userNotificationCenter(_:didReceive:)
    ↓
NotificationManager.onLocationNotificationAction callback
    ↓
warmnetApp.handleNotificationAction()
    ↓
Execute action (view contacts, snooze, dismiss)
```

## Configuration

### User Settings (UserSettings model)

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `locationNotificationsEnabled` | Bool | true | Master toggle for feature |
| `notificationCooldownHours` | Int | 24 | Hours between notifications for same city |
| `quietHoursEnabled` | Bool | false | Enable quiet hours |
| `quietHoursStart` | Int | 22 | Quiet hours start (10 PM) |
| `quietHoursEnd` | Int | 8 | Quiet hours end (8 AM) |

### Cooldown Options (NotificationCooldown enum)

| Option | Hours | Description |
|--------|-------|-------------|
| `.oncePerVisit` | 0 | Minimum 1 hour between notifications |
| `.everyTwelveHours` | 12 | Twice daily maximum |
| `.daily` | 24 | Once per day (default) |
| `.everyTwoDays` | 48 | Every other day |
| `.weekly` | 168 | Once per week |

## Permissions

### Required Info.plist Keys

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>...</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>...</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>...</string>

<key>UIBackgroundModes</key>
<array>
    <string>location</string>
</array>
```

### Permission Flow

1. Request "When In Use" authorization
2. Request upgrade to "Always" authorization
3. Request notification authorization

**Note:** Geofencing requires "Always" authorization. "When In Use" is not sufficient.

## iOS Constraints

### Geofencing Limits

- **Maximum 20 regions per app** - System-enforced limit
- Regions persist across app terminations
- Entry events delivered even when app is killed
- Minimum region radius: 100 meters
- Current implementation uses 15km radius (city-level)

### City Prioritization Algorithm

Cities are prioritized for the 20-region limit by:

1. **Priority Score**: Sum of contact tier weights in city
   - Inner Circle: 3 points per contact
   - Key Relationships: 2 points per contact
   - Broader Network: 1 point per contact

2. **Contact Count**: Tiebreaker for equal priority scores

## UI Components

### NotificationsSettingsScreen

Sections:
1. **Permissions** - Status badges and request buttons
2. **Location Notifications** - Master toggle
3. **Frequency** - Cooldown picker
4. **Quiet Hours** - Time range configuration
5. **Monitored Cities** - List of tracked cities (read-only)

## Notification Content

**Title:** "You're in [City]!"

**Body Examples:**
- 1 contact: "Connect with Sarah while you're here."
- 2 contacts: "Connect with Sarah and Mike while you're here."
- 3-4 contacts: "Connect with Sarah, Mike, and Alex while you're here."
- 5+ contacts: "Connect with Sarah, Mike, and 3 others while you're here."

**Actions:**
- View Contacts (opens app, filtered to city)
- Snooze 2 Hours
- Dismiss

## Testing

### Simulator Limitations

Geofencing cannot be tested in the iOS Simulator. Use:
- Physical device testing
- GPX files for location simulation in Xcode
- `simulateRegionEntry(city:)` method for unit testing

### Test Scenarios

1. **Permission denied** - Verify graceful degradation
2. **No contacts in city** - Verify no notification sent
3. **Cooldown active** - Verify notification suppression
4. **Quiet hours** - Verify timing respects settings
5. **20+ cities** - Verify prioritization works correctly
6. **Background state** - Verify notifications arrive when app is killed

## Future Enhancements

- [ ] Deep link to filtered contacts list on notification tap
- [ ] "Once per visit" using exit detection
- [ ] Smart notification timing based on user patterns
- [ ] Suggested contacts based on last interaction date
- [ ] Rich notifications with contact avatars

