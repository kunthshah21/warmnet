# Settings Page

## Overview
The Settings Page serves as the central hub for user configuration, legal information, and application debugging. It is accessed via the profile icon in the top-right corner of the Home screen.

## Features

### 1. Personal Information Management
Users can view and update their personalisation profile directly from the settings.
- **Data Source**: `PersonalisationData` model (SwiftData).
- **Editable Fields**:
  - Relationship Goal
  - Network Size
  - Communication Style
- **Behavior**: Changes are automatically saved to the local database via SwiftData bindings.

### 2. Legal & Privacy
- **Privacy Policy**: A dedicated view (`PrivacyPolicyView`) outlining data handling practices.
- **Key Privacy Principles**:
  - Local-first architecture.
  - No external server transmission.
  - User ownership of data.

### 3. Testing & Debugging
Consolidates developer tools and testing functions:
- **Test Contact Input**: Launches the contact import flow.
- **Reminder System Debug**: Opens the reminder queue debugger.
- **Test Onboarding**: Resets the `hasCompletedOnboarding` flag and restarts the app.
- **Reset All Data**: Wipes all `Contact` data from the local database.

## Architecture

### View Structure
- **Container**: `NavigationStack` wrapping a `List`.
- **Sections**:
  1. **Personal Information**: Uses `Picker` components bound to the `PersonalisationData` model.
  2. **Legal**: Navigation links to static information views.
  3. **Testing & Debug**: Action buttons for developer tools.

### Data Flow
- **Read**: Uses `@Query` to fetch the `PersonalisationData` object.
- **Write**: Uses direct bindings to the model properties. SwiftData handles the persistence automatically when the view updates.
- **Actions**: Uses `@Environment(\.modelContext)` for destructive actions like deleting data.

## Future Improvements
- Add "Export Data" functionality.
- Add "Import Data" functionality.
- Add app-wide appearance settings (Dark/Light mode toggle).
