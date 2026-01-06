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
- **Test Contact Input**: Launches the contact import flow
- **Reminder System Debug**: Opens the reminder queue debugger
- **Test Onboarding**: Resets onboarding state and restarts the app
- **Reset All Data**: Wipes all contact data from the database

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
   - Notification should appear within 1 second
   - Check notification center if not visible

3. **Test Random City**:
   - Tap "Test Random City" in Actions section
   - System randomly selects a monitored city
   - Notification triggers automatically

4. **System Verification**:
   - Tap "Test All Systems"
   - Review feedback for any configuration issues
   - Address any reported problems

#### Technical Implementation

##### Key Methods

**LocationNotificationService.simulateRegionEntry(city:)**
```swift
func simulateRegionEntry(city: String) {
    // Finds monitored city by name
    // Triggers processRegionEntry() asynchronously
    // Bypasses actual geofencing for testing
}
```

**Notification Flow**
```
User taps "Test" → simulateRegionEntry() 
    → processRegionEntry() 
    → Checks settings & cooldown 
    → Fetches contacts in city 
    → NotificationManager.scheduleLocationNotification() 
    → Notification appears
```

##### State Management
- Uses `@State` for UI state (alerts, navigation)
- Observes `LocationNotificationService.shared` for real-time updates
- Observes `NotificationManager.shared` for permission status
- Queries `UserSettings` from SwiftData context

#### Error Handling

The test screen provides clear feedback for common issues:
- **Permission Denied**: Guides user to Settings
- **Notifications Disabled**: Provides enable button
- **No Monitored Cities**: Explains how to add contacts with city data
- **System Not Ready**: Lists all missing prerequisites

#### Console Logging

The test screen leverages existing logging in:
- `LocationNotificationService`: Region entry, geofence setup
- `NotificationManager`: Notification scheduling, permission status
- `NotificationHistory`: Cooldown checks, history recording

## Testing Screen

### Overview
A dedicated testing interface (`TestingScreen.swift`) that consolidates various testing tools.

### Features
- **Test Contact Input**: Import contacts flow
- **Reminder System Debug**: Reminder queue debugging
- **Test Location Notifications**: Location notification testing
- **Test Onboarding**: Reset onboarding state
- **Reset All Data**: Clear all contact data

### Navigation
- Accessible via navigation destination from Settings
- Uses `NavigationStack` with destination bindings
- Provides clean, organized testing interface

## Testing Scenarios

### Location Notification Testing

#### Scenario 1: Basic Notification Test
1. Ensure prerequisites are met
2. Select a monitored city
3. Tap "Test" button
4. Verify notification appears
5. Check notification content (title, body, actions)

#### Scenario 2: Permission Testing
1. Revoke location permission
2. Open test screen
3. Verify status shows "Not Ready"
4. Request permission via button
5. Verify status updates

#### Scenario 3: Settings Validation
1. Disable location notifications
2. Open test screen
3. Verify "System Not Ready" status
4. Enable via button
5. Verify status updates

#### Scenario 4: Cooldown Testing
1. Trigger notification for a city
2. Immediately trigger again
3. Verify cooldown prevents second notification
4. Check notification history

#### Scenario 5: Quiet Hours Testing
1. Enable quiet hours
2. Set current time within quiet hours
3. Attempt to trigger notification
4. Verify notification is suppressed
5. Check console logs for suppression message

#### Scenario 6: Multiple Cities
1. Add contacts in multiple cities
2. Verify cities appear in monitored list
3. Test each city individually
4. Verify notifications work for all

#### Scenario 7: Empty State
1. Remove all contacts with city data
2. Verify empty state message appears
3. Verify helpful instructions are shown

## Limitations

### Simulator Testing
- **Geofencing**: Cannot be tested in iOS Simulator
- **Real Location**: Requires physical device for actual geofencing
- **Solution**: Use `simulateRegionEntry()` method for testing

### Background Testing
- Notifications triggered via simulation work in foreground
- Real geofencing works in background (requires device testing)
- App termination: Real geofencing delivers notifications even when app is killed

## Best Practices

### For Developers
1. **Always test on physical device** for real geofencing behavior
2. **Use test screen** for rapid iteration during development
3. **Check console logs** for detailed debugging information
4. **Verify permissions** before testing notification flow
5. **Test edge cases**: Empty states, permission denied, cooldowns

### For Testers
1. **Start with "Test All Systems"** to verify configuration
2. **Test individual cities** to verify notification content
3. **Test permission flows** to ensure proper user guidance
4. **Test settings changes** to verify real-time updates
5. **Test error states** to verify graceful degradation

## Future Enhancements

- [ ] Add notification history viewer in test screen
- [ ] Add ability to clear notification history for testing
- [ ] Add ability to bypass cooldown for testing
- [ ] Add ability to test quiet hours without changing system time
- [ ] Add notification preview before sending
- [ ] Add batch testing (test all cities at once)
- [ ] Add test result logging/export
- [ ] Add automated test scenarios

## Related Documentation

- **LocationNotifications.md**: Complete location notification system documentation
- **SettingsPage.md**: Settings screen structure and features
- **ReminderSystem.md**: Reminder system architecture (for reminder debug tools)

## Architecture

### File Structure
```
warmnet/Screens/
├── LocationNotificationTestScreen.swift  # Main testing interface
├── TestingScreen.swift                   # Consolidated testing tools
└── Settings/
    └── SettingsScreen.swift              # Access point for testing
```

### Dependencies
- `LocationNotificationService`: Core geofencing service
- `NotificationManager`: Notification scheduling and permissions
- `UserSettings`: User preferences and configuration
- `NotificationHistory`: Notification tracking and cooldown management
- `ContactLocationMatcher`: City prioritization and geocoding

### Data Flow
```
User Action (Test Button)
    ↓
LocationNotificationTestScreen.testNotification()
    ↓
LocationNotificationService.simulateRegionEntry()
    ↓
LocationNotificationService.processRegionEntry()
    ↓
Checks: Settings, Quiet Hours, Cooldown
    ↓
Fetches Contacts in City
    ↓
NotificationManager.scheduleLocationNotification()
    ↓
Notification Appears
```

