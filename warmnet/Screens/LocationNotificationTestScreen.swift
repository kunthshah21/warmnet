//
//  LocationNotificationTestScreen.swift
//  warmnet
//
//  Testing screen for location-based push notifications
//

import SwiftUI
import SwiftData

struct LocationNotificationTestScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var contacts: [Contact]
    
    @State private var locationService = LocationNotificationService.shared
    @State private var notificationManager = NotificationManager.shared
    @State private var settings: UserSettings?
    
    @State private var testResult: String?
    @State private var showTestAlert = false
    @State private var testAlertMessage = ""
    
    var body: some View {
        List {
            // MARK: - System Status
            systemStatusSection
            
            // MARK: - Permissions
            permissionsSection
            
            // MARK: - Settings Check
            settingsCheckSection
            
            // MARK: - Monitored Cities
            monitoredCitiesSection
            
            // MARK: - Test Actions
            testActionsSection
        }
        .navigationTitle("Test Location Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadSettings()
            Task {
                await notificationManager.refreshAuthorizationStatus()
            }
        }
        .alert("Test Result", isPresented: $showTestAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(testAlertMessage)
        }
    }
    
    // MARK: - System Status Section
    
    private var systemStatusSection: some View {
        Section {
            HStack {
                Label("System Ready", systemImage: systemReady ? "checkmark.circle.fill" : "xmark.circle.fill")
                Spacer()
                Text(systemReady ? "Yes" : "No")
                    .foregroundStyle(systemReady ? .green : .red)
                    .font(.subheadline)
            }
            
            if let result = testResult {
                Text(result)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Status")
        } footer: {
            Text("All systems must be ready for notifications to work. Check permissions and settings below.")
        }
    }
    
    private var systemReady: Bool {
        locationService.authorizationStatus.canUseGeofencing &&
        notificationManager.authorizationStatus.canSendNotifications &&
        (settings?.locationNotificationsEnabled ?? false) &&
        !locationService.monitoredCities.isEmpty
    }
    
    // MARK: - Permissions Section
    
    private var permissionsSection: some View {
        Section {
            // Location Permission
            HStack {
                Label("Location Access", systemImage: "location.fill")
                Spacer()
                permissionBadge(for: locationService.authorizationStatus)
            }
            
            if locationService.authorizationStatus != .always {
                Button {
                    requestLocationPermission()
                } label: {
                    HStack {
                        Text("Request Location Permission")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Notification Permission
            HStack {
                Label("Notifications", systemImage: "bell.fill")
                Spacer()
                notificationPermissionBadge
            }
            
            if !notificationManager.authorizationStatus.canSendNotifications {
                Button {
                    requestNotificationPermission()
                } label: {
                    HStack {
                        Text("Request Notification Permission")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        } header: {
            Text("Permissions")
        } footer: {
            Text("Location notifications require \"Always\" location access and notification permissions.")
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
    
    // MARK: - Settings Check Section
    
    private var settingsCheckSection: some View {
        Section {
            HStack {
                Label("Location Notifications Enabled", systemImage: "location.circle")
                Spacer()
                if settings?.locationNotificationsEnabled == true {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.red)
                }
            }
            
            if settings?.locationNotificationsEnabled == false {
                Button {
                    enableLocationNotifications()
                } label: {
                    Text("Enable Location Notifications")
                }
            }
            
            if let cooldown = settings?.notificationCooldown {
                HStack {
                    Label("Notification Cooldown", systemImage: "clock")
                    Spacer()
                    Text(cooldown.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            if settings?.quietHoursEnabled == true {
                HStack {
                    Label("Quiet Hours", systemImage: "moon.fill")
                    Spacer()
                    Text("Active")
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                }
            }
        } header: {
            Text("Settings")
        } footer: {
            Text("Location notifications must be enabled in settings. Check the Notifications settings screen to configure.")
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
                    Text("Add contacts with city information and refresh geofences to enable monitoring.")
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
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(city.contactCount) contact\(city.contactCount == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Button {
                                testNotification(for: city.city)
                            } label: {
                                Text("Test")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
            }
            
            Button {
                setupGeofences()
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
            Text("Tap \"Test\" next to any city to simulate entering that region and trigger a notification.")
        }
    }
    
    // MARK: - Test Actions Section
    
    private var testActionsSection: some View {
        Section {
            Button {
                testAllSystems()
            } label: {
                HStack {
                    Label("Test All Systems", systemImage: "checkmark.circle")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            if !locationService.monitoredCities.isEmpty {
                Button {
                    testRandomCity()
                } label: {
                    HStack {
                        Label("Test Random City", systemImage: "dice")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            NavigationLink {
                NotificationsSettingsScreen()
            } label: {
                HStack {
                    Label("Open Notification Settings", systemImage: "gear")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("Actions")
        }
    }
    
    // MARK: - Actions
    
    private func loadSettings() {
        settings = UserSettings.getOrCreate(from: modelContext)
    }
    
    private func requestLocationPermission() {
        switch locationService.authorizationStatus {
        case .notDetermined:
            locationService.requestWhenInUseAuthorization()
            Task {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if locationService.authorizationStatus == LocationNotificationService.LocationAuthorizationStatus.whenInUse {
                    locationService.requestAlwaysAuthorization()
                }
            }
        case .whenInUse:
            locationService.requestAlwaysAuthorization()
        case .denied:
            testAlertMessage = "Location access was denied. Please enable \"Always\" location access in Settings."
            showTestAlert = true
        case .always:
            break
        }
    }
    
    private func requestNotificationPermission() {
        Task {
            let granted = await notificationManager.requestPermission()
            if !granted {
                testAlertMessage = "Notification permission was denied. Please enable notifications in Settings."
                showTestAlert = true
            }
        }
    }
    
    private func enableLocationNotifications() {
        settings?.setLocationNotifications(enabled: true)
        setupGeofences()
    }
    
    private func setupGeofences() {
        Task {
            await locationService.setupGeofences(for: contacts)
        }
    }
    
    private func testNotification(for city: String) {
        guard systemReady else {
            testAlertMessage = "System not ready. Please check:\n• Location permission is \"Always\"\n• Notification permission is granted\n• Location notifications are enabled\n• At least one city is monitored"
            showTestAlert = true
            return
        }
        
        locationService.simulateRegionEntry(city: city)
        testResult = "Test notification triggered for \(city). Check your notification center!"
        testAlertMessage = "Test notification triggered for \(city).\n\nYou should see a notification appear in about 1 second. If you don't see it, check:\n• Notification Center is not in Do Not Disturb mode\n• App notifications are enabled in Settings\n• The app has notification permission"
        showTestAlert = true
        
        // Clear result after 5 seconds
        Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            testResult = nil
        }
    }
    
    private func testAllSystems() {
        var issues: [String] = []
        
        if !locationService.authorizationStatus.canUseGeofencing {
            issues.append("Location permission is not \"Always\"")
        }
        
        if !notificationManager.authorizationStatus.canSendNotifications {
            issues.append("Notification permission is not granted")
        }
        
        if settings?.locationNotificationsEnabled != true {
            issues.append("Location notifications are disabled in settings")
        }
        
        if locationService.monitoredCities.isEmpty {
            issues.append("No cities are being monitored")
        }
        
        if issues.isEmpty {
            testAlertMessage = "✅ All systems are ready!\n\nYou can test notifications by tapping \"Test\" next to any monitored city."
        } else {
            testAlertMessage = "⚠️ Issues found:\n\n" + issues.joined(separator: "\n• ")
        }
        
        showTestAlert = true
    }
    
    private func testRandomCity() {
        guard let randomCity = locationService.monitoredCities.randomElement() else {
            return
        }
        testNotification(for: randomCity.city)
    }
}

#Preview {
    NavigationStack {
        LocationNotificationTestScreen()
    }
    .modelContainer(for: [Contact.self, UserSettings.self, NotificationHistory.self], inMemory: true)
}

