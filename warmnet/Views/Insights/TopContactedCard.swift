//
//  TopContactedCard.swift
//  warmnet
//
//  Reusable card showing most-contacted people.
//  Tapping opens a detail sheet with a per-person bar chart
//  and a collapsible dropdown of not-yet-contacted people ordered by priority.
//

import SwiftUI
import SwiftData

// MARK: - Top Contacted Card

/// Collapsed card showing the top 3 most-contacted people.
/// Tapping opens `ContactFrequencySheet` with the full breakdown.
struct TopContactedCard: View {
    @Environment(\.colorScheme) private var colorScheme
    @Query private var contacts: [Contact]

    @State private var showDetailSheet = false

    // MARK: Computed

    private var contactedContacts: [(contact: Contact, count: Int)] {
        contacts
            .map { ($0, $0.interactions.count) }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
    }

    private var topThree: [(contact: Contact, count: Int)] {
        Array(contactedContacts.prefix(3))
    }

    // MARK: Body

    var body: some View {
        Button {
            HapticManager.impact(.light)
            showDetailSheet = true
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                // Card header
                HStack(alignment: .center, spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(AppColors.mutedBlue.opacity(0.15))
                            .frame(width: 40, height: 40)
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(AppColors.mutedBlue)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Top Connections")
                            .font(.custom(AppFontName.workSansMedium, size: 16))
                            .foregroundStyle(.primary)
                        Text("Most contacted people")
                            .font(.custom(AppFontName.workSansRegular, size: 12))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }

                Divider()

                // Content
                if topThree.isEmpty {
                    emptyState
                } else {
                    topContactsList
                }
            }
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark
                          ? AppColors.charcoal
                          : Color(uiColor: .secondarySystemGroupedBackground))
                    .shadow(
                        color: colorScheme == .dark ? .clear : .black.opacity(0.06),
                        radius: 12, x: 0, y: 6
                    )
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDetailSheet) {
            ContactFrequencySheet()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: Sub-views

    private var emptyState: some View {
        HStack(spacing: 10) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 20))
                .foregroundStyle(.tertiary)
            Text("No interactions logged yet")
                .font(.custom(AppFontName.workSansRegular, size: 14))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }

    private var topContactsList: some View {
        VStack(spacing: 10) {
            ForEach(Array(topThree.enumerated()), id: \.element.contact.id) { index, item in
                HStack(spacing: 12) {
                    // Rank indicator
                    Text("#\(index + 1)")
                        .font(.custom(AppFontName.workSansMedium, size: 11))
                        .foregroundStyle(.tertiary)
                        .frame(width: 20, alignment: .trailing)

                    // Initials avatar
                    ContactInitialsAvatar(name: item.contact.name, size: 32)

                    // Name
                    Text(item.contact.name)
                        .font(.custom(AppFontName.workSansRegular, size: 14))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Spacer()

                    // Interaction count badge
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left.fill")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(AppColors.mutedBlue.opacity(0.7))
                        Text("\(item.count)")
                            .font(.custom(AppFontName.workSansMedium, size: 13))
                            .foregroundStyle(AppColors.mutedBlue)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppColors.mutedBlue.opacity(0.1))
                    .clipShape(Capsule())
                }
            }
        }
    }
}

// MARK: - Contact Frequency Detail Sheet

/// Full sheet opened from TopContactedCard.
/// Shows a horizontal bar chart of all contacted people, then a
/// collapsible dropdown of not-yet-contacted people by priority (green → yellow).
struct ContactFrequencySheet: View {
    @Environment(\.colorScheme) private var colorScheme
    @Query private var contacts: [Contact]

    @State private var showUncontacted = false

    // MARK: Computed

    private var contactedContacts: [(contact: Contact, count: Int)] {
        contacts
            .map { ($0, $0.interactions.count) }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
    }

    private var uncontactedContacts: [Contact] {
        contacts
            .filter { $0.interactions.isEmpty }
            .sorted { priorityOrder($0) < priorityOrder($1) }
    }

