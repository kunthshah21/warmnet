import SwiftUI
import SwiftData

struct AddContactSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var contactToEdit: Contact?
    
    // UI-specific state for split names
    @State private var firstName = ""
    @State private var lastName = ""
    
    // Core fields
    @State private var selectedCountryCode = CountryCode.all[0]
    @State private var phoneNumber = ""
    
    // Advanced fields
    @State private var email = ""
    @State private var company = ""
    @State private var jobTitle = ""
    @State private var reference = ""
    
    // Location
    @State private var city = ""
    @State private var state = ""
    @State private var country = ""
    
    // Personal
    @State private var birthday: Date? = nil
    @State private var showBirthdayPicker = false
    @State private var notes = ""
    
    // Priority
    @State private var priority: Priority = .broaderNetwork
    @State private var useCustomSchedule = false
    @State private var scheduleFrequency: ScheduleFrequency = .month
    @State private var scheduleInterval: Int = 6
    @State private var selectedDays: Set<Weekday> = []
    
    @State private var showDeleteConfirmation = false
    
    init(contactToEdit: Contact? = nil) {
        self.contactToEdit = contactToEdit
        
        if let contact = contactToEdit {
            let components = contact.name.components(separatedBy: " ")
            _firstName = State(initialValue: components.first ?? "")
            if components.count > 1 {
                _lastName = State(initialValue: components.dropFirst().joined(separator: " "))
            } else {
                _lastName = State(initialValue: "")
            }
            
            if let match = CountryCode.all.first(where: { $0.code == contact.phoneCountryCode }) {
                _selectedCountryCode = State(initialValue: match)
            }
            
            _phoneNumber = State(initialValue: contact.phoneNumber)
            _reference = State(initialValue: contact.reference)
            _priority = State(initialValue: contact.priority ?? .broaderNetwork)
            _email = State(initialValue: contact.email)
            _city = State(initialValue: contact.city)
            _state = State(initialValue: contact.state)
            _country = State(initialValue: contact.country)
            _birthday = State(initialValue: contact.birthday)
            _company = State(initialValue: contact.company)
            _jobTitle = State(initialValue: contact.jobTitle)
            _notes = State(initialValue: contact.notes)
            
            _useCustomSchedule = State(initialValue: contact.useCustomSchedule)
            
            if contact.useCustomSchedule {
                if let freqRaw = contact.scheduleFrequency, let freq = ScheduleFrequency(rawValue: freqRaw) {
                    _scheduleFrequency = State(initialValue: freq)
                }
                if let interval = contact.scheduleInterval {
                    _scheduleInterval = State(initialValue: interval)
                }
                if let daysRaw = contact.scheduleDays {
                    let days = daysRaw.compactMap { raw -> Weekday? in
                        Weekday.allCases.first { $0.rawValue == raw }
                    }
                    _selectedDays = State(initialValue: Set(days))
                }
            } else {
                let (interval, freq) = Self.getDefaultSchedule(for: contact.priority ?? .broaderNetwork)
                _scheduleInterval = State(initialValue: interval)
                _scheduleFrequency = State(initialValue: freq)
            }
        }
    }
    
    var fullName: String {
        [firstName, lastName].filter { !$0.isEmpty }.joined(separator: " ")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Header / Avatar Section
                Section {
                    VStack(spacing: 12) {
                        ZStack {
                            if fullName.isEmpty && contactToEdit == nil {
                                Circle()
                                    .fill(Color(.systemGray4))
                                    .frame(width: 100, height: 100)
                                Text("?")
                                    .font(.largeTitle)
                                    .foregroundStyle(.white)
                            } else {
                                AvatarView(name: fullName.isEmpty ? "?" : fullName, size: 100)
                            }
                        }
                        
                        Button("Add Photo") {
                            // Photo picker placeholder
                        }
                        .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    .padding(.bottom, 10)
                }
                
                Section {
                    TextField("First name", text: $firstName)
                    TextField("Last name", text: $lastName)
                    TextField("Company", text: $company)
                }
                
                // Phone Group
                Section {
                    if !phoneNumber.isEmpty {
                        HStack {
                            Button {
                                phoneNumber = ""
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.plain)
                            
                            Menu {
                                ForEach(CountryCode.all) { code in
                                    Button {
                                        selectedCountryCode = code
                                    } label: {
                                        Text(code.fullDisplayName)
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text("mobile")
                                        .foregroundStyle(.blue)
                                    Image(systemName: "chevron.right")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Text(selectedCountryCode.code)
                                .foregroundStyle(.secondary)

                            TextField("Phone", text: $phoneNumber)
                                .keyboardType(.phonePad)
                        }
                    } else {
                        Button {
                            phoneNumber = " "
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(.green)
                                Text("add phone")
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                    
                    if !email.isEmpty {
                         HStack {
                            Button {
                                email = ""
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.plain)
                            
                            Text("email")
                                .foregroundStyle(.blue)
                                .frame(width: 60, alignment: .leading)
                            
                            Divider()
                            
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                        }
                    } else {
                         Button {
                            email = " "
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(.green)
                                Text("add email")
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                }
                
                // Extra Fields
                Section {
                     if let bday = birthday {
                        HStack {
                             Button {
                                birthday = nil
                                showBirthdayPicker = false
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.plain)

                            Text("birthday")
                                .foregroundStyle(.blue)
                            
                             Spacer()
                            
                             Button {
                                showBirthdayPicker.toggle()
                             } label: {
                                Text(bday, style: .date)
                                    .foregroundStyle(.primary)
                             }
                        }
                        if showBirthdayPicker {
                            DatePicker("Birthday", selection: Binding(get: { birthday ?? Date() }, set: { birthday = $0 }), displayedComponents: .date)
                                .datePickerStyle(.graphical)
                        }
                     } else {
                         Button {
                            birthday = Date()
                            showBirthdayPicker = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(.green)
                                Text("add birthday")
                                    .foregroundStyle(.primary)
                            }
                        }
                     }
                     
                    TextField("Job Title", text: $jobTitle)
                    TextField("Reference", text: $reference)
                }
                
                // Location
                Section {
                    TextField("City", text: $city)
                    TextField("State", text: $state)
                    TextField("Country", text: $country)
                }
                
                 // Priority
                Section(header: Text("Priority & Schedule")) {
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    
                    if priority == .innerCircle {
                        Toggle("Custom Schedule", isOn: $useCustomSchedule)
                        if useCustomSchedule {
                             HStack {
                                Text("Repeat every")
                                TextField("Interval", value: $scheduleInterval, format: .number)
                                    .keyboardType(.numberPad)
                                    .frame(width: 40)
                                Picker("", selection: $scheduleFrequency) {
                                    ForEach(ScheduleFrequency.allCases, id: \.self) { freq in
                                        Text(freq.rawValue).tag(freq)
                                    }
                                }
                             }
                        }
                    }
                }
                
                Section {
                     ZStack(alignment: .topLeading) {
                        if notes.isEmpty {
                            Text("Notes")
                                .foregroundStyle(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $notes)
                            .frame(minHeight: 100)
                    }
                }
                
                if contactToEdit != nil {
                     Section {
                        Button {
                            showDeleteConfirmation = true
                        } label: {
                            Text("Delete Contact")
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                     }
                }
            }
            .navigationTitle(contactToEdit == nil ? "New Contact" : "Edit Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { saveContact() }
                        .fontWeight(.semibold)
                        .disabled(firstName.isEmpty && lastName.isEmpty && company.isEmpty)
                }
            }
            .alert("Delete Contact?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    if let contact = contactToEdit {
                        modelContext.delete(contact)
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
    
    private func saveContact() {
        let finalName = [firstName, lastName].filter { !$0.isEmpty }.joined(separator: " ")
        var adjustedName = finalName
        if adjustedName.isEmpty && !company.isEmpty { adjustedName = company }
        if adjustedName.isEmpty { adjustedName = "No Name" }
        
        let cleanedPhone = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let contact = contactToEdit {
             let priorityChanged = contact.priority != priority
             contact.name = adjustedName
             contact.phoneCountryCode = selectedCountryCode.code
             contact.phoneNumber = cleanedPhone == " " ? "" : cleanedPhone
             contact.reference = reference
             contact.email = cleanedEmail == " " ? "" : cleanedEmail
             contact.city = city
             contact.state = state
             contact.country = country
             contact.birthday = birthday
             contact.company = company
             contact.jobTitle = jobTitle
             contact.notes = notes
             contact.priority = priority
             contact.useCustomSchedule = useCustomSchedule
             contact.scheduleFrequency = scheduleFrequency.rawValue
             contact.scheduleInterval = scheduleInterval
             contact.scheduleDays = selectedDays.map { $0.rawValue }
             contact.updatedAt = Date()
             
             if priorityChanged || contact.useCustomSchedule != useCustomSchedule {
                 if let lastContacted = contact.lastContacted {
                     ReminderScheduler.rescheduleAfterInteraction(contact, interactionDate: lastContacted)
                 } else {
                     ReminderScheduler.scheduleNewContact(contact)
                 }
             }
        } else {
             let contact = Contact(
                name: adjustedName,
                phoneCountryCode: selectedCountryCode.code,
                phoneNumber: cleanedPhone == " " ? "" : cleanedPhone,
                reference: reference,
                email: cleanedEmail == " " ? "" : cleanedEmail,
                city: city,
                state: state,
                country: country,
                birthday: birthday,
                company: company,
                jobTitle: jobTitle,
                notes: notes,
                priority: priority,
                useCustomSchedule: useCustomSchedule,
                scheduleFrequency: scheduleFrequency.rawValue,
                scheduleInterval: scheduleInterval,
                scheduleDays: selectedDays.map { $0.rawValue }
            )
             ReminderScheduler.scheduleNewContact(contact)
             modelContext.insert(contact)
        }
        dismiss()
    }
    
    private static func getDefaultSchedule(for priority: Priority) -> (Int, ScheduleFrequency) {
        switch priority {
        case .innerCircle: return (2, .week)
        case .keyRelationships: return (2, .month)
        case .broaderNetwork: return (6, .month)
        }
    }
}

enum ScheduleFrequency: String, CaseIterable {
    case day = "Day(s)"
    case week = "Week(s)"
    case month = "Month(s)"
    case year = "Year(s)"
}

enum Weekday: String, CaseIterable, Identifiable {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
    
    var id: String { rawValue }
    
    var shortName: String {
        switch self {
        case .monday: return "M"
        case .tuesday: return "T"
        case .wednesday: return "W"
        case .thursday: return "T"
        case .friday: return "F"
        case .saturday: return "S"
        case .sunday: return "S"
        }
    }
}

struct DayToggle: View {
    let day: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(day)
                .font(.caption2)
                .fontWeight(.bold)
                .frame(width: 32, height: 32)
                .background(isSelected ? Color("Blue-app") : Color(.systemGray6))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AddContactSheet()
        .modelContainer(for: Contact.self, inMemory: true)
}
