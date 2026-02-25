# Warmnet

A personal relationship management app for iOS that helps you stay connected with the people who matter most. Built entirely with Apple-first technologies.

## What is Warmnet?

Warmnet organizes your relationships into three tiers — **Inner Circle**, **Key Relationships**, and **Broader Network** — and uses smart reminders, location awareness, and on-device AI to help you nurture every connection at the right cadence.

### Core Features

- **Smart Reminder System** — Tiered contact scheduling with urgency-based prioritization and configurable windows per relationship tier
- **AI Insights** — On-device AI coaching powered by Apple Foundation Models (iOS 26+) with contextual networking advice and a conversational chat interface
- **Location Intelligence** — Geofence-based notifications when you're near contacts, powered by CoreLocation region monitoring
- **Birthday Notifications** — Automatic birthday reminders so you never miss an important date
- **Network Progress Tracking** — Visual progress rings and weekly trend charts showing your networking health across all tiers
- **Interactive Map** — Clustered map view of your contacts with filtering by relationship tier
- **Contact Enrichment** — Guided onboarding pipeline for importing, prioritizing, and enriching contacts from your address book
- **AI Writing Assistant** — Contextual message drafting with tone and intent customization

## Tech Stack

| Technology | Purpose |
|---|---|
| **SwiftUI** | Declarative UI with iOS 26+ components |
| **SwiftData** | Local persistence for contacts, interactions, and settings |
| **Foundation Models** | On-device AI insights and chat (iOS 26+) |
| **CoreLocation** | Geofencing and location-based notifications |
| **MapKit** | Interactive clustered contact map |
| **UserNotifications** | Reminder scheduling and birthday alerts |

## Architecture

Warmnet follows the **Model-View (MV)** architecture pattern:

- **Models** — SwiftData models (`Contact`, `Interaction`, `Milestone`, `UserSettings`) and service layers
- **Views** — Reusable SwiftUI components (cards, buttons, form fields)
- **Screens** — Full-screen views composed from reusable components

All data is stored **locally on-device** using SwiftData. No data is transmitted to external servers.

## Project Structure

```
warmnet/
├── Models/
│   ├── AI/                     # AI context, prompts, conversation management
│   ├── Notifications/          # Birthday and geolocation notification services
│   ├── ReminderSystem/         # Tiered reminder scheduling and urgency calculation
│   ├── Contact.swift           # Core contact model
│   ├── Interaction.swift       # Interaction logging model
│   └── ...
├── Screens/
│   ├── Onboarding/             # Multi-step onboarding and enrichment flow
│   ├── Settings/               # Settings, profile, appearance, privacy
│   ├── ReminderDebug/          # Debug views for reminder queue inspection
│   ├── HomeScreen.swift        # Main dashboard
│   ├── ContactsScreen.swift    # Contact list with A-Z index
│   ├── InsightsScreen.swift    # AI insights and analytics
│   ├── MapScreen.swift         # Contact map view
│   └── ...
├── Views/                      # Reusable UI components
├── DesignSystem/               # Typography and design tokens
├── Features and Logic/         # Feature specification documents
└── warmnetApp.swift            # App entry point
```

## Requirements

- **iOS 26.0+**
- **Xcode 26.0+**
- **Swift 6.0+**

AI features require iOS 26+ with Foundation Models support. On older versions, the app provides contextual fallback responses.

## Getting Started

1. Clone the repository
   ```bash
   git clone https://github.com/your-username/warmnet.git
   ```
2. Open `warmnet.xcodeproj` in Xcode 26+
3. Select a simulator or device running iOS 26+
4. Build and run

No external dependencies or API keys required — everything runs on-device.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
