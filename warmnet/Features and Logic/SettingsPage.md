# Settings Page

## Overview
The Settings Page serves as the central hub for user configuration, legal information, and application debugging. It is accessed via the profile icon in the top-right corner of the Home screen.

## Features

### 1. Profile Management
- **Profile Header**: Displays user avatar, name, and email.
- **Manage Profile**: Dedicated screen (`ProfileEditScreen`) to edit personal details.
  - Currently uses dummy data for UI visualization.

### 2. Customisation
- **Appearance**: Dedicated screen (`AppearanceScreen`) to toggle between Light, Dark, and System themes.

### 3. Support & Legal
- **Report a Bug**: Screen (`ReportBugScreen`) for user feedback.
- **Manage Subscription**: Screen (`SubscriptionScreen`) for premium features.
- **Privacy Policy**: View (`PrivacyPolicyView`) outlining data handling practices.

### 4. Testing & Debugging
Consolidates developer tools and testing functions:
- **Test Contact Input**: Launches the contact import flow.
- **Reminder System Debug**: Opens the reminder queue debugger.
- **Test Onboarding**: Resets the `hasCompletedOnboarding` flag and restarts the app.
- **Reset All Data**: Wipes all `Contact` data from the local database.

## Architecture

### Folder Structure
- `Screens/Settings/`: Contains all settings-related screens.
  - `SettingsScreen.swift`: Main entry point.
  - `ProfileEditScreen.swift`
  - `AppearanceScreen.swift`
  - `NotificationsSettingsScreen.swift`
  - `ReportBugScreen.swift`
  - `SubscriptionScreen.swift`
  - `PrivacyPolicyView.swift`

### View Structure
- **Container**: `NavigationStack` wrapping a `List`.
- **Sections**:
  1. **Profile Header**: Custom view with avatar and text.
  2. **Manage Profile**: Navigation link.
  3. **Customise Experience**: Navigation link.
  4. **Notifications**: Navigation link.
  5. **Support & Legal**: Navigation links.
  6. **Testing & Debug**: Action buttons.

### Data Flow
- **Profile Data**: Currently using dummy data strings. Future integration with `PersonalisationData` or a dedicated `UserProfile` model is planned.
- **Theme**: Uses `@AppStorage("userTheme")` to persist theme preference.

## Future Improvements
- Connect Profile UI to real `PersonalisationData` or `UserProfile` model.
- Implement actual logic for Notifications, Bug Reporting, and Subscriptions.
