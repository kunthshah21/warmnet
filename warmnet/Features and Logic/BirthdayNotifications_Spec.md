# Birthday Notification System
Rhis is a part of the overall notification system of the app

## Overview

The Birthday Notification System ensures users never miss a contact's birthday. It uses a dual-notification strategy to provide advance notice for planning and a timely remainder on the day itself.

## Architecture

### Components

1.  **NotificationManager** (`NotificationManager.swift`)
    *   **Role**: variable logic for creating and scheduling `UNNotificationRequest`.
    *   **Category**: Uses `BIRTHDAY_REMINDER` category.
    *   **Triggers**: Uses `UNCalendarNotificationTrigger` for recurring annual events.

2.  **BirthdayNotificationService** (`BirthdayNotificationService.swift`)
    *   **Role**: High-level service acting as the bridge between data models and the notification manager.
    *   **Responsibility**: Scans contacts and schedules notifications in batches.

3.  **Contact Model** (`Contact.swift`)
    *   **Data**: Uses the `birthday: Date?` property.
    *   **Logic**: Notifications are only scheduled if this property is non-nil.

4.  **NotificationContentProvider** (`NotificationContentProvider.swift`)
    *   **Role**: Centralized factory for notification text.
    *   **Responsibility**: Defines the copy for "Upcoming" and "Day Of" alerts to ensure consistency across scheduling and testing.

## Notification Logic

The system schedules **two** distinct notifications for every contact with a birthday:

### 1. The "Upcoming" Notification
*   **Timing**: 7 days before the birthday at 9:00 AM.
*   **Purpose**: Giving the user time to buy a gift or plan an event.
*   **Content**: "Upcoming Birthday: [Name] - [Name]'s birthday is in one week. Plan something special!"
*   **Repeat**: recurring annually.
*   **Calculation**: `Birthday Date - 7 Days`. Adjusted for leap years.

### 2. The "Day Of" Notification
*   **Timing**: On the birthday date at 12:00 AM (Midnight).
*   **Purpose**: Immediate reminder to send a wish.
*   **Content**: "Happy Birthday [Name]! 🎂 - It's [Name]'s birthday today. Don't forget to wish them!"
*   **Repeat**: Recurring annually.

## Data Flow

1.  User adds/edits a contact with a birthday.
2.  (Future Implementation) `save` action calls `BirthdayNotificationService.schedule(contact:)`.
3.  Currently, scheduling can be triggered manually via settings or batch updates.
4.  `NotificationManager` creates `UNCalendarNotificationTrigger` components.
5.  System handles delivery.

## Testing

A dedicated testing screen is available in **Settings > Testing & Debug > Test Birthday Notifications**.

### Capabilities
1.  **Permission Check**: Verifies notification permissions.
2.  **Simulate "Day Of"**: Triggers an immediate (5s delay) notification mimicking the "Day Of" alert.
3.  **Simulate "Week Before"**: Triggers an immediate (5s delay) notification mimicking the "Upcoming" alert.
4.  **Schedule All**: Iterates through all contacts and registers the real calendar triggers for device testing.
