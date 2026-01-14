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
        colorScheme == .dark ? Color("Background-dark") : Color(.systemBackground)
    }
    
    private var headingColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Insights")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(headingColor)
                            
                            Text("Track your network patterns and engagement")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        KPICard(
                            innerCircleCount: innerCircleCount,
                            keyRelationshipsCount: keyRelationshipsCount,
                            broaderNetworkCount: broaderNetworkCount
                        )
                            .padding(.horizontal)

                        // Full Calendar Access
                        CalendarAccessCard()
                            .padding(.horizontal)
                        
                        // Engagement Stats
                        VStack(spacing: 12) {
                            Text("Engagement Statistics")
                                .font(.headline)
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
                            .background(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                            .frame(height: 20)
                    }
                }
                .scrollContentBackground(.visible)
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
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text("View full interaction schedule")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundStyle(Color("Blue-app"))
            }
            .padding()
            .background(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6))
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
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }
            
            Spacer()
            
            Text("\(count)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
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
                    .foregroundStyle(Color("Blue-app"))
                    .frame(width: 24)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    InsightsScreen()
        .modelContainer(for: [Contact.self, Interaction.self], inMemory: true)
}
