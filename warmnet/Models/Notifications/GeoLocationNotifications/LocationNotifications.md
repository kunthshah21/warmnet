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
| `NotificationContentProvider` | Centralized factory for generating notification strings (Title & Body) |

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
NotificationContentProvider.content(for: .locationEntry)
    ↓
NotificationManager.scheduleLocationNotification()
    ↓
NotificationHistory.record() (save to history)
```
