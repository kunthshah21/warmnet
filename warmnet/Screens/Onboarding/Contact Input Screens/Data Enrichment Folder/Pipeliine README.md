# Contact Enrichment Pipeline

This module manages the "Contact Enrichment" flow, which is responsible for importing contacts from the device and adding essential metadata used by Warmnet's core features (Map, Reminders, and Relationship KPI).

## Overview

The pipeline allows users to:
1.  **Select Contacts**: Import from the device address book.
2.  **Assign Priority**: Categorize contacts into *Inner Circle*, *Key Relationships*, or *Broader Network*.
3.  **Add Location**: Assign City/State/Country for the Map view.

## Access Points

This pipeline handles two distinct use cases with shared logic:

### 1. Onboarding Flow (First Launch)
-   **Trigger**: Automatically starts after the Welcome screens.
-   **Constraints**: Requires selecting **at least 3 contacts**.
-   **Styling**: Enforces a **Strict White Theme** (Light Mode) regardless of system settings to match the onboarding aesthetic.
-   **Navigation**: Linear flow that ends with the Home Screen.

### 2. Main App (Add Contacts)
-   **Trigger**: `ContactsScreen` (Tab Bar) -> Top Right `+` Button -> **Add from Contacts**.
-   **Constraints**: Minimum **1 contact** required.
-   **Styling**: **Dynamic System Theme**. Respects the user's Light/Dark mode settings (uses `Color(uiColor: .systemBackground)` and `.primary`).
-   **Navigation**: Presented as a sheet; dismisses back to the Contacts list upon completion.

## Architecture & Data Flow

The flow is built on a chain of SwiftUI views that pass state forward. The key control mechanism is the `isOnboarding: Bool` flag passed into every view.

### Control Flag: `isOnboarding`

| Property | `isOnboarding: true` | `isOnboarding: false` |
| :--- | :--- | :--- |
| **Background** | `Color.white` | `.systemBackground` |
| **Text Color** | `.black` (Hardcoded) | `.primary` (Dynamic) |
| **Min Selection** | 3 Contacts | 1 Contact |
| **Navigation Bar** | White/Light scheme | Standard System scheme |

### File Breakdown

*   **`ContactSelectScreen.swift`**:
    *   The entry point. Handles permission requests and CNContact fetching.
    *   Filters out contacts already in the database (shows them as greyed out with a checkmark).
*   **`EnrichInfoScreen.swift`**:
    *   Informational landing page explaining why data is needed.
*   **`PriorityEnrichmentScreen.swift`**:
    *   List view allowing users to tap Priority buttons (Green/Blue/Yellow).
    *   Auto-advances or allows distinct selection.
*   **`LocationEnrichmentScreen.swift`**:
    *   Matches contacts to locations. Sorts "Needs Location" to the top.
    *   Uses a sheet to input City/State data.

## Developer Notes

*   **Reusability**: Do not duplicate these views for separate flows. Always use the `isOnboarding` flag to handle divergence in behavior or style.
*   **Testing**:
    *   **Onboarding**: Validated by resetting the app container.
    *   **App Mode**: Validated by toggling Dark Mode in Simulator while in the "Add from Contacts" sheet.
*   **SwiftData**: The pipeline commits changes directly to the `modelContext`. Ensure `onFlowComplete` callbacks are handled to properly dismiss the navigation stack.
