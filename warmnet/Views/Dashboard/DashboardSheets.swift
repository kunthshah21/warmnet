//
//  DashboardSheets.swift
//  warmnet
//
//  Created on 14/01/2026.
//

import SwiftUI
import SwiftData
import UserNotifications

// MARK: - Add Reminder Sheet

struct AddReminderSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var contacts: [Contact]
    
    @State private var selectedContact: Contact?
    @State private var reminderTitle = ""
    @State private var reminderNote = ""
    @State private var searchText = ""
    
    @State private var hasDate = false
    @State private var hasTime = false
    @State private var isUrgent = false
    @State private var reminderDate = Date()
    @State private var reminderTime = Date()
    @State private var repeatInterval: ReminderRepeatInterval = .never
    @State private var selectedTimeZone: TimeZone = .current
    
    private var filteredContacts: [Contact] {
        let base: [Contact]
        if searchText.isEmpty {
            base = Array(contacts)
        } else {
            base = contacts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        return sortedByRelevance(base)
    }
    
    private func sortedByRelevance(_ contacts: [Contact]) -> [Contact] {
        return contacts.sorted { a, b in
            let aDate = a.mostRecentInteraction?.date ?? a.lastContacted
            let bDate = b.mostRecentInteraction?.date ?? b.lastContacted
            let aFreq = a.interactions.count
            let bFreq = b.interactions.count
            
            let aHasHistory = aDate != nil || aFreq > 0
            let bHasHistory = bDate != nil || bFreq > 0
            if aHasHistory != bHasHistory { return aHasHistory }
            
            if let ad = aDate, let bd = bDate, ad != bd {
                return ad > bd
            }
            if aFreq != bFreq {
                return aFreq > bFreq
            }
            return a.name < b.name
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search contacts...", text: $searchText)
                }
                .padding(12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top)
                
                if let contact = selectedContact {
                    // Selected contact and reminder details
                    selectedContactView(contact)
                } else {
                    // Contact list
                    contactsList
                }
            }
            .navigationTitle("Add Network Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if selectedContact != nil {
                        Button("Save") {
                            saveReminder()
                            dismiss()
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
        }
    }
    
    private var contactsList: some View {
        List {
            ForEach(filteredContacts) { contact in
                Button {
                    withAnimation {
                        selectedContact = contact
                        reminderTitle = contact.name
                    }
                } label: {
                    HStack(spacing: 12) {
                        AvatarView(name: contact.name, size: 44)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(contact.name)
                                .font(.custom(AppFontName.workSansMedium, size: 16))
                                .foregroundStyle(.primary)
                            
                            if !contact.company.isEmpty {
                                Text(contact.company)
                                    .font(.custom(AppFontName.overpassVariable, size: 13))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.plain)
    }
    
    private func selectedContactView(_ contact: Contact) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Selected contact card with close button
                HStack(spacing: 16) {
                    AvatarView(name: contact.name, size: 50)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(contact.name)
                            .font(.custom(AppFontName.workSansMedium, size: 16))
                        
                        if !contact.company.isEmpty {
                            Text(contact.company)
                                .font(.custom(AppFontName.overpassVariable, size: 13))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            selectedContact = nil
                            resetFormState()
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Title field
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Meeting title", text: $reminderTitle)
                        .font(.custom(AppFontName.workSansMedium, size: 24))
                    
                    Divider()
                }
                
                // Notes field
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Notes", text: $reminderNote, axis: .vertical)
                        .font(.custom(AppFontName.overpassVariable, size: 16))
                        .foregroundStyle(.secondary)
                        .lineLimit(2...4)
                    
                    Divider()
                }
                
                // Date & Time section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Date & Time")
                        .font(.custom(AppFontName.workSansMedium, size: 16))
                        .padding(.bottom, 4)
                    
                    VStack(spacing: 0) {
                        // Date toggle row
                        dateToggleRow
                        
                        // Time toggle row
                        timeToggleRow
                        
                        // Timezone row
                        if hasTime {
                            timeZoneRow
                        }
                        
                        // Urgent toggle row
                        urgentToggleRow
                    }
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    
                    Text("Mark this reminder as urgent to set an alarm.")
                        .font(.custom(AppFontName.overpassVariable, size: 13))
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
                
                // Repeat section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Repeat")
                        .font(.custom(AppFontName.workSansMedium, size: 16))
                    
                    Menu {
                        ForEach(ReminderRepeatInterval.allCases, id: \.self) { interval in
                            Button {
                                repeatInterval = interval
                            } label: {
                                HStack {
                                    Text(interval.rawValue)
                                    if repeatInterval == interval {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(repeatInterval.rawValue)
                                .font(.custom(AppFontName.overpassVariable, size: 16))
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
    }
    
    private var dateToggleRow: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.red)
                        .frame(width: 30, height: 30)
                    Image(systemName: "calendar")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Date")
                        .font(.custom(AppFontName.overpassVariable, size: 16))
                    
                    if hasDate {
                        Text(formattedDateSubtitle)
                            .font(.custom(AppFontName.overpassVariable, size: 13))
                            .foregroundStyle(.blue)
                    }
                }
                
                Spacer()
                
                Toggle("", isOn: $hasDate)
                    .labelsHidden()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            if hasDate {
                Divider()
                    .padding(.leading, 58)
                
                DatePicker("", selection: $reminderDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
            }
            
            Divider()
                .padding(.leading, 58)
        }
    }
    
    private var timeToggleRow: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.blue)
                        .frame(width: 30, height: 30)
                    Image(systemName: "clock.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Time")
                        .font(.custom(AppFontName.overpassVariable, size: 16))
                    
                    if hasTime {
                        Text(formattedTimeSubtitle)
                            .font(.custom(AppFontName.overpassVariable, size: 13))
                            .foregroundStyle(.blue)
                    }
                }
                
                Spacer()
                
                Toggle("", isOn: $hasTime)
                    .labelsHidden()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            if hasTime {
                Divider()
                    .padding(.leading, 58)
                
                DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxHeight: 180)
                    .clipped()
            }
            
            Divider()
                .padding(.leading, 58)
        }
    }
    
    private var timeZoneRow: some View {
        VStack(spacing: 0) {
            NavigationLink {
                TimeZonePicker(selectedTimeZone: $selectedTimeZone)
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.purple)
                            .frame(width: 30, height: 30)
                        Image(systemName: "globe")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Time Zone")
                            .font(.custom(AppFontName.overpassVariable, size: 16))
                            .foregroundStyle(.primary)
                        
                        Text(selectedTimeZone.identifier.replacingOccurrences(of: "_", with: " "))
                            .font(.custom(AppFontName.overpassVariable, size: 13))
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            
            Divider()
                .padding(.leading, 58)
        }
    }
    
    private var urgentToggleRow: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.orange)
                    .frame(width: 30, height: 30)
                Image(systemName: "alarm.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
            }
            
            Text("Urgent")
                .font(.custom(AppFontName.overpassVariable, size: 16))
            
            Spacer()
            
            Toggle("", isOn: $isUrgent)
                .labelsHidden()
                .onChange(of: isUrgent) { _, newValue in
                    if newValue {
                        enableUrgentDefaults()
                    }
                }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var formattedDateSubtitle: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(reminderDate) {
            return "Today"
        } else if calendar.isDateInTomorrow(reminderDate) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: reminderDate)
        }
    }
    
    private var formattedTimeSubtitle: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: reminderTime)
    }
    
    private func enableUrgentDefaults() {
        hasDate = true
        hasTime = true
        
        let calendar = Calendar.current
        let now = Date()
        
        reminderDate = now
        
        let currentHour = calendar.component(.hour, from: now)
        let targetHour = currentHour + 2
        
        if let roundedTime = calendar.date(bySettingHour: targetHour, minute: 0, second: 0, of: now) {
            reminderTime = roundedTime
        }
    }
    
    private func resetFormState() {
        reminderTitle = ""
        reminderNote = ""
        hasDate = false
        hasTime = false
        isUrgent = false
        reminderDate = Date()
        reminderTime = Date()
        repeatInterval = .never
        selectedTimeZone = .current
    }
    
    private func saveReminder() {
        guard let contact = selectedContact else { return }
        
        let manual = ManualReminder(
            contact: contact,
            title: reminderTitle.isEmpty ? contact.name : reminderTitle,
            reminderDate: hasDate ? reminderDate : nil,
            reminderTime: hasTime ? reminderTime : nil,
            note: reminderNote,
            isUrgent: isUrgent,
            repeatInterval: repeatInterval,
            hasDate: hasDate,
            hasTime: hasTime,
            status: .pending,
            source: isUrgent ? .urgent : .manual
        )
        
        modelContext.insert(manual)
        
        if isUrgent, let alarmDate = manual.combinedDateTime {
            Task {
                await scheduleUrgentNotification(
                    for: contact,
                    title: manual.title,
                    note: manual.note,
                    at: alarmDate,
                    reminderId: manual.id
                )
            }
        }
    }
    
    private func scheduleUrgentNotification(
        for contact: Contact,
        title: String,
        note: String,
        at date: Date,
        reminderId: UUID
    ) async {
        let manager = NotificationManager.shared
        
        if !manager.authorizationStatus.canSendNotifications {
            let granted = await manager.requestPermission()
            if !granted { return }
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Urgent: \(title)"
        content.body = note.isEmpty ? "Time to connect with \(contact.name)" : note
        content.sound = .defaultCritical
        content.interruptionLevel = .timeSensitive
        content.userInfo = [
            "contactId": contact.id.uuidString,
            "reminderId": reminderId.uuidString
        ]
        
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "urgent_reminder_\(reminderId.uuidString)",
            content: content,
            trigger: trigger
        )
        
        try? await UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - Notifications Sheet

struct NotificationsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let upcomingReminders: [Contact]
    let onContactTap: (Contact) -> Void
    
    var body: some View {
        NavigationStack {
            Group {
                if upcomingReminders.isEmpty {
                    emptyState
                } else {
                    remindersList
                }
            }
            .navigationTitle("Reminders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("No upcoming reminders")
                .font(.custom(AppFontName.workSansMedium, size: 18))
                .foregroundStyle(.secondary)
            
            Text("Your scheduled contacts will appear here")
                .font(.custom(AppFontName.overpassVariable, size: 14))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var remindersList: some View {
        List {
            Section {
                ForEach(upcomingReminders.prefix(10)) { contact in
                    Button {
                        onContactTap(contact)
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            AvatarView(name: contact.name, size: 40)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(contact.name)
                                    .font(.custom(AppFontName.workSansMedium, size: 16))
                                    .foregroundStyle(.primary)
                                
                                Text(formattedDate(contact.nextReminderDate))
                                    .font(.custom(AppFontName.workSansRegular, size: 13))
                                    .foregroundStyle(contact.isOverdue ? AppColors.accentRed : .secondary)
                            }
                            
                            Spacer()
                            
                            if contact.isOverdue {
                                Text("Overdue")
                                    .font(.custom(AppFontName.workSansRegular, size: 12))
                                    .foregroundStyle(AppColors.accentRed)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(AppColors.accentRed.opacity(0.15))
                                    )
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("Upcoming")
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}

// MARK: - Time Zone Picker

struct TimeZonePicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTimeZone: TimeZone
    @State private var searchText = ""
    
    private var filteredTimeZones: [TimeZone] {
        let allZones = TimeZone.knownTimeZoneIdentifiers.compactMap { TimeZone(identifier: $0) }
        
        if searchText.isEmpty {
            return allZones.sorted { $0.identifier < $1.identifier }
        }
        
        return allZones.filter { zone in
            zone.identifier.localizedCaseInsensitiveContains(searchText) ||
            (zone.localizedName(for: .standard, locale: .current) ?? "").localizedCaseInsensitiveContains(searchText)
        }.sorted { $0.identifier < $1.identifier }
    }
    
    var body: some View {
        List {
            ForEach(filteredTimeZones, id: \.identifier) { zone in
                Button {
                    selectedTimeZone = zone
                    dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(zone.identifier.replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: "/", with: " / "))
                                .font(.custom(AppFontName.overpassVariable, size: 16))
                                .foregroundStyle(.primary)
                            
                            Text(zone.localizedName(for: .standard, locale: .current) ?? "")
                                .font(.custom(AppFontName.overpassVariable, size: 13))
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if zone.identifier == selectedTimeZone.identifier {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .searchable(text: $searchText, prompt: "Search time zones")
        .navigationTitle("Time Zone")
        .navigationBarTitleDisplayMode(.inline)
    }
}
