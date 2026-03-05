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

### 3. Advanced
- **Scoring & Priorities**: Dedicated screen (`AdvancedScoringScreen`) for power users to customize:
  - Per-tier contact frequency multipliers
  - Per-tier queue priority weight multipliers
  - Global scoring sensitivity (forgiving to strict)
  - Decay speed (slow to fast)
  - Health boost strength (off to aggressive)
  - Daily queue size

For detailed documentation, see **Features and Logic/AdvancedScoring_Spec.md**.

### 4. Support & Legal
- **Report a Bug**: Screen (`ReportBugScreen`) for user feedback.
- **Manage Subscription**: Screen (`SubscriptionScreen`) for premium features.
- **Privacy Policy**: View (`PrivacyPolicyView`) outlining data handling practices.

### 5. Testing & Debugging
Consolidates developer tools and testing functions:
- **Test Location Notifications**: Opens comprehensive location notification testing interface (`LocationNotificationTestScreen`)
  - System status verification
  - Permission management
  - Individual city testing
  - Random city testing
  - System diagnostics
- **Test Contact Input**: Launches the contact import flow.
- **Reminder System Debug**: Opens the reminder queue debugger.
- **Test Onboarding**: Resets the `hasCompletedOnboarding` flag and restarts the app.
- **Reset All Data**: Wipes all `Contact` data from the local database.

For detailed testing documentation, see **TestingFeatures.md**.

## Architecture

### Folder Structure
- `Screens/Settings/`: Contains all settings-related screens.
  - `SettingsScreen.swift`: Main entry point.
  - `ProfileEditScreen.swift`
  - `AppearanceScreen.swift`
  - `AdvancedScoringScreen.swift`: Advanced scoring and priority customization.
  - `NotificationsSettingsScreen.swift`
  - `ReportBugScreen.swift`
  - `SubscriptionScreen.swift`
  - `PrivacyPolicyView.swift`
- `Screens/`: Contains testing screens.
  - `LocationNotificationTestScreen.swift`: Location notification testing interface.
  - `TestingScreen.swift`: Consolidated testing tools (if accessible).

### View Structure
- **Container**: `NavigationStack` wrapping a `List`.
- **Sections**:
  1. **Profile Header**: Custom view with avatar and text.
  2. **Manage Profile**: Navigation link.
  3. **Customise Experience**: Navigation link.
  4. **Advanced**: Navigation link to advanced scoring settings.
  5. **Notifications**: Navigation link.
  6. **Support & Legal**: Navigation links.
  7. **Testing & Debug**: Action buttons.

### Data Flow
- **Profile Data**: Currently using dummy data strings. Future integration with `PersonalisationData` or a dedicated `UserProfile` model is planned.
- **Theme**: Uses `@AppStorage("userTheme")` to persist theme preference.

## Future Improvements
- Connect Profile UI to real `PersonalisationData` or `UserProfile` model.
- Implement actual logic for Notifications, Bug Reporting, and Subscriptions.
