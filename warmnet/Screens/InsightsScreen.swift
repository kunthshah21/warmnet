//
//  InsightsScreen.swift
//  warmnet
//
//  Created on 14 January 2026.
//

import SwiftUI
import SwiftData

struct InsightsScreen: View {
    @Environment(\.colorScheme) private var colorScheme
    @Query private var contacts: [Contact]
    @Query private var interactions: [Interaction]
    
    @State private var showMapSheet = false
    @State private var selectedDate = Date()
    @State private var showDatePicker = false

    // MARK: - Computed Properties
    private var innerCircleCount: Int {
        contacts.filter { $0.priority == .innerCircle }.count
    }
    
    private var keyRelationshipsCount: Int {
        contacts.filter { $0.priority == .keyRelationships }.count
    }
    
    private var broaderNetworkCount: Int {
        contacts.filter { $0.priority == .broaderNetwork }.count
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? AppColors.deepNavy : Color(red: 0xF1/255, green: 0xF2/255, blue: 0xF6/255)
    }
    
    private var headingColor: Color {
        colorScheme == .dark ? AppColors.textPrimary : .black
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Header
                        HStack(spacing: 0) {
                            let titleString: AttributedString = {
                                var a = AttributedString("Go Deep into\nyour Network")
                                // Apply base font to the whole string
                                a.font = .system(size: 37, weight: .bold)
                                // Apply colors to specific ranges
                                if let rangeGo = a.range(of: "Go ") {
                                    a[rangeGo].foregroundColor = headingColor
                                }
                                if let rangeDeep = a.range(of: "Deep") {
                                    a[rangeDeep].foregroundColor = Color(red: 0.38, green: 0.51, blue: 0.98)
                                }
                                if let rangeIntoYour = a.range(of: " into\nyour ") {
                                    a[rangeIntoYour].foregroundColor = headingColor
                                }
                                if let rangeNetwork = a.range(of: "Network") {
                                    a[rangeNetwork].foregroundColor = Color(red: 0.38, green: 0.51, blue: 0.98)
                                }
                                return a
                            }()
                            
                            Text(titleString)
                            
                            Spacer()
                            
                            Button {
                                showDatePicker.toggle()
                            } label: {
                                HStack(spacing: 8) {
                                    Text(selectedDate, format: .dateTime.month(.abbreviated).day())
                                        .font(.custom("Inter", size: 12).weight(.medium))
                                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(red: 0.34, green: 0.34, blue: 0.34))
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(red: 0.34, green: 0.34, blue: 0.34))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .inset(by: 0.5)
                                        .stroke(colorScheme == .dark ? Color.white.opacity(0.2) : Color(red: 0.68, green: 0.68, blue: 0.68), lineWidth: 0.5)
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        AIInsightCard(
                            insightText: "This month, you've focused on connecting with professionals in the biotech and AI sectors. The trend shows a growing interest in collaborative projects at the intersection of these fields.",
                            onInteractionIdeas: {
                                // Handle interaction ideas action
                            },
                            onNetworkOpportunity: {
                                // Handle network opportunity action
                            }
                        )
                        .padding(.horizontal)
                        
                        MapPreviewCard {
                            showMapSheet = true
                        }
                        .padding(.horizontal)

                        // Full Calendar Access
                        CalendarAccessCard()
                            .padding(.horizontal)
                        
                        // Engagement Stats
                        VStack(spacing: 12) {
                            Text("Engagement Statistics")
                                .font(.custom(AppFontName.workSansMedium, size: 16))
                                .foregroundStyle(headingColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                StatRow(
                                    icon: "bubble.left.fill",
                                    title: "Total Interactions",
                                    value: "\(interactions.count)"
                                )
                                
                                StatRow(
                                    icon: "calendar",
                                    title: "Contacts with Reminders",
                                    value: "\(contacts.filter { $0.nextTouchDate != nil }.count)"
                                )
                                
                                StatRow(
                                    icon: "exclamationmark.circle.fill",
                                    title: "Overdue Contacts",
                                    value: "\(contacts.filter { $0.isOverdue }.count)"
                                )
                            }
                            .padding()
                            .background(colorScheme == .dark ? AppColors.charcoal : Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                            .frame(height: 20)
                    }
                }
                .scrollContentBackground(.visible)
            }
            .sheet(isPresented: $showMapSheet) {
                MapScreen(showsDismissButton: true)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showDatePicker) {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    .padding()
            }
        }
    }
}

// MARK: - Helper Views

struct CalendarAccessCard: View {
    @State private var showCalendar = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button {
            showCalendar = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                     Text("Calendar")
                        .font(.custom(AppFontName.workSansMedium, size: 16))
                        .foregroundStyle(.primary)
                    
                    Text("View full interaction schedule")
                        .font(.custom(AppFontName.workSansRegular, size: 14))
                        .foregroundStyle(colorScheme == .dark ? AppColors.textSecondary : .secondary)
                }
                
                Spacer()
                
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundStyle(AppColors.mutedBlue)
            }
            .padding()
            .background(colorScheme == .dark ? AppColors.charcoal : Color(.systemGray6))
            .cornerRadius(12)
        }
        .sheet(isPresented: $showCalendar) {
            ReminderCalendarScreen()
        }
    }
}

struct NetworkBreakdownRow: View {
    let title: String
    let count: Int
    let color: Color
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                
                Text(title)
                    .font(.custom(AppFontName.workSansRegular, size: 14))
                    .foregroundStyle(colorScheme == .dark ? AppColors.textPrimary : .primary)
            }
            
            Spacer()
            
            Text("\(count)")
                .font(.custom(AppFontName.workSansMedium, size: 14))
                .fontWeight(.semibold)
                .foregroundStyle(colorScheme == .dark ? AppColors.textSecondary : .secondary)
        }
        .padding(.vertical, 8)
    }
}

struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.mutedBlue)
                    .frame(width: 24)
                
                Text(title)
                    .font(.custom(AppFontName.workSansRegular, size: 14))
                    .foregroundStyle(colorScheme == .dark ? AppColors.textPrimary : .primary)
            }
            
            Spacer()
            
            Text(value)
                .font(.custom(AppFontName.workSansMedium, size: 14))
                .fontWeight(.semibold)
                .foregroundStyle(colorScheme == .dark ? AppColors.textSecondary : .secondary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    InsightsScreen()
        .modelContainer(for: [Contact.self, Interaction.self], inMemory: true)
}

