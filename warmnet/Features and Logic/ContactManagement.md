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

**`LocationManager.swift`** - CoreLocation wrapper for device location services:
- Manages location permission requests
- Provides approximate location (city/state level accuracy)
- Handles authorization state changes

**`GeocodingService.swift`** - MapKit geocoding service:
- Autocomplete suggestions using `MKLocalSearchCompleter`
- Forward geocoding (text to location) using `CLGeocoder`
- Reverse geocoding (coordinates to address) using `CLGeocoder`
- Parses results into City, State, Country components

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

### Location Input Flow

```
┌─────────────────────┐
│  LocationInputView  │
└─────────┬───────────┘
          │
    ┌─────┴─────┐
    ▼           ▼
┌────────┐  ┌──────────────┐
│ Manual │  │ Use Current  │
│ Input  │  │   Location   │
└────┬───┘  └──────┬───────┘
     │             │
     ▼             ▼
┌──────────┐  ┌─────────────┐
│ Geocoding │  │ Location    │
│ Service   │  │ Manager     │
└────┬──────┘  └──────┬──────┘
     │                │
     ▼                ▼
┌───────────────────────────┐
│   GeocodingService        │
│   (Reverse Geocode)       │
└────────────┬──────────────┘
             │
             ▼
┌───────────────────────────┐
│  LocationResult           │
│  (City, State, Country)   │
└───────────────────────────┘
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
  - Smart location input with autocomplete
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
| `LocationInputView` | Smart location input with autocomplete and current location support |

## Location Input Feature

### Overview
The location input provides a unified experience for entering contact locations with:
- Single text field instead of separate City/State/Country fields
- Real-time autocomplete suggestions from MapKit
- "Use Current Location" button for quick entry
- Validation with clear error messaging

### User Flow

1. **Manual Input**:
   - User types location text (e.g., "New York" or "San Francisco, CA")
   - Autocomplete suggestions appear below the input
   - User can select a suggestion or submit manually
   - On submit, location is geocoded and validated
   - If valid: City, State, Country are parsed and saved
   - If invalid: Error alert shown, user can retry

2. **Current Location**:
   - User taps "Use Current" button
   - If permission not determined: System prompts for permission
   - If authorized: Device location is fetched (approximate, city/state level)
   - Location is reverse geocoded to get City/State
   - Fields are auto-filled

### Error Handling

| Scenario | Behavior |
|----------|----------|
| Invalid location text | Show error: "Location not found. Please check spelling and try again." |
| Partial match (e.g., only state) | Fill available fields, leave others empty |
| Permission denied | Hide "Use Current" button, show manual input only |
| Network unavailable | Show error: "Unable to verify location. Please check your connection." |
| Location service unavailable | Show error: "Location service unavailable. Please enter manually." |

### Required Permissions

- `NSLocationWhenInUseUsageDescription` in Info.plist
- Uses approximate location accuracy (kCLLocationAccuracyKilometer)

## Usage

### Adding a Contact
1. Tap "Add Contact" button on HomeScreen
2. Fill in required name field
3. Optionally add phone number with country code
4. Add reference to remember context
5. Expand "Advanced Details" for more fields
6. For location: type to search or tap "Use Current" for auto-fill
7. Tap "Save" to persist

### Deleting a Contact
1. On HomeScreen, swipe left on any contact
2. Tap "Delete" to remove

## Build Target
- **iOS 26+**
- Uses latest SwiftUI components and modifiers
- SwiftData for persistence (no CoreData)
- CoreLocation for device location
- MapKit for geocoding and autocomplete
