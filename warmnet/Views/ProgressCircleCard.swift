//
//  ProgressCircleCard.swift
//  warmnet
//
//  Created on 31/01/2026.
//

import SwiftUI
import SwiftData

/// Card displaying weekly progress with concentric ring visualization
struct ProgressCircleCard: View {
    @Environment(\.colorScheme) private var colorScheme
    @Query private var contacts: [Contact]
    @Query private var interactions: [Interaction]
    
    var onTap: (() -> Void)? = nil
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var startOfWeek: Date {
        calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
    }
    
    private var endOfWeek: Date {
        calendar.dateInterval(of: .weekOfYear, for: Date())?.end ?? Date()
    }
    
    // Calculate progress for each tier this week
    private var tierProgresses: [TierProgressData] {
        let priorities: [Priority] = [.innerCircle, .keyRelationships, .broaderNetwork]
        
        return priorities.map { priority in
            let tierContacts = contacts.filter { $0.priority == priority }
            let contactedThisWeek = tierContacts.filter { contact in
                guard let lastContacted = contact.lastContacted else { return false }
                return lastContacted >= startOfWeek && lastContacted <= endOfWeek
            }.count
            
            let total = tierContacts.count
            let progress = total > 0 ? Double(contactedThisWeek) / Double(total) : 0
            
            return TierProgressData(
                priority: priority,
                contacted: contactedThisWeek,
                total: total,
                progress: progress
            )
        }
    }
    
    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                // Header with title and arrow
                HStack {
                    Text("Progress")
                        .font(.custom(AppFontName.workSansMedium, size: 18))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                        .padding(8)
                        .background(Circle().fill(Color.black.opacity(0.1)))
                }
                
                Spacer()
                
                // Concentric rings centered
                HStack {
                    Spacer()
                    ProgressConcentricRings(progresses: tierProgresses)
                    Spacer()
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.85, green: 0.82, blue: 0.95)) // Lavender/purple tint
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Supporting Types

struct TierProgressData: Identifiable {
    let id = UUID()
    let priority: Priority
    let contacted: Int
    let total: Int
    let progress: Double
    
    var color: Color {
        switch priority {
        case .innerCircle:
            return Color(red: 0.2, green: 0.9, blue: 0.7) // Cyan/teal
        case .keyRelationships:
            return Color(red: 0.7, green: 1.0, blue: 0.3) // Lime green
        case .broaderNetwork:
            return Color(red: 1.0, green: 0.4, blue: 0.6) // Pink/coral
        }
    }
}

// MARK: - Concentric Rings for Progress Card

struct ProgressConcentricRings: View {
    let progresses: [TierProgressData]
    
    private let ringSize: CGFloat = 90
    private let lineWidth: CGFloat = 10
    private let gap: CGFloat = 12
    
    var body: some View {
        ZStack {
            // Outer ring - Broader Network (pink)
            if let broader = progresses.first(where: { $0.priority == .broaderNetwork }) {
                ProgressRingView(
                    progress: broader.progress,
                    color: broader.color,
                    lineWidth: lineWidth,
                    size: ringSize
                )
            }
            
            // Middle ring - Key Relationships (lime)
            if let key = progresses.first(where: { $0.priority == .keyRelationships }) {
                ProgressRingView(
                    progress: key.progress,
                    color: key.color,
                    lineWidth: lineWidth,
                    size: ringSize - gap * 2
                )
            }
            
            // Inner ring - Inner Circle (cyan)
            if let inner = progresses.first(where: { $0.priority == .innerCircle }) {
                ProgressRingView(
                    progress: inner.progress,
                    color: inner.color,
                    lineWidth: lineWidth,
                    size: ringSize - gap * 4
                )
            }
        }
        .frame(width: ringSize, height: ringSize)
    }
}

struct ProgressRingView: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat
    let size: CGFloat
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(color.opacity(0.3), lineWidth: lineWidth)
            
            // Progress arc
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.spring(duration: 1.0, bounce: 0.3)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.spring(duration: 0.6, bounce: 0.2)) {
                animatedProgress = newValue
            }
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.1)
            .ignoresSafeArea()
        
        ProgressCircleCard()
            .padding()
    }
}
