//
//  NotificationsSettingsScreen.swift
//  warmnet
//
//  Settings screen for configuring location-based notifications.
//

import SwiftUI
import SwiftData

struct NotificationsSettingsScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var contacts: [Contact]
    
    @State private var settings: UserSettings?
    @State private var locationService = LocationNotificationService.shared
    @State private var notificationManager = NotificationManager.shared
    
    @State private var showPermissionAlert = false
    @State private var permissionAlertMessage = ""
    
    var body: some View {
        List {
            // MARK: - Permission Status
            permissionStatusSection
            
            // MARK: - Location Notifications Toggle
            if canShowNotificationSettings {
                locationNotificationsSection
            }
            
            // MARK: - Frequency Settings
            if settings?.locationNotificationsEnabled == true && canShowNotificationSettings {
                frequencySection
                quietHoursSection
            }
            
            // MARK: - Monitored Cities
            if settings?.locationNotificationsEnabled == true && canShowNotificationSettings {
                monitoredCitiesSection
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadSettings()
        }
        .alert("Permission Required", isPresented: $showPermissionAlert) {
            Button("Open Settings") {
                openAppSettings()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(permissionAlertMessage)
        }
    }
    
    // MARK: - Computed Properties
    
    private var canShowNotificationSettings: Bool {
        locationService.authorizationStatus.canUseGeofencing &&
        notificationManager.authorizationStatus.canSendNotifications
    }
    
    // MARK: - Permission Status Section
    
    private var permissionStatusSection: some View {
        Section {
            // Location Permission
            HStack {
                Label("Location Access", systemImage: "location.fill")
                Spacer()
                permissionBadge(for: locationService.authorizationStatus)
            }
            
            if locationService.authorizationStatus != .always {
                locationPermissionButton
            }
            
            // Notification Permission
            HStack {
                Label("Notifications", systemImage: "bell.fill")
                Spacer()
                notificationPermissionBadge
            }
            
            if !notificationManager.authorizationStatus.canSendNotifications {
                notificationPermissionButton
            }
        } header: {
            Text("Permissions")
        } footer: {
            if !canShowNotificationSettings {
                Text("Both \"Always\" location access and notification permissions are required for location-based reminders.")
            }
        }
    }
    
    private func permissionBadge(for status: LocationNotificationService.LocationAuthorizationStatus) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(status.canUseGeofencing ? Color.green : Color.orange)
                .frame(width: 8, height: 8)
            Text(status.displayText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var notificationPermissionBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(notificationManager.authorizationStatus.canSendNotifications ? Color.green : Color.orange)
                .frame(width: 8, height: 8)
            Text(notificationManager.authorizationStatus.canSendNotifications ? "Allowed" : "Not Allowed")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var locationPermissionButton: some View {
        Button {
            requestLocationPermission()
        } label: {
            HStack {
                Text(locationService.authorizationStatus == .notDetermined ? "Enable Location Access" : "Update Location Permission")
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var notificationPermissionButton: some View {
        Button {
            requestNotificationPermission()
        } label: {
            HStack {
                Text(notificationManager.authorizationStatus == .notDetermined ? "Enable Notifications" : "Update Notification Permission")
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - Location Notifications Section
    
    private var locationNotificationsSection: some View {
        Section {
            Toggle(isOn: Binding(
                get: { settings?.locationNotificationsEnabled ?? true },
                set: { newValue in
                    settings?.setLocationNotifications(enabled: newValue)
                    if newValue {
                        setupGeofencesIfNeeded()
                    } else {
                        locationService.stopAllMonitoring()
                    }
                }
            )) {
                Label("Location Reminders", systemImage: "location.circle")
            }
        } header: {
            Text("Location-Based Notifications")
        } footer: {
            Text("Get notified when you enter a city where your contacts live. Great for staying connected while traveling.")
        }
    }
    
    // MARK: - Frequency Section
    
    private var frequencySection: some View {
        Section {
            Picker("Notification Frequency", selection: Binding(
                get: { settings?.notificationCooldown ?? .daily },
                set: { newValue in
                    settings?.setNotificationCooldown(newValue)
                }
            )) {
                ForEach(NotificationCooldown.allCases, id: \.self) { cooldown in
                    Text(cooldown.displayName).tag(cooldown)
                }
            }
        } header: {
            Text("Frequency")
        } footer: {
            Text("How often you can receive notifications for the same location.")
        }
    }
    
    // MARK: - Quiet Hours Section
    
    private var quietHoursSection: some View {
        Section {
            Toggle(isOn: Binding(
                get: { settings?.quietHoursEnabled ?? false },
                set: { newValue in
                    settings?.setQuietHours(enabled: newValue)
                }
            )) {
                Label("Quiet Hours", systemImage: "moon.fill")
            }
            
            if settings?.quietHoursEnabled == true {
                HStack {
                    Text("From")
                    Spacer()
                    Picker("Start", selection: Binding(
                        get: { settings?.quietHoursStart ?? 22 },
                        set: { newValue in
                            settings?.setQuietHours(enabled: true, start: newValue)
                        }
                    )) {
                        ForEach(0..<24, id: \.self) { hour in
                            Text(formatHour(hour)).tag(hour)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                HStack {
                    Text("To")
                    Spacer()
                    Picker("End", selection: Binding(
                        get: { settings?.quietHoursEnd ?? 8 },
                        set: { newValue in
                            settings?.setQuietHours(enabled: true, end: newValue)
                        }
                    )) {
                        ForEach(0..<24, id: \.self) { hour in
                            Text(formatHour(hour)).tag(hour)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
        } header: {
            Text("Quiet Hours")
        } footer: {
            if settings?.quietHoursEnabled == true {
                Text("Notifications will be silenced between \(formatHour(settings?.quietHoursStart ?? 22)) and \(formatHour(settings?.quietHoursEnd ?? 8)).")
            } else {
                Text("Pause notifications during specific hours.")
            }
        }
    }
    
    // MARK: - Monitored Cities Section
    
    private var monitoredCitiesSection: some View {
        Section {
            if locationService.isSettingUpGeofences {
                HStack {
                    ProgressView()
                        .padding(.trailing, 8)
                    Text("Setting up location monitoring...")
                        .foregroundStyle(.secondary)
                }
            } else if locationService.monitoredCities.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("No cities monitored")
                        .foregroundStyle(.secondary)
                    Text("Add contacts with city information to enable location-based reminders.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 4)
            } else {
                ForEach(locationService.monitoredCities) { city in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(city.city)
                                .font(.body)
                            if !city.state.isEmpty || !city.country.isEmpty {
                                Text([city.state, city.country].filter { !$0.isEmpty }.joined(separator: ", "))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Text("\(city.contactCount) contact\(city.contactCount == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Button {
                setupGeofencesIfNeeded()
            } label: {
                Label("Refresh Monitored Cities", systemImage: "arrow.clockwise")
            }
            .disabled(locationService.isSettingUpGeofences)
        } header: {
            HStack {
                Text("Monitored Cities")
                Spacer()
                Text("\(locationService.monitoredCities.count)/20")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } footer: {
            Text("Cities are prioritized by contact importance. iOS allows monitoring up to 20 locations.")
        }
    }
    
    // MARK: - Actions
    
    private func loadSettings() {
        settings = UserSettings.getOrCreate(from: modelContext)
        
        Task {
            await notificationManager.refreshAuthorizationStatus()
        }
    }
    
    private func requestLocationPermission() {
        switch locationService.authorizationStatus {
        case .notDetermined:
            // First request "When In Use"
            locationService.requestWhenInUseAuthorization()
            // Then request "Always" after a brief delay
            Task {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if locationService.authorizationStatus == .whenInUse {
                    locationService.requestAlwaysAuthorization()
                }
            }
        case .whenInUse:
            locationService.requestAlwaysAuthorization()
        case .denied:
            permissionAlertMessage = "Location access was denied. Please enable \"Always\" location access in Settings to receive location-based reminders."
            showPermissionAlert = true
        case .always:
            break
        }
    }
    
    private func requestNotificationPermission() {
        switch notificationManager.authorizationStatus {
        case .notDetermined:
            Task {
                await notificationManager.requestPermission()
            }
        case .denied:
            permissionAlertMessage = "Notifications were denied. Please enable notifications in Settings to receive location-based reminders."
            showPermissionAlert = true
        default:
            break
        }
    }
    
    private func setupGeofencesIfNeeded() {
        Task {
            await locationService.setupGeofences(for: contacts)
        }
    }
    
    private func openAppSettings() {
        notificationManager.openSettings()
    }
    
    // MARK: - Helpers
    
    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        
        var components = DateComponents()
        components.hour = hour
        
        if let date = Calendar.current.date(from: components) {
            return formatter.string(from: date)
        }
        return "\(hour):00"
    }
}

#Preview {
    NavigationStack {
        NotificationsSettingsScreen()
    }
    .modelContainer(for: [Contact.self, UserSettings.self, NotificationHistory.self], inMemory: true)
}
