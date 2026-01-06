import SwiftUI
import SwiftData

struct AddContactSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var contactToEdit: Contact?
      
    // Basic info
    @State private var name = ""
    @State private var selectedCountryCode = CountryCode.all[0]
    @State private var phoneNumber = ""
    @State private var reference = ""
    @State private var priority: Priority = .broaderNetwork
    
    // Advanced info
    @State private var email = ""
    @State private var city = ""
    @State private var state = ""
    @State private var country = ""
    @State private var birthday: Date? = nil
    @State private var showBirthdayPicker = false
    @State private var company = ""
    @State private var jobTitle = ""
    @State private var notes = ""
    
    // Schedule Override
    @State private var useCustomSchedule = false
    @State private var scheduleFrequency: ScheduleFrequency = .month
    @State private var scheduleInterval: Int = 6
    @State private var selectedDays: Set<Weekday> = []
    
    init(contactToEdit: Contact? = nil) {
        self.contactToEdit = contactToEdit
        
        if let contact = contactToEdit {
            _name = State(initialValue: contact.name)
            
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
            
            // Initialize schedule defaults based on existing priority
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
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header avatar
                    headerSection
                    
                    // Basic fields
                    basicInfoSection
                    
                    // Priority
                    prioritySection
                    
                    // Advanced fields
                    advancedInfoSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .scrollContentBackground(.visible)
            .background(Color(.systemGroupedBackground))
            .navigationTitle(contactToEdit == nil ? "New Contact" : "Edit Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveContact()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            AvatarView(name: name.isEmpty ? "?" : name, size: 100)
            
            Text(name.isEmpty ? (contactToEdit == nil ? "New Contact" : "Edit Contact") : name)
                .font(.title2.weight(.semibold))
                .foregroundStyle(name.isEmpty ? .secondary : .primary)
        }
        .padding(.top, 20)
    }
    
    private var basicInfoSection: some View {
        VStack(spacing: 16) {
            sectionHeader("Basic Information")
            
            VStack(spacing: 12) {
                FormTextField(
                    title: "Name",
                    text: $name,
                    placeholder: "Full name",
                    autocapitalization: .words
                )
                
                phoneField
                
                FormTextField(
                    title: "Reference",
                    text: $reference,
                    placeholder: "How do you know this person?"
                )
            }
            .padding(16)
            .background(cardBackground)
        }
    }
    
    private var prioritySection: some View {
        VStack(spacing: 16) {
            sectionHeader("Priority & Schedule")
            
            VStack(spacing: 16) {
                // Priority Picker
                HStack(spacing: 0) {
                    ForEach(Priority.allCases, id: \.self) { option in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                priority = option
                                // Update schedule defaults when priority changes
                                let (interval, freq) = Self.getDefaultSchedule(for: option)
                                scheduleInterval = interval
                                scheduleFrequency = freq
                            }
                        } label: {
                            Text(option.rawValue.replacingOccurrences(of: " ", with: "\n"))
                                .font(.subheadline)
                                .fontWeight(priority == option ? .semibold : .regular)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 4)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 7)
                                        .fill(priority == option ? Color(.systemBackground) : Color.clear)
                                        .shadow(color: priority == option ? .black.opacity(0.12) : .clear, radius: 2, x: 0, y: 1)
                                        .padding(2)
                                )
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 9)
                        .fill(Color(.tertiarySystemFill))
                )
                
                HStack {
                    Circle()
                        .fill(priority.color)
                        .frame(width: 8, height: 8)
                    
                    Text(priority.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal, 4)
                
                if priority == .innerCircle {
                    Divider()
                    
                    // Schedule Override
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Custom Schedule", isOn: $useCustomSchedule.animation())
                            .tint(.blue)
                        
                        if useCustomSchedule {
                            VStack(alignment: .leading, spacing: 16) {
                                // Frequency Picker
                                HStack {
                                    Text("Repeat every")
                                        .foregroundStyle(.secondary)
                                    
                                    if scheduleFrequency == .week {
                                        Menu {
                                            ForEach(1...3, id: \.self) { num in
                                                Button {
                                                    scheduleInterval = num
                                                } label: {
                                                    if scheduleInterval == num {
                                                        Label("\(num)", systemImage: "checkmark")
                                                    } else {
                                                        Text("\(num)")
                                                    }
                                                }
                                            }
                                        } label: {
                                            Text("\(scheduleInterval)")
                                                .multilineTextAlignment(.center)
                                                .frame(width: 50)
                                                .padding(.vertical, 6)
                                                .background(Color(.systemGray6))
                                                .cornerRadius(8)
                                                .foregroundStyle(.primary)
                                        }
                                    } else {
                                        TextField("1", value: $scheduleInterval, format: .number)
                                            .keyboardType(.numberPad)
                                            .multilineTextAlignment(.center)
                                            .frame(width: 50)
                                            .padding(.vertical, 6)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(8)
                                    }
                                    
                                    Picker("", selection: $scheduleFrequency) {
                                        ForEach([ScheduleFrequency.day, ScheduleFrequency.week], id: \.self) { freq in
                                            Text(freq.rawValue).tag(freq)
                                        }
                                    }
                                    .labelsHidden()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .onChange(of: scheduleFrequency) { _, newValue in
                                        if newValue == .week && scheduleInterval > 3 {
                                            scheduleInterval = 2
                                        }
                                    }
                                }
                                
                                // Days of week picker (if weekly)
                                if scheduleFrequency == .week {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("On these days")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        
                                        HStack(spacing: 0) {
                                            ForEach(Weekday.allCases) { day in
                                                DayToggle(day: day.shortName, isSelected: selectedDays.contains(day)) {
                                                    if selectedDays.contains(day) {
                                                        selectedDays.remove(day)
                                                    } else {
                                                        selectedDays.insert(day)
                                                    }
                                                }
                                                .frame(maxWidth: .infinity)
                                            }
                                        }
                                    }
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                }
                            }
                            .padding(.top, 4)
                        } else {
                            // Default Schedule Info
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                    .foregroundStyle(.secondary)
                                Text("Default: Every \(defaultDaysForPriority) days")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .padding(.top, 4)
                        }
                    }
                }
            }
            .padding(16)
            .background(cardBackground)
        }
    }
    
    private var defaultDaysForPriority: Int {
        switch priority {
        case .innerCircle: return 14
        case .keyRelationships: return 60
        case .broaderNetwork: return 180
        }
    }
    
    private static func getDefaultSchedule(for priority: Priority) -> (Int, ScheduleFrequency) {
        switch priority {
        case .innerCircle: return (2, .week)
        case .keyRelationships: return (2, .month)
        case .broaderNetwork: return (6, .month)
        }
    }
    
    private var phoneField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Phone")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            
            HStack(spacing: 8) {
                // Country code picker
                Menu {
                    ForEach(CountryCode.all) { code in
                        Button {
                            selectedCountryCode = code
                        } label: {
                            Text(code.fullDisplayName)
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(selectedCountryCode.displayName)
                            .font(.body)
                        Image(systemName: "chevron.down")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.systemGray5))
                    )
                }
                
                // Phone number field
                TextField("Phone number", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.systemGray6))
                    )
            }
        }
    }
    
    private var advancedInfoSection: some View {
        VStack(spacing: 16) {
            // Contact details
            VStack(spacing: 16) {
                sectionHeader("Contact Details")
                
                VStack(spacing: 12) {
                    FormTextField(
                        title: "Email",
                        text: $email,
                        placeholder: "email@example.com",
                        keyboardType: .emailAddress,
                        autocapitalization: .never
                    )
                }
                .padding(16)
                .background(cardBackground)
            }
            
            // Location
            VStack(spacing: 16) {
                sectionHeader("Location")
                
                LocationInputView(
                    city: $city,
                    state: $state,
                    country: $country
                )
                .padding(16)
                .background(cardBackground)
            }
            
            // Personal details
            VStack(spacing: 16) {
                sectionHeader("Personal Details")
                
                VStack(spacing: 12) {
                    // Birthday
                    birthdayField
                    
                    FormTextField(
                        title: "Company",
                        text: $company,
                        placeholder: "Company name",
                        autocapitalization: .words
                    )
                    
                    FormTextField(
                        title: "Job Title",
                        text: $jobTitle,
                        placeholder: "Job title",
                        autocapitalization: .words
                    )
                    
                    notesField
                }
                .padding(16)
                .background(cardBackground)
            }
        }
    }
    
    private var birthdayField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Birthday")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            
            Button {
                showBirthdayPicker.toggle()
                if birthday == nil {
                    birthday = Date()
                }
            } label: {
                HStack {
                    if let birthday = birthday {
                        Text(birthday, style: .date)
                            .foregroundStyle(.primary)
                    } else {
                        Text("Add birthday")
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "calendar")
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemGray6))
                )
            }
            .buttonStyle(.plain)
            
            if showBirthdayPicker, let _ = birthday {
                DatePicker(
                    "Birthday",
                    selection: Binding(
                        get: { birthday ?? Date() },
                        set: { birthday = $0 }
                    ),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemGray6))
                )
            }
        }
    }
    
    private var notesField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            
            TextEditor(text: $notes)
                .frame(minHeight: 80)
                .padding(12)
                .scrollContentBackground(.hidden)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemGray6))
                )
        }
    }
    
    // MARK: - Helpers
    
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            Spacer()
        }
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color(.systemBackground))
            .shadow(color: .black.opacity(0.03), radius: 8, y: 2)
    }
    
    // MARK: - Actions
    
    private func saveContact() {
        if let contact = contactToEdit {
            let priorityChanged = contact.priority != priority
            let scheduleChanged = contact.useCustomSchedule != useCustomSchedule
            
            contact.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            contact.phoneCountryCode = selectedCountryCode.code
            contact.phoneNumber = phoneNumber
            contact.reference = reference
            contact.email = email
            contact.city = city
            contact.state = state
            contact.country = country
            contact.birthday = birthday
            contact.company = company
            contact.jobTitle = jobTitle
            contact.notes = notes
            contact.priority = priority
            
            // Save custom schedule
            contact.useCustomSchedule = useCustomSchedule
            contact.scheduleFrequency = scheduleFrequency.rawValue
            contact.scheduleInterval = scheduleInterval
            contact.scheduleDays = selectedDays.map { $0.rawValue }
            
            contact.updatedAt = Date()
            
            if priorityChanged || scheduleChanged || useCustomSchedule {
                if let lastContacted = contact.lastContacted {
                    ReminderScheduler.rescheduleAfterInteraction(contact, interactionDate: lastContacted)
                } else {
                    ReminderScheduler.scheduleNewContact(contact)
                }
            }
        } else {
            let contact = Contact(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                phoneCountryCode: selectedCountryCode.code,
                phoneNumber: phoneNumber,
                reference: reference,
                email: email,
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
                .background(isSelected ? Color.blue : Color(.systemGray6))
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
