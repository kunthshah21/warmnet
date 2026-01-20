import SwiftUI
import SwiftData

struct ContactDetailScreen: View {
    @Bindable var contact: Contact
    @State private var showEditSheet = false
    @State private var showHistory = false
    @State private var scrollOffset: CGFloat = 0
    
    // MARK: - Computed Properties
    
    private var interactionCount: Int {
        contact.interactions.count
    }
    
    private var progressValue: Double {
        // Progress based on interaction count, max at 50 interactions
        min(Double(interactionCount) / 50.0, 1.0)
    }
    
    private var blurAmount: CGFloat {
        // Blur increases as user scrolls up, max blur at 20
        min(max(scrollOffset / 15, 0), 20)
    }
    
    private var avatarScale: CGFloat {
        // Scale down slightly as user scrolls
        let scale = 1 - (scrollOffset / 500)
        return max(min(scale, 1), 0.8)
    }
    
    private var avatarOpacity: Double {
        // Fade out avatar as blur increases
        let opacity = 1 - (scrollOffset / 200)
        return max(min(opacity, 1), 0.3)
    }
    
    private var hasContactInfo: Bool {
        !contact.phoneNumber.isEmpty || !contact.email.isEmpty
    }
    
    private var hasWorkOrPersonalInfo: Bool {
        !contact.company.isEmpty || !contact.jobTitle.isEmpty || contact.birthday != nil
    }
    
