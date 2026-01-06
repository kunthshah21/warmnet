//
//  BirthdayNotificationTestScreen.swift
//  warmnet
//
//  Testing screen for birthday notifications
//

import SwiftUI
import SwiftData

struct BirthdayNotificationTestScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var contacts: [Contact]
    
    @State private var notificationManager = NotificationManager.shared
    @State private var birthdayService = BirthdayNotificationService.shared
    
    @State private var showTestAlert = false
    @State private var testResult = ""
    
    var body: some View {
        List {
            // MARK: - Status
            Section {
                 HStack {
                    Label("Notifications", systemImage: "bell.fill")
                    Spacer()
                    Text(notificationManager.authorizationStatus.canSendNotifications ? "Authorized" : "Not Authorized")
                        .foregroundStyle(notificationManager.authorizationStatus.canSendNotifications ? .green : .red)
                }
                
                if !notificationManager.authorizationStatus.canSendNotifications {
                    Button("Request Permissions") {
                        Task {
                            await notificationManager.requestPermission()
                        }
                    }
                }
            } header: {
                Text("Status")
            }
            
            // MARK: - Actions
            Section {
                Button("Simulate Birthday Notification (5s Delay)") {
                    Task {
                        await notificationManager.testBirthdayNotification(contactName: "Test User")
                        testResult = "Notification scheduled in 5 seconds"
                        showTestAlert = true
                    }
                }
                
                Button("Schedule All Contacts") {
                    Task {
                        await birthdayService.scheduleAll(contacts: contacts)
                        testResult = "Scheduled for \(contacts.filter({ $0.birthday != nil }).count) contacts"
                        showTestAlert = true
                    }
                }
            } header: {
                Text("Actions")
            } footer: {
                Text("Use simulation to test the notification appearance immediately. Use Schedule All to register real calendar triggers for existing contacts.")
            }
            
            // MARK: - Contacts with Birthdays
            Section("Contacts with Birthdays") {
                let birthdayContacts = contacts.filter { $0.birthday != nil }
                if birthdayContacts.isEmpty {
                    Text("No contacts with birthdays")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(birthdayContacts) { contact in
                        HStack {
                            Text(contact.name)
                            Spacer()
                            if let bday = contact.birthday {
                                Text(bday.formatted(date: .abbreviated, time: .omitted))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Birthday Notifications")
        .alert("Result", isPresented: $showTestAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(testResult)
        }
        .onAppear {
            Task {
                await notificationManager.refreshAuthorizationStatus()
            }
        }
    }
}