    private var maxCount: Int {
        max(contactedContacts.map { $0.count }.max() ?? 1, 1)
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                Text("Contact Frequency")
                    .font(.custom(AppFontName.workSansMedium, size: 22))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)

                // Bar chart section
                if contactedContacts.isEmpty {
                    emptyChartState
                } else {
                    barChartSection
                }

                // Not-yet-contacted dropdown
                uncontactedSection

                Spacer(minLength: 32)
            }
            .padding(.horizontal, 24)
            .padding(.top, 4)
        }
        .scrollContentBackground(.visible)
        .background(Color(.systemBackground))
    }

    // MARK: Bar Chart Section

    private var barChartSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Interactions per Person", systemImage: "chart.bar.fill")
                    .font(.custom(AppFontName.workSansMedium, size: 14))
                    .foregroundStyle(.secondary)
                    .labelStyle(.titleAndIcon)

                Spacer()

                Text("\(contactedContacts.count) contacted")
                    .font(.custom(AppFontName.workSansRegular, size: 12))
                    .foregroundStyle(.tertiary)
            }

            VStack(spacing: 14) {
                ForEach(Array(contactedContacts.enumerated()), id: \.element.contact.id) { index, item in
                    contactBarRow(item: item, rank: index + 1)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark
                      ? Color(.systemGray6)
                      : Color(.systemGray6).opacity(0.5))
        )
    }

    @ViewBuilder
    private func contactBarRow(item: (contact: Contact, count: Int), rank: Int) -> some View {
        HStack(spacing: 10) {
            // Avatar
            ContactInitialsAvatar(name: item.contact.name, size: 30)

            // Name
            Text(item.contact.name)
                .font(.custom(AppFontName.workSansRegular, size: 13))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .frame(width: 90, alignment: .leading)

            // Horizontal bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color(.systemGray5))
                        .frame(height: 20)

                    RoundedRectangle(cornerRadius: 5)
                        .fill(AppGradients.blueGlow)
                        .frame(
                            width: barWidth(for: item.count, totalWidth: geo.size.width),
                            height: 20
                        )
                }
            }
            .frame(height: 20)

            // Count
            Text("\(item.count)")
                .font(.custom(AppFontName.workSansMedium, size: 13))
                .foregroundStyle(AppColors.mutedBlue)
                .frame(width: 24, alignment: .trailing)
        }
    }

    private var emptyChartState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 38))
                .foregroundStyle(.tertiary)
            Text("No interactions logged yet")
                .font(.custom(AppFontName.workSansMedium, size: 15))
                .foregroundStyle(.secondary)
            Text("Log your first interaction to see your contact frequency here.")
                .font(.custom(AppFontName.workSansRegular, size: 13))
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark
                      ? Color(.systemGray6)
                      : Color(.systemGray6).opacity(0.5))
        )
    }

    // MARK: Uncontacted Dropdown

    private var uncontactedSection: some View {
        VStack(spacing: 0) {
            // Disclosure header
            Button {
                HapticManager.impact(.light)
                withAnimation(.spring(duration: 0.35, bounce: 0.1)) {
                    showUncontacted.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.12))
                            .frame(width: 36, height: 36)
                        Image(systemName: "person.crop.circle.badge.clock")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.orange)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Not Yet Contacted")
                            .font(.custom(AppFontName.workSansMedium, size: 15))
                            .foregroundStyle(.primary)
                        if uncontactedContacts.isEmpty {
                            Text("Everyone contacted — nice work!")
                                .font(.custom(AppFontName.workSansRegular, size: 12))
                                .foregroundStyle(.green)
                        } else {
                            Text("\(uncontactedContacts.count) people awaiting outreach")
                                .font(.custom(AppFontName.workSansRegular, size: 12))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    if !uncontactedContacts.isEmpty {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                            .rotationEffect(.degrees(showUncontacted ? 180 : 0))
                            .animation(.easeInOut(duration: 0.25), value: showUncontacted)
                    }
                }
                .padding(16)
            }
            .buttonStyle(.plain)

            // Expanded rows
            if showUncontacted && !uncontactedContacts.isEmpty {
                Divider()
                    .padding(.horizontal, 16)

                if uncontactedContacts.isEmpty {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Everyone has been contacted!")
                            .font(.custom(AppFontName.workSansRegular, size: 14))
                            .foregroundStyle(.secondary)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(uncontactedContacts.enumerated()), id: \.element.id) { index, contact in
                            uncontactedRow(contact: contact)

                            if index < uncontactedContacts.count - 1 {
                                Divider()
                                    .padding(.leading, 56)
                            }
                        }
                    }
                    .padding(.bottom, 4)
                }
            }
        }
        .background(
            colorScheme == .dark
            ? Color(.systemGray6)
            : Color(.systemGray6).opacity(0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray4).opacity(0.4), lineWidth: 0.5)
        )
    }

    @ViewBuilder
    private func uncontactedRow(contact: Contact) -> some View {
        HStack(spacing: 12) {
            // Priority colour dot
            Circle()
                .fill(priorityColor(contact.priority))
                .frame(width: 9, height: 9)

            // Initials avatar
            ContactInitialsAvatar(name: contact.name, size: 32)

            // Name + tier
            VStack(alignment: .leading, spacing: 2) {
                Text(contact.name)
                    .font(.custom(AppFontName.workSansRegular, size: 14))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                if let priority = contact.priority {
                    Text(priority.rawValue)
                        .font(.custom(AppFontName.workSansRegular, size: 11))
                        .foregroundStyle(priorityColor(contact.priority).opacity(0.9))
                }
            }

            Spacer()

            // Priority pill
            if let priority = contact.priority {
                Text(priorityLabel(priority))
                    .font(.custom(AppFontName.workSansMedium, size: 11))
                    .foregroundStyle(priorityColor(contact.priority))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(priorityColor(contact.priority).opacity(0.12))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: Helpers

    private func barWidth(for count: Int, totalWidth: CGFloat) -> CGFloat {
        let minWidth: CGFloat = 8
        guard maxCount > 0 else { return minWidth }
        let proportion = CGFloat(count) / CGFloat(maxCount)
        return minWidth + proportion * (totalWidth - minWidth)
    }

    private func priorityOrder(_ contact: Contact) -> Int {
        switch contact.priority {
        case .innerCircle:      return 0
        case .keyRelationships: return 1
        case .broaderNetwork:   return 2
        case .none:             return 3
        }
    }

    private func priorityColor(_ priority: Priority?) -> Color {
        switch priority {
        case .innerCircle:      return .green
        case .keyRelationships: return Color(red: 1.0, green: 0.6, blue: 0.2)
        case .broaderNetwork:   return Color(red: 1.0, green: 0.85, blue: 0.1)
        case .none:             return .gray
        }
    }

    private func priorityLabel(_ priority: Priority) -> String {
        switch priority {
        case .innerCircle:      return "High"
        case .keyRelationships: return "Medium"
        case .broaderNetwork:   return "Low"
        }
    }
}

// MARK: - Initials Avatar (private utility)

/// Simple initials-based avatar used within this file.
private struct ContactInitialsAvatar: View {
    let name: String
    let size: CGFloat

    private var initials: String {
        let parts = name.split(separator: " ")
        let first  = parts.first?.prefix(1) ?? ""
        let second = parts.dropFirst().first?.prefix(1) ?? ""
        return "\(first)\(second)".uppercased()
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(AppColors.mutedBlue.opacity(0.18))
                .frame(width: size, height: size)
            Text(initials.isEmpty ? "?" : initials)
                .font(.custom(AppFontName.workSansMedium, size: size * 0.36))
                .foregroundStyle(AppColors.mutedBlue)
        }
    }
}

// MARK: - Preview

#Preview("Card") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, Interaction.self, configurations: config)

    return ZStack {
        Color(.systemGroupedBackground).ignoresSafeArea()
        TopContactedCard()
            .padding()
    }
    .modelContainer(container)
}

#Preview("Sheet") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, Interaction.self, configurations: config)

    return ContactFrequencySheet()
        .modelContainer(container)
}
