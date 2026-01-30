//
//  TodaysNetworkGoalsView.swift
//  warmnet
//
//  Created on 30/01/2026.
//

import SwiftUI

/// Reusable component displaying today's network goals with paginated carousel
struct TodaysNetworkGoalsView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let contacts: [Contact]
    let onContactTap: (Contact) -> Void
    var onSeeAllTap: (() -> Void)? = nil
    
    @State private var currentPage: Int = 0
    
    // Number of items per page in the goals carousel
    private let itemsPerPage = 4
    
    // Calculate total number of pages
    private var totalPages: Int {
        guard !contacts.isEmpty else { return 1 }
        return (contacts.count + itemsPerPage - 1) / itemsPerPage
    }
    
    var body: some View {
        VStack(spacing: 18) {
            // Header with title and See all
            headerRow
            
            // Goals carousel or empty state
            if contacts.isEmpty {
                emptyGoalsState
            } else {
                goalsCarousel
                
                // Page indicators
                if totalPages > 1 {
                    pageIndicators
                }
            }
        }
    }
    
    // MARK: - Header Row
    
    private var headerRow: some View {
        HStack {
            Text("Today's Network Goals")
                .font(.custom(AppFontName.workSansMedium, size: 20))
                .foregroundStyle(.primary)
            
            Spacer()
            
            Button {
                onSeeAllTap?()
            } label: {
                Text("See all")
                    .font(.custom(AppFontName.workSansMedium, size: 15))
                    .underline()
                    .foregroundStyle(Color(red: 0.03, green: 0, blue: 0.81))
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyGoalsState: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(AppColors.accentGreen)
            
            Text("You're all caught up for today!")
                .font(.custom(AppFontName.workSansMedium, size: 16))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
    
    // MARK: - Goals Carousel
    
    private var goalsCarousel: some View {
        TabView(selection: $currentPage) {
            ForEach(0..<totalPages, id: \.self) { pageIndex in
                goalsPage(for: pageIndex)
                    .tag(pageIndex)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 145)
    }
    
    private func goalsPage(for pageIndex: Int) -> some View {
        let startIndex = pageIndex * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, contacts.count)
        let pageContacts = Array(contacts[startIndex..<endIndex])
        
        return HStack(spacing: 10) {
            ForEach(pageContacts) { contact in
                Button {
                    onContactTap(contact)
                } label: {
                    goalContactCard(for: contact)
                }
                .buttonStyle(.plain)
            }
            
            // Add spacers if page is not full
            if pageContacts.count < itemsPerPage {
                ForEach(0..<(itemsPerPage - pageContacts.count), id: \.self) { _ in
                    Color.clear
                        .frame(width: 85)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func goalContactCard(for contact: Contact) -> some View {
        VStack(spacing: 10) {
            AvatarView(name: contact.name, size: 55)
            
            Text(formatName(contact.name))
                .font(.custom(AppFontName.workSansMedium, size: 10))
                .lineSpacing(4)
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
                .lineLimit(2)
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 14)
        .frame(width: 85)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(goalCardBackgroundColor)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private func formatName(_ fullName: String) -> String {
        let components = fullName.components(separatedBy: " ")
        if components.count >= 2 {
            return "\(components[0])\n\(components[1])"
        }
        return fullName
    }
    
    // MARK: - Page Indicators
    
    private var pageIndicators: some View {
        HStack(spacing: 3) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.gray.opacity(0.65) : Color.gray.opacity(0.35))
                    .frame(width: 7, height: 7)
            }
        }
    }
    
    // MARK: - Colors
    
    private var goalCardBackgroundColor: Color {
        colorScheme == .dark
            ? AppColors.charcoal
            : .white
    }
}

// MARK: - Preview

#Preview {
    let sampleContacts = [
        Contact(name: "Michael Thompson", priority: .innerCircle),
        Contact(name: "Sarah Johnson", priority: .keyRelationships),
        Contact(name: "Emily Roberts", priority: .innerCircle),
        Contact(name: "David Williams", priority: .broaderNetwork),
        Contact(name: "Lisa Park", priority: .keyRelationships),
        Contact(name: "James Brown", priority: .broaderNetwork)
    ]
    
    return VStack {
        TodaysNetworkGoalsView(
            contacts: sampleContacts,
            onContactTap: { _ in },
            onSeeAllTap: {}
        )
        .padding()
        
        Divider()
        
        // Empty state preview
        TodaysNetworkGoalsView(
            contacts: [],
            onContactTap: { _ in }
        )
        .padding()
    }
    .background(Color.gray.opacity(0.1))
}
