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