    private var sortedInteractions: [Interaction] {
        contact.interactions.sorted { $0.date > $1.date }
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Scroll offset tracker
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self, value: -geometry.frame(in: .named("scroll")).minY)
                }
                .frame(height: 0)
                
                VStack(spacing: 24) {
                    // Large Profile Header with Blur Effect
                    profileHeaderSection
                    
                    // Contact Stats Section (Progress + Last Contacted + History)
                    contactStatsSection
                    
                    // Contact Info
                    if hasContactInfo {
                        contactInfoSection
                    }
                    
                    // Location
                    if !contact.fullLocation.isEmpty {
                        locationSection
                    }
                    
                    // Work & Personal
                    if hasWorkOrPersonalInfo {
                        workAndPersonalSection
                    }
                    
                    // Notes
                    if !contact.notes.isEmpty {
                        notesSection
                    }
                    
                    // Reference
                    if !contact.reference.isEmpty {
                        referenceSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            scrollOffset = value
        }
        .scrollContentBackground(.visible)
        .background(
            LinearGradient(
                colors: [
                    Color(.systemGray5),
                    Color(.systemGray6),
                    Color(.systemGroupedBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            AddContactSheet(contactToEdit: contact)
        }
    }
    
    // MARK: - Profile Header Section
    
    private var profileHeaderSection: some View {
        VStack(spacing: 20) {
            // Large Avatar with Blur Effect
            ZStack {
                // Blurred background ring
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 180, height: 180)
                    .blur(radius: blurAmount)
                    .opacity(avatarOpacity)
                
                // Avatar
                ContactAvatarView(
                    name: contact.name,
                    photoData: contact.photoData,
                    size: 160
                )
                .scaleEffect(avatarScale)
                .blur(radius: blurAmount * 0.5)
                .opacity(avatarOpacity)
            }
            .animation(.easeOut(duration: 0.1), value: scrollOffset)
            
            // Name and Subtitle
            VStack(spacing: 8) {
                Text(contact.name)
                    .font(.custom(AppFontName.workSansMedium, size: 32))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                
                if !contact.jobTitle.isEmpty || !contact.company.isEmpty {
                    VStack(spacing: 4) {
                        if !contact.jobTitle.isEmpty {
                            Text(contact.jobTitle)
                                .font(.custom(AppFontName.workSansMedium, size: 16))
                                .foregroundStyle(.secondary)
                        }
                        
                        if !contact.company.isEmpty {
                            Text(contact.company)
                                .font(.custom(AppFontName.workSansRegular, size: 14))
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
    
    // MARK: - Contact Stats Section
    
    private var contactStatsSection: some View {
        VStack(spacing: 0) {
            // Progress Bar Section
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(AppColors.mutedBlue)
                    
                    Text("Times Contacted")
                        .font(.custom(AppFontName.workSansMedium, size: 14))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text("\(interactionCount)")
                        .font(.custom(AppFontName.workSansMedium, size: 20))
                        .foregroundStyle(AppColors.mutedBlue)
                }
                
                // Progress Bar
                ContactProgressBar(progress: progressValue, interactionCount: interactionCount)
            }
            .padding(16)
            
            Divider()
                .padding(.leading, 16)
            
            // Last Contacted Section
            HStack(spacing: 12) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(AppColors.accentGreen)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Last Contacted")
                        .font(.custom(AppFontName.workSansRegular, size: 12))
                        .foregroundStyle(.secondary)
                    
                    if let lastContacted = contact.lastContacted {
                        Text(lastContacted.formatted(date: .abbreviated, time: .omitted))
                            .font(.custom(AppFontName.workSansMedium, size: 16))
                            .foregroundStyle(.primary)
                    } else if let lastInteraction = sortedInteractions.first {
                        Text(lastInteraction.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.custom(AppFontName.workSansMedium, size: 16))
                            .foregroundStyle(.primary)
                    } else {
                        Text("Never")
                            .font(.custom(AppFontName.workSansMedium, size: 16))
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(16)
            
            Divider()
                .padding(.leading, 16)
            
            // Interaction History Toggle
            Button {
                withAnimation(.spring(duration: 0.4, bounce: 0.2)) {
                    showHistory.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "list.bullet.clipboard")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.purple)
                    
                    Text("Interaction History")
                        .font(.custom(AppFontName.workSansRegular, size: 16))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Text("\(interactionCount) entries")
                            .font(.custom(AppFontName.workSansRegular, size: 14))
                            .foregroundStyle(.secondary)
                        
                        Image(systemName: showHistory ? "chevron.up" : "chevron.down")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(16)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            // Expandable History List
            if showHistory {
                Divider()
                    .padding(.leading, 16)
                
                interactionHistoryList
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(glassCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    // MARK: - Interaction History List
    
    private var interactionHistoryList: some View {
        VStack(spacing: 0) {
            if sortedInteractions.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 20))
                        .foregroundStyle(.secondary)
                    
                    Text("No interactions logged yet")
                        .font(.custom(AppFontName.workSansRegular, size: 16))
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                .padding(16)
            } else {
                ForEach(Array(sortedInteractions.enumerated()), id: \.element.id) { index, interaction in
                    VStack(spacing: 0) {
                        HStack(alignment: .top, spacing: 12) {
                            // Interaction type icon
                            ZStack {
                                Circle()
                                    .fill(colorForType(interaction.interactionType.color).opacity(0.15))
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: interaction.interactionType.icon)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(colorForType(interaction.interactionType.color))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(interaction.interactionType.rawValue)
                                        .font(.custom(AppFontName.workSansMedium, size: 14))
                                        .foregroundStyle(.primary)
                                    
                                    Spacer()
                                    
                                    Text(interaction.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.custom(AppFontName.workSansRegular, size: 12))
                                        .foregroundStyle(.secondary)
                                }
                                
                                if !interaction.notes.isEmpty {
                                    Text(interaction.notes)
                                        .font(.custom(AppFontName.workSansRegular, size: 12))
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                        .padding(.top, 2)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        
                        if index < sortedInteractions.count - 1 {
                            Divider()
                                .padding(.leading, 64)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Contact Info Section
    
    private var contactInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Contact Info")
            
            VStack(spacing: 0) {
                if !contact.phoneNumber.isEmpty {
                    detailRow(icon: "phone.fill", iconColor: .blue, title: "Phone", value: contact.fullPhoneNumber)
                }
                
                if !contact.phoneNumber.isEmpty && !contact.email.isEmpty {
                    Divider()
                        .padding(.leading, 52)
                }
                
                if !contact.email.isEmpty {
                    detailRow(icon: "envelope.fill", iconColor: .orange, title: "Email", value: contact.email)
                }
            }
            .background(glassCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
    
    // MARK: - Location Section
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Location")
            
            VStack(spacing: 0) {
                detailRow(icon: "mappin.circle.fill", iconColor: .red, title: "Address", value: contact.fullLocation)
            }
            .background(glassCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
    
    // MARK: - Work And Personal Section
    
    private var workAndPersonalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Personal Details")
            
            VStack(spacing: 0) {
                if !contact.company.isEmpty {
                    detailRow(icon: "building.2.fill", iconColor: .indigo, title: "Company", value: contact.company)
                }
                
                if !contact.company.isEmpty && !contact.jobTitle.isEmpty {
                    Divider()
                        .padding(.leading, 52)
                }
                
                if !contact.jobTitle.isEmpty {
                    detailRow(icon: "briefcase.fill", iconColor: .brown, title: "Job Title", value: contact.jobTitle)
                }
                
                if (!contact.company.isEmpty || !contact.jobTitle.isEmpty) && contact.birthday != nil {
                    Divider()
                        .padding(.leading, 52)
                }
                
                if let birthday = contact.birthday {
                    detailRow(icon: "gift.fill", iconColor: .pink, title: "Birthday", value: birthday.formatted(date: .long, time: .omitted))
                }
            }
            .background(glassCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
    
    // MARK: - Notes Section
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Notes")
            
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "note.text")
                    .font(.system(size: 18))
                    .foregroundStyle(AppColors.softBeige)
                    .frame(width: 24)
                
                Text(contact.notes)
                    .font(.custom(AppFontName.workSansRegular, size: 16))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(glassCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
    
    // MARK: - Reference Section
    
    private var referenceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Reference")
            
            HStack(spacing: 12) {
                Image(systemName: "person.text.rectangle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(AppColors.darkTeal)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("How you met")
                        .font(.custom(AppFontName.workSansRegular, size: 12))
                        .foregroundStyle(.secondary)
                    
                    Text(contact.reference)
                        .font(.custom(AppFontName.workSansRegular, size: 16))
                        .foregroundStyle(.primary)
                }
                
                Spacer()
            }
            .padding(16)
            .background(glassCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
    
    // MARK: - Helpers
    
    private func colorForType(_ colorName: String) -> Color {
        switch colorName {
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "orange": return .orange
        case "mint": return .mint
        default: return .blue
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.custom(AppFontName.workSansMedium, size: 12))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .padding(.leading, 4)
    }
    
    private func detailRow(icon: String, iconColor: Color, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(iconColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.custom(AppFontName.workSansRegular, size: 12))
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.custom(AppFontName.workSansRegular, size: 16))
                    .foregroundStyle(.primary)
            }
            
            Spacer()
        }
        .padding(16)
    }
    
    private var glassCardBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(.ultraThinMaterial)
            .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
}

// MARK: - Contact Avatar View (Supports Photo Data)

private struct ContactAvatarView: View {
    let name: String
    let photoData: Data?
    let size: CGFloat
    
    private var initials: String {
        let components = name.split(separator: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        } else if let first = components.first {
            return String(first.prefix(2)).uppercased()
        }
        return "?"
    }
    
    private var backgroundColor: Color {
        // Use design system colors for avatars
        let colors: [Color] = [
            AppColors.mutedBlue,
            AppColors.darkTeal,
            AppColors.accentGreen,
            AppColors.softBeige,
            Color.purple,
            Color.pink,
            Color.orange
        ]
        let hash = name.hashValue
        return colors[abs(hash) % colors.count]
    }
    
    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.6), .white.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: size + 6, height: size + 6)
            
            if let photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(backgroundColor.gradient)
                    .frame(width: size, height: size)
                
                Text(initials)
                    .font(.custom(AppFontName.workSansMedium, size: size * 0.35))
                    .foregroundStyle(.white)
            }
        }
    }
}

// MARK: - Contact Progress Bar

private struct ContactProgressBar: View {
    let progress: Double
    let interactionCount: Int
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color(.systemGray5))
                        .frame(height: 12)
                    
                    // Progress fill
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: progressGradientColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(geometry.size.width * animatedProgress, 0), height: 12)
                }
            }
            .frame(height: 12)
            
            // Labels
            HStack {
                Text("0")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("50+")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 1.0, bounce: 0.3)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { oldValue, newValue in
            withAnimation(.spring(duration: 0.6, bounce: 0.2)) {
                animatedProgress = newValue
            }
        }
    }
    
    private var progressGradientColors: [Color] {
        if interactionCount < 10 {
            return [AppColors.mutedBlue, AppColors.darkTeal]
        } else if interactionCount < 25 {
            return [AppColors.accentGreen, Color.mint]
        } else if interactionCount < 40 {
            return [AppColors.softBeige, Color.orange]
        } else {
            return [Color.purple, Color.pink]
        }
    }
}

// MARK: - Scroll Offset Preference Key

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ContactDetailScreen(contact: Contact(
            name: "John Doe",
            phoneCountryCode: "+1",
            phoneNumber: "555-0123",
            reference: "Met at conference",
            email: "john@example.com",
            city: "San Francisco",
            state: "CA",
            country: "USA",
            company: "Tech Corp",
            jobTitle: "Developer",
            notes: "Great guy, loves coffee."
        ))
    }
}
