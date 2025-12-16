# Contact Management Feature

## Overview
The Contact Management feature allows users to store and manage their personal contacts with comprehensive details. The feature follows the MV (Model-View) architecture pattern with SwiftData for persistence.

## Architecture

### Data Layer
- **SwiftData Storage**: All contacts are persisted using SwiftData with a `Contact` model
- **Model Container**: Configured in `warmnetApp.swift` with persistent storage

### Model
**`Contact.swift`** - Core data model containing:
- Basic Info: `name`, `phoneCountryCode`, `phoneNumber`, `reference`
- Advanced Info: `email`, `city`, `state`, `country`, `birthday`, `company`, `jobTitle`, `notes`
- Metadata: `id`, `createdAt`, `updatedAt`

**`CountryCode.swift`** - Static data structure for phone country codes

## Data Flow

```
┌─────────────────┐
│   HomeScreen    │
│  (View + Query) │
└────────┬────────┘
         │ @Query
         ▼
┌─────────────────┐
│  ModelContext   │
│   (SwiftData)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Contact Model  │
│  (Persistent)   │
└─────────────────┘
```

## Screens

### HomeScreen
- **Purpose**: Main contact list display
- **Features**:
  - Displays all contacts sorted by name
  - Search functionality across name, phone, and reference
  - Swipe-to-delete action
  - Empty state for first-time users
  - Floating "Add Contact" button

### AddContactSheet
- **Purpose**: Create new contacts
- **Features**:
  - Basic info section (always visible)
  - Advanced info section (expandable)
  - Country code picker for phone numbers
  - Birthday date picker
  - Notes text field
  - Real-time avatar preview

## Components (Views folder)

| Component | Purpose |
|-----------|---------|
| `AvatarView` | Displays contact initials with dynamic color |
| `ContactRow` | List row displaying contact summary |
| `FormTextField` | Styled text input with label |
| `PrimaryButton` | Main action button styling |

## Usage

### Adding a Contact
1. Tap "Add Contact" button on HomeScreen
2. Fill in required name field
3. Optionally add phone number with country code
4. Add reference to remember context
5. Expand "Advanced Details" for more fields
6. Tap "Save" to persist

### Deleting a Contact
1. On HomeScreen, swipe left on any contact
2. Tap "Delete" to remove

## Build Target
- **iOS 26+**
- Uses latest SwiftUI components and modifiers
- SwiftData for persistence (no CoreData)

