# Testing Features

## Overview

The Testing Features provide comprehensive tools for developers and testers to verify application functionality, debug issues, and test critical features like location-based notifications without requiring physical travel or complex setup.

## Access Points

### Primary Access
- **Settings Screen** → "Testing & Debug" section → "Test Location Notifications"
- **Testing Screen** → "Test Location Notifications" button (if accessible)

### Settings Screen Integration
The Settings Screen (`SettingsScreen.swift`) includes a "Testing & Debug" section with the following options:
- **Test Location Notifications**: Opens the location notification testing interface
- **Test Birthday Notifications**: Opens the birthday notification testing interface
- **Test Contact Input**: Launches the contact import flow
- **Reminder System Debug**: Opens the reminder queue debugger
- **Test Onboarding**: Resets onboarding state and restarts the app
- **Reset All Data**: Wipes all contact data from the database

## Birthday Notification Testing

### BirthdayNotificationTestScreen

A dedicated interface for verifying the birthday reminder system.

#### Purpose
Allows developers to simulate birthday alerts immediately without waiting for specific dates, and to verify permission states.

#### Features
1.  **Status Checks**: Verifies if notifications are authorized.
2.  **Simulation - Day Of**: Schedules a test notification to fire in 5 seconds with the "Happy Birthday" copy.
3.  **Simulation - Week Before**: Schedules a test notification to fire in 5 seconds with the "Upcoming Birthday" copy.
4.  **Schedule All**: Batch processes all contacts in the database and registers their real `UNCalendarNotificationTrigger` events.

## Location Notification Testing

### LocationNotificationTestScreen

A comprehensive testing interface for verifying location-based push notification functionality.

#### Purpose
Enables testing of geo-location push notifications without requiring physical travel to different cities. Uses the `simulateRegionEntry(city:)` method to trigger notifications programmatically.

#### Features

##### 1. System Status Section
- **System Ready Indicator**: Shows overall readiness status
  - Checks location permission ("Always" required)
  - Checks notification permission
  - Verifies location notifications are enabled
  - Confirms at least one city is monitored
- **Test Result Display**: Shows feedback from test operations

##### 2. Permissions Section
- **Location Access Status**: 
  - Displays current authorization status
  - Shows badge (green for "Always", orange for other states)
  - Provides button to request permissions if needed
- **Notification Permission Status**:
  - Displays authorization status
  - Shows badge (green for authorized, orange for denied)
  - Provides button to request permissions if needed

##### 3. Settings Check Section
- **Location Notifications Enabled**: Toggle status indicator
- **Enable Button**: Quick access to enable notifications if disabled
- **Notification Cooldown**: Displays current cooldown setting
- **Quiet Hours**: Shows if quiet hours are active

##### 4. Monitored Cities Section
- **City List**: Displays all cities currently being monitored
  - Shows city name, state, and country
  - Displays contact count per city
  - **Test Button**: Individual test button for each city
- **Refresh Button**: Manually refresh the monitored cities list
- **Status Indicators**:
  - Loading state during geofence setup
  - Empty state with helpful message
  - Count display (X/20 cities)

##### 5. Test Actions Section
- **Test All Systems**: Comprehensive system check
  - Verifies all prerequisites
  - Provides detailed feedback on issues
- **Test Random City**: Randomly selects a monitored city and triggers notification
- **Open Notification Settings**: Quick navigation to notification configuration

#### Testing Workflow

1. **Prerequisites Check**:
   - Ensure location permission is set to "Always"
   - Ensure notification permission is granted
   - Enable location notifications in settings
   - Verify at least one city is monitored (add contacts with city data)

2. **Test Individual City**:
   - Navigate to "Monitored Cities" section
   - Tap "Test" button next to desired city
