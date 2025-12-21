# Contact Management Feature

## Overview
The Contact Management feature allows users to store and manage their personal contacts with comprehensive details. The feature follows the MV (Model-View) architecture pattern with SwiftData for persistence.

## Contact Import Feature

### Overview
The contact import feature enables users to bulk-import contacts from their device's contact list directly into the app. This streamlines the onboarding process and allows users to quickly populate their contact database.

### Import Flow

1. **Testing Screen** → Navigate from TestingScreen by tapping "Test Contact Input"
2. **Import Contacts Screen** → Request device contacts permission
3. **Contact Select Screen** → Select minimum 3 contacts to import
4. **Automatic Sync** → Selected contacts are converted and saved to SwiftData

### Screens

**ImportContactsScreen**
- Displays permission request UI with informative text about privacy
- Shows visual placeholder for contact import
- Triggers iOS system permission dialog
- Navigates to ContactSelectScreen upon permission grant
- Shows error alert if permission denied

**ContactSelectScreen**
- Loads all device contacts with full contact details
- Displays contacts in scrollable list with search functionality
- Shows contact avatar (photo or initials), name, and phone number
- Multi-select interface with checkboxes
- Enforces minimum selection of 3 contacts
- Real-time selection counter with validation
- "Clear All" button to reset selections
- Converts selected device contacts to app Contact model
- Saves all imported contacts to SwiftData in batch
- Automatically dismisses upon successful import

### Data Conversion

Device contacts (CNContact) are converted to app Contact model with mapping:
- `givenName` + `familyName` → `name`
- First phone number → `phoneNumber` + `phoneCountryCode`
- First email → `email`
- Postal address → `city`, `state`, `country`
- Birthday components → `birthday`
- Organization → `company`
- Job title → `jobTitle`
- Notes → `notes`

### Technical Details
- Uses Contacts framework (`CNContactStore`)
- Requests all contact keys for complete data extraction
- Loads contacts asynchronously to avoid UI blocking
- Batch inserts into SwiftData for performance
- Validates minimum selection before enabling import button
- Shows loading states during contact fetch and import operations

### Required Permissions
- `NSContactsUsageDescription` in Info.plist

### User Flow Diagram

```
┌─────────────────┐
│ TestingScreen   │
│  (Button Tap)   │
└────────┬────────┘
         │
         ▼
┌─────────────────────────┐
│ ImportContactsScreen    │
│ (Request Permission)    │
└────────┬────────────────┘
         │
         ▼ (Granted)
┌─────────────────────────┐
│ ContactSelectScreen     │
│ (Select ≥ 3 contacts)   │
└────────┬────────────────┘
         │
         ▼ (Import)
┌─────────────────────────┐
│   CNContact → Contact   │
│   (Data Conversion)     │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│   SwiftData Save        │
│  (Batch Insert)         │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│  ContactsScreen         │
│ (Auto-populated list)   │
└─────────────────────────┘
```

## Navigation

The app uses a bottom tab bar with three main sections:
- **Home**: Welcome screen with quick add contact button
- **Contacts**: Full contact list with search and management
- **Map**: Visual map showing contact locations with filtering

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

**`ContactLocationService.swift`** - Contact location caching service:
- Batch geocodes all contact locations
- Caches coordinates to avoid repeated geocoding
- Provides filter options (cities, states, countries)
- Calculates map regions for filtered views

**`ContactAnnotation.swift`** - Map annotation model:
- Conforms to `MKAnnotation` protocol
- Represents contact pins on the map
- Supports clustering for nearby contacts

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

### Map View Flow

```
┌─────────────────────┐
│     MapScreen       │
│  (@Query contacts)  │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│ ContactLocationService │
│  (Geocode & Cache)  │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│  ContactAnnotation  │
│     (Map Pins)      │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│    MapKit View      │
│  (Clustered Pins)   │
└─────────────────────┘
          ▲
          │
┌─────────┴───────────┐
│   MapFilterBar      │
│ (City/State/Country)│
└─────────────────────┘
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

### ContactsScreen
- **Purpose**: Full contact management
- **Features**:
  - Complete contact list
  - Search and filter
  - Contact details view

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

### ImportContactsScreen
- **Purpose**: Request device contacts permission
- **Location**: `Screens/Contact Input Screens/`
- **Features**:
  - Privacy-focused permission request UI
  - Visual contact import placeholder
  - Triggers iOS system permission dialog
  - Error handling for denied permissions
  - Automatic navigation to ContactSelectScreen on grant

### ContactSelectScreen
- **Purpose**: Bulk import contacts from device
- **Location**: `Screens/Contact Input Screens/`
- **Features**:
  - Loads all device contacts asynchronously
  - Search functionality across names and phone numbers
  - Multi-select with checkbox interface
  - Minimum 3 contact validation
  - Selection counter and "Clear All" button
  - Batch import to SwiftData
  - Loading and empty states

### MapScreen
- **Purpose**: Visual map of contact locations
- **Features**:
  - Interactive MapKit map with pinch/zoom
  - Contact pins with name tooltips
  - Clustered pins for nearby contacts
  - Filter bar for City/State/Country filtering
  - Animated zoom-to-location on filter selection
  - Loading indicator during geocoding
  - Empty state for no contacts

## Components (Views folder)

| Component | Purpose |
|-----------|---------|
| `AvatarView` | Displays contact initials with dynamic color |
| `ContactRow` | List row displaying contact summary |
| `DeviceContactRow` | Selectable contact row for import with checkbox and device contact data |
| `FormTextField` | Styled text input with label |
| `PrimaryButton` | Main action button styling |
| `LocationInputView` | Smart location input with autocomplete and current location support |
| `MapFilterBar` | Filter controls for map (All/City/State/Country) |

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

## Map Feature

### Overview
The map view provides a visual representation of where contacts are located, with filtering and navigation capabilities.

### Features

1. **Interactive Map**:
   - Full MapKit integration with standard gestures
   - Pinch to zoom, pan to navigate
   - Map controls (compass, scale, user location)

2. **Contact Pins**:
   - Each contact with location shows as a pin
   - Pin displays contact initial in a blue bubble
   - Tap pin to see contact name tooltip
   - Nearby pins cluster with count badge

3. **Filtering**:
   - Filter by All, City, State, or Country
   - Dynamic filter options from contact data
   - Animated zoom to filtered location
   - "All" option resets to show all contacts

### User Flow

1. Navigate to Map tab
2. App geocodes all contacts (shows loading progress)
3. Pins appear on map at contact locations
4. Use filter bar to narrow by location type
5. Select specific city/state/country to zoom
6. Tap pins to see contact names

### Technical Notes

- Geocoding is rate-limited to avoid API throttling
- Coordinates are cached to avoid repeated geocoding
- Map region auto-adjusts to fit visible pins
- Zoom level varies by filter type (city=close, country=far)

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

### Using the Map
1. Navigate to Map tab
2. Wait for contacts to load (shows progress)
3. Pinch/zoom to explore
4. Use filter bar to focus on specific locations
5. Tap pins to see contact names

## Build Target
- **iOS 26+**
- Uses latest SwiftUI components and modifiers
- SwiftData for persistence (no CoreData)
- CoreLocation for device location
- MapKit for geocoding, autocomplete, and map display
